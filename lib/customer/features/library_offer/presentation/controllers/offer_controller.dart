import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/idempotency.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/customer/features/library_offer/domain/entities/library_offer.dart';
import 'package:project/customer/features/library_offer/domain/repositories/offer_repository.dart';

enum OfferViewState {
  loading,

  /// لم تسعّر المكتبة الطلب بعد (404 no_offer_yet).
  notReady,
  open,
  expired,
  approved,
  rejected,

  /// العرض تغيّر أو حُسم من مكان آخر (superseded أو no_open_offer).
  changed,
  failed,
}

class OfferController extends GetxController {
  OfferController({
    required this.orderId,
    required OfferRepository repository,
    required SessionStore session,
    DateTime Function()? clock,
  })  : _repository = repository,
        _session = session,
        _now = clock ?? DateTime.now;

  final int orderId;
  final OfferRepository _repository;
  final SessionStore _session;
  final DateTime Function() _now;

  final offer = Rxn<LibraryOffer>();
  final viewState = OfferViewState.loading.obs;
  final failure = Rxn<Failure>();
  final acting = false.obs;

  /// موافقة صريحة على البدائل قبل قبول العرض.
  final substitutionsAccepted = false.obs;
  final remaining = Duration.zero.obs;

  String? _approveKey;
  int? _approveKeyOfferId;
  Timer? _ticker;
  Timer? _poller;
  AppLifecycleListener? _lifecycle;

  /// فاصل التحديث التلقائي أثناء انتظار العرض أو مراجعته.
  static const pollInterval = Duration(seconds: 15);

  @override
  void onReady() {
    super.onReady();
    load();
    _poller = Timer.periodic(pollInterval, (_) => refreshQuietly());
    _lifecycle = AppLifecycleListener(onResume: refreshQuietly);
  }

  /// تحديث بلا مؤشر تحميل: عند العودة للتطبيق ودوريًا أثناء الانتظار.
  /// إن تغيّر العرض المفتوح على الخادم يُعرض للمراجعة من جديد.
  Future<void> refreshQuietly() async {
    if (acting.value || orderId <= 0) return;
    final state = viewState.value;
    if (state == OfferViewState.notReady) return load(silent: true);
    if (state != OfferViewState.open) return;
    final shown = offer.value;
    if (shown == null) return;
    final guard = _session.guard();
    final latest = await _repository.offer(orderId);
    if (!guard.isCurrent || acting.value) return;
    latest.fold((_) {}, (fresh) {
      if (fresh == shown) return;
      _show(fresh);
      if (viewState.value == OfferViewState.open) {
        viewState.value = OfferViewState.changed;
      }
    });
  }

  Future<void> load({bool silent = false}) async {
    if (orderId <= 0) {
      failure.value = const ServerFailure(code: ApiErrorCodes.notFound);
      viewState.value = OfferViewState.failed;
      return;
    }
    if (!silent) viewState.value = OfferViewState.loading;
    failure.value = null;
    final guard = _session.guard();
    final result = await _repository.offer(orderId);
    if (!guard.isCurrent) return;
    result.fold(_onFailure, (o) => _show(o, fromRefresh: true));
  }

  void _show(LibraryOffer o, {bool fromRefresh = false}) {
    final previous = offer.value;
    // عرض جديد يحل محل القديم: تُلغى موافقة البدائل السابقة.
    if (previous != null && previous.id != o.id) {
      substitutionsAccepted.value = false;
    }
    offer.value = o;
    viewState.value = switch (o.status) {
      OfferStatus.approved => OfferViewState.approved,
      OfferStatus.rejected => OfferViewState.rejected,
      OfferStatus.expired => OfferViewState.expired,
      OfferStatus.superseded => OfferViewState.changed,
      _ => o.isOpenAt(_now()) ? OfferViewState.open : OfferViewState.expired,
    };
    _startTicker();
  }

  void _onFailure(Failure f) {
    failure.value = f;
    if (f.code == ApiErrorCodes.notFound && f.reason == 'no_offer_yet') {
      viewState.value = OfferViewState.notReady;
    } else {
      viewState.value = OfferViewState.failed;
    }
  }

  bool get canApprove {
    final o = offer.value;
    if (o == null || acting.value) return false;
    if (viewState.value != OfferViewState.open || !o.isOpenAt(_now())) {
      return false;
    }
    return !o.hasSubstitutions || substitutionsAccepted.value;
  }

  Future<void> approve() async {
    if (!canApprove) return;
    final o = offer.value!;
    acting.value = true;
    final guard = _session.guard();
    // POST /offer/approve لا يحمل رقم العرض ويعتمد العرض المفتوح حاليًا،
    // فنتأكد أولًا أن ما يراه الزبون هو نفس العرض على الخادم.
    if (!await _stillShowingLatest(o, guard)) return;
    if (_approveKeyOfferId != o.id) {
      _approveKey = IdempotencyKey.generate();
      _approveKeyOfferId = o.id;
    }
    final result = await _repository.approve(orderId, _approveKey!);
    if (!guard.isCurrent) return;
    acting.value = false;
    await result.fold(_onDecisionFailure, (o) async => _show(o));
  }

  Future<void> reject() async {
    final o = offer.value;
    if (o == null || acting.value || viewState.value != OfferViewState.open) {
      return;
    }
    acting.value = true;
    final guard = _session.guard();
    if (!await _stillShowingLatest(o, guard)) return;
    final result = await _repository.reject(orderId);
    if (!guard.isCurrent) return;
    acting.value = false;
    await result.fold(_onDecisionFailure, (o) async => _show(o));
  }

  /// يجلب أحدث عرض؛ إن اختلف عن المعروض (رقمه أو حالته أو بنوده أو مبالغه)
  /// يعرض النسخة الجديدة بحالة «تم تحديث العرض» ولا يتابع القرار.
  Future<bool> _stillShowingLatest(
      LibraryOffer shown, SessionGuard guard) async {
    final latest = await _repository.offer(orderId);
    if (!guard.isCurrent) return false;
    return latest.fold((f) {
      acting.value = false;
      failure.value = f;
      return false;
    }, (fresh) {
      if (fresh == shown &&
          fresh.itemsTotal == shown.itemsTotal &&
          fresh.deliveryFee == shown.deliveryFee) {
        return true;
      }
      acting.value = false;
      _show(fresh);
      if (viewState.value == OfferViewState.open) {
        viewState.value = OfferViewState.changed;
      }
      return false;
    });
  }

  Future<void> _onDecisionFailure(Failure f) async {
    // موثّق كـ 409 offer_expired؛ لم يُختبر فعليًا، فنقبل الرمز أو السبب.
    if (f.reason == 'offer_expired' || f.code == 'offer_expired') {
      failure.value = f;
      viewState.value = OfferViewState.expired;
      return;
    }
    if (f.code == ApiErrorCodes.invalidTransition ||
        f.code == ApiErrorCodes.conflict) {
      // حُسم أو تغيّر العرض من مكان آخر: نعرض أحدث حالة.
      final guard = _session.guard();
      final latest = await _repository.offer(orderId);
      if (!guard.isCurrent) return;
      latest.fold(_onFailure, (o) {
        _show(o);
        if (viewState.value == OfferViewState.open) {
          viewState.value = OfferViewState.changed;
        }
      });
      failure.value = f;
      return;
    }
    failure.value = f;
  }

  void _startTicker() {
    _ticker?.cancel();
    final expires = offer.value?.expiresAt;
    if (expires == null || viewState.value != OfferViewState.open) return;
    void tick() {
      final left = expires.difference(_now());
      remaining.value = left.isNegative ? Duration.zero : left;
      if (left.isNegative || left == Duration.zero) {
        _ticker?.cancel();
        if (viewState.value == OfferViewState.open) {
          viewState.value = OfferViewState.expired;
        }
      }
    }

    tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  @override
  void onClose() {
    _ticker?.cancel();
    _poller?.cancel();
    _lifecycle?.dispose();
    super.onClose();
  }
}
