import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/theme/app_theme.dart';
import 'package:project/core/uploads/picked_file.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/checkout/domain/usecases/get_order_usecase.dart';
import 'package:project/customer/features/library_offer/domain/entities/library_offer.dart';
import 'package:project/customer/features/library_offer/domain/repositories/offer_repository.dart';
import 'package:project/customer/features/library_offer/presentation/controllers/offer_controller.dart';
import 'package:project/customer/features/library_offer/presentation/views/offer_view.dart';
import 'package:project/customer/features/payment/domain/repositories/payment_repository.dart';
import 'package:project/customer/features/payment/domain/usecases/submit_receipt_usecase.dart';
import 'package:project/customer/features/payment/presentation/controllers/transfer_payment_controller.dart';
import 'package:project/customer/features/payment/presentation/views/transfer_payment_view.dart';

import '../helpers/purchasing_fakes.dart';

// Controlled layout check (not a live test): the purchase screens on a small
// phone with large system text, in both directions, must not overflow.

const _longName =
    'دفتر سلكي كبير مقاس A4 بغلاف كرتوني مقوّى ولون كحلي غامق مع فواصل ملونة';

Map<String, dynamic> _offer() => {
      'id': 40,
      'order_id': 63,
      'status': 'sent',
      'items': [
        {
          'id': 1,
          'name': _longName,
          'qty': 12,
          'unit_price': {'amount': 12345},
          'available': false,
          'substitute': {
            'name': '$_longName — بديل أخضر',
            'unit_price': {'amount': 13345},
          },
          'line_total': {'amount': 0},
          'note': 'ملاحظة طويلة من المكتبة عن سبب الاستبدال وموعد توفر المنتج',
        },
        {
          'id': 2,
          'name': 'طقم أقلام حبر 3 قطع',
          'qty': 2,
          'unit_price': {'amount': 500},
          'available': true,
          'substitute': null,
          'line_total': {'amount': 1000},
          'note': null,
        },
      ],
      'items_total': {'amount': 1000},
      'delivery_fee': {'amount': 2300},
      'total': {'amount': 3300},
      'note': 'تم تسعير الطلب من المكتبة، يرجى المراجعة قبل الموافقة.',
      'expires_at': '2026-10-29T14:38:03+00:00',
      'created_at': '2026-10-29T13:38:03+00:00',
    };

class _Offers implements OfferRepository {
  @override
  Future<Either<Failure, LibraryOffer>> offer(int orderId) async =>
      Right(LibraryOffer.fromJson(_offer()));

  @override
  Future<Either<Failure, LibraryOffer>> approve(
          int orderId, int offerId, String key) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, LibraryOffer>> reject(int orderId,
          {int? offerId, String? reason}) =>
      throw UnimplementedError();
}

class _NoFiles implements FileSource {
  @override
  Future<List<PickedFile>> pick({required bool multiple}) async => const [];
}

class _NoPayments implements PaymentRepository {
  @override
  Future<Either<Failure, PlacedOrder>> submitReceipt({
    required int orderId,
    required int uploadId,
    required String idempotencyKey,
  }) =>
      throw UnimplementedError();
}

Future<void> _pump(WidgetTester tester, Widget screen,
    {required String locale, required double scale}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(320, 568);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(GetMaterialApp(
    theme: AppTheme.light(),
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: screen,
  ));
  await tester.pump(const Duration(milliseconds: 100));
}

/// يمرّر القائمة حتى نهايتها حتى تُبنى كل العناصر وتُفحص.
Future<void> _scrollThrough(WidgetTester tester) async {
  final lists = find.byType(Scrollable);
  if (lists.evaluate().isEmpty) return;
  for (var i = 0; i < 12; i++) {
    await tester.drag(lists.first, const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  tearDown(Get.reset);

  for (final locale in ['ar', 'en']) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('offer with substitutes · $locale · text ×$scale',
          (tester) async {
        final session = await signedInSession();
        Get.put<RemoteConfigRepository>(
            FakeRemoteConfigRepository(offlineApi(session)));
        final c = Get.put(OfferController(
          orderId: 63,
          repository: _Offers(),
          session: session,
          clock: () => DateTime.utc(2026, 10, 29, 14),
        ));
        await c.load();
        await _pump(tester, const OfferView(), locale: locale, scale: scale);
        expect(c.viewState.value, OfferViewState.open);
        await _scrollThrough(tester);
        expect(tester.takeException(), isNull);
        Get.delete<OfferController>();
      });

      testWidgets('transfer correction · $locale · text ×$scale',
          (tester) async {
        final session = await signedInSession();
        final api = offlineApi(session);
        final orders = FakeCheckoutRepository()
          ..orderResults.add(Right(orderFromJson(
            id: 62,
            status: 'awaiting_payment',
            method: 'bank_transfer',
            paymentStatus: 'transfer_pending',
            reviewNote: 'صورة الإشعار غير واضحة ولا يظهر المبلغ. '
                'يرجى رفع صورة أوضح تظهر فيها جميع التفاصيل.',
          )));
        final c = Get.put(TransferPaymentController(
          orderId: 62,
          config: FakeRemoteConfigRepository(api),
          session: session,
          getOrder: GetOrderUseCase(orders),
          uploads: FakeUploadRepository(api),
          submitReceipt: SubmitReceiptUseCase(_NoPayments()),
          files: _NoFiles(),
        ));
        await c.load();
        c.receipt.value = SelectedReceipt(
          name: 'receipt-with-a-very-long-file-name-from-the-bank-app.png',
          size: 1234567,
          mime: 'image/png',
          bytes: Uint8List(0),
        );
        await _pump(tester, const TransferPaymentView(),
            locale: locale, scale: scale);
        expect(c.order.value!.needsCorrection, isTrue);
        await _scrollThrough(tester);
        expect(tester.takeException(), isNull);
        Get.delete<TransferPaymentController>();
      });
    }
  }
}
