import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/idempotency.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/picked_file.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/checkout/domain/usecases/get_order_usecase.dart';
import 'package:project/customer/features/payment/domain/usecases/submit_receipt_usecase.dart';
import 'package:project/customer/features/printing/domain/entities/file_check.dart';

/// إشعار اختاره الزبون ولم يُرسل بعد.
class SelectedReceipt {
  const SelectedReceipt({
    required this.name,
    required this.size,
    required this.mime,
    required this.bytes,
  });

  final String name;
  final int size;
  final String mime;
  final Uint8List bytes;
}

/// عقد تصحيح الطلب → الدفع: يكفي orderId؛ الشاشة تجلب حالة الدفع الحالية.
class TransferPaymentController extends GetxController {
  TransferPaymentController({
    required this.orderId,
    required RemoteConfigRepository config,
    required SessionStore session,
    required GetOrderUseCase getOrder,
    required UploadRepository uploads,
    required SubmitReceiptUseCase submitReceipt,
    required FileSource files,
  })  : _config = config,
        _session = session,
        _getOrder = getOrder,
        _uploads = uploads,
        _submitReceipt = submitReceipt,
        _files = files;

  final int orderId;
  final RemoteConfigRepository _config;
  final SessionStore _session;
  final GetOrderUseCase _getOrder;
  final UploadRepository _uploads;
  final SubmitReceiptUseCase _submitReceipt;
  final FileSource _files;

  final order = Rxn<PlacedOrder>();
  final transfer = Rxn<TransferConfig>();
  final currency = Rxn<RemoteConfig>();
  final loading = false.obs;
  final loadFailure = Rxn<Failure>();

  final receipt = Rxn<SelectedReceipt>();
  final rejection = Rxn<FileRejection>();
  final uploadProgress = 0.0.obs;
  final submitting = false.obs;
  final submitFailure = Rxn<Failure>();

  /// الحالة تغيّرت على الخادم أثناء الإرسال (invalid_transition أو conflict).
  final stateChanged = false.obs;
  final justSubmitted = false.obs;

  int? _uploadedId;
  String? _submitKey;
  Timer? _poller;
  AppLifecycleListener? _lifecycle;

  static const pollInterval = Duration(seconds: 15);

  @override
  void onReady() {
    super.onReady();
    load();
    _poller = Timer.periodic(pollInterval, (_) => refreshQuietly());
    _lifecycle = AppLifecycleListener(onResume: refreshQuietly);
  }

  /// يحدّث حالة الطلب بلا مؤشر تحميل: عند العودة للتطبيق، ودوريًا ما دام
  /// الطلب ينتظر خطوة من المكتبة. لا يقاطع زبونًا يرفع إشعارًا.
  Future<void> refreshQuietly() async {
    if (submitting.value || loading.value || orderId <= 0) return;
    final current = order.value;
    final waiting =
        current == null || !current.canSubmitReceipt || receipt.value == null;
    if (!waiting) return;
    final guard = _session.guard();
    final result = await _getOrder(orderId);
    if (!guard.isCurrent || submitting.value) return;
    result.fold((_) {}, (o) {
      if (o != order.value) order.value = o;
    });
  }

  @override
  void onClose() {
    _poller?.cancel();
    _lifecycle?.dispose();
    super.onClose();
  }

  Future<void> load() async {
    if (orderId <= 0) {
      loadFailure.value = const ServerFailure(code: ApiErrorCodes.notFound);
      return;
    }
    loading.value = true;
    loadFailure.value = null;
    final guard = _session.guard();
    final configResult = await _config.load();
    final orderResult = await _getOrder(orderId);
    if (!guard.isCurrent) return;
    configResult.fold((_) {}, (c) {
      currency.value = c;
      transfer.value = c.transfer;
    });
    orderResult.fold((f) => loadFailure.value = f, (o) => order.value = o);
    loading.value = false;
  }

  Future<void> pickReceipt() async {
    final t = transfer.value;
    if (t == null || submitting.value) return;
    final picked = await _files.pick(multiple: false);
    if (picked.isEmpty) return;
    final file = picked.first;
    final bytes = await file.readBytes();
    final check = FileCheck.check(
      size: file.size,
      header: bytes.length > 16 ? bytes.sublist(0, 16) : bytes,
      allowedMimes: t.receiptMimes,
      maxBytes: t.receiptMaxBytes,
    );
    if (!check.isAccepted) {
      rejection.value = check.rejection;
      return;
    }
    rejection.value = null;
    submitFailure.value = null;
    _uploadedId = null;
    _submitKey = null;
    uploadProgress.value = 0;
    receipt.value = SelectedReceipt(
      name: file.name,
      size: file.size,
      mime: check.mime!,
      bytes: bytes,
    );
  }

  void removeReceipt() {
    if (submitting.value) return;
    receipt.value = null;
    _uploadedId = null;
    _submitKey = null;
    uploadProgress.value = 0;
  }

  bool get canSubmit =>
      (order.value?.canSubmitReceipt ?? false) &&
      receipt.value != null &&
      !submitting.value;

  Future<void> submit() async {
    if (!canSubmit) return;
    final selected = receipt.value!;
    final guard = _session.guard();
    submitting.value = true;
    submitFailure.value = null;
    stateChanged.value = false;

    if (_uploadedId == null) {
      final up = await _uploads.upload(
        bytes: selected.bytes,
        fileName: selected.name,
        mime: selected.mime,
        purpose: UploadPurpose.paymentReceipt,
        onProgress: (p) => uploadProgress.value = p,
      );
      if (!guard.isCurrent) return;
      final ok = up.fold((f) {
        submitFailure.value = f;
        return false;
      }, (u) {
        _uploadedId = u.uploadId;
        return true;
      });
      if (!ok) {
        submitting.value = false;
        return;
      }
    }

    // مفتاح واحد لكل إشعار مرفوع؛ يُعاد استخدامه عند إعادة المحاولة.
    _submitKey ??= IdempotencyKey.generate();
    final result = await _submitReceipt(
      orderId: orderId,
      uploadId: _uploadedId!,
      idempotencyKey: _submitKey!,
    );
    if (!guard.isCurrent) return;
    submitting.value = false;
    await result.fold((failure) async {
      submitFailure.value = failure;
      final code = failure.code;
      if (code == ApiErrorCodes.invalidTransition ||
          code == ApiErrorCodes.conflict) {
        stateChanged.value = true;
        await load();
      }
    }, (updated) async {
      order.value = updated;
      receipt.value = null;
      _uploadedId = null;
      _submitKey = null;
      justSubmitted.value = true;
    });
  }
}
