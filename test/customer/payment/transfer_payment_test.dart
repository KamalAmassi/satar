import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/uploads/picked_file.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/checkout/domain/usecases/get_order_usecase.dart';
import 'package:project/customer/features/payment/domain/repositories/payment_repository.dart';
import 'package:project/customer/features/payment/domain/usecases/submit_receipt_usecase.dart';
import 'package:project/customer/features/payment/presentation/controllers/transfer_payment_controller.dart';
import 'package:project/customer/features/printing/domain/entities/file_check.dart';

import '../../helpers/purchasing_fakes.dart';

final _png = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  1
]);

class _Files implements FileSource {
  _Files(this.files);
  final List<PickedFile> files;

  @override
  Future<List<PickedFile>> pick({required bool multiple}) async => files;
}

class _Payments implements PaymentRepository {
  final List<Either<Failure, PlacedOrder>> results = [];
  final List<(int, String)> calls = [];

  @override
  Future<Either<Failure, PlacedOrder>> submitReceipt({
    required int orderId,
    required int uploadId,
    required String idempotencyKey,
  }) async {
    calls.add((uploadId, idempotencyKey));
    return results.removeAt(0);
  }
}

void main() {
  group('receipt eligibility from the order state', () {
    test('only a transfer order awaiting payment may submit', () {
      expect(
          orderFromJson(status: 'awaiting_payment', method: 'bank_transfer')
              .canSubmitReceipt,
          isTrue);
      expect(
          orderFromJson(status: 'payment_review', method: 'bank_transfer')
              .canSubmitReceipt,
          isFalse);
      expect(
          orderFromJson(status: 'pending', method: 'bank_transfer')
              .canSubmitReceipt,
          isFalse);
      expect(
          orderFromJson(status: 'awaiting_payment', method: 'cash')
              .canSubmitReceipt,
          isFalse);
    });

    test('a library review note means correction and resubmission', () {
      final o = orderFromJson(
        status: 'awaiting_payment',
        method: 'bank_transfer',
        reviewNote: 'The amount is not visible',
      );
      expect(o.needsCorrection, isTrue);
      expect(o.reviewNote, 'The amount is not visible');
    });
  });

  group('TransferPaymentController', () {
    late FakeCheckoutRepository orders;
    late FakeUploadRepository uploads;
    late _Payments payments;
    late TransferPaymentController c;

    setUp(() async {
      final session = await signedInSession();
      final api = offlineApi(session);
      orders = FakeCheckoutRepository()
        ..orderResults.add(Right(orderFromJson(
          id: 62,
          status: 'awaiting_payment',
          method: 'bank_transfer',
          paymentStatus: 'transfer_pending',
        )));
      uploads = FakeUploadRepository(api);
      payments = _Payments();
      c = Get.put(TransferPaymentController(
        orderId: 62,
        config: FakeRemoteConfigRepository(api),
        session: session,
        getOrder: GetOrderUseCase(orders),
        uploads: uploads,
        submitReceipt: SubmitReceiptUseCase(payments),
        files: _Files([
          PickedFile(
              name: 'receipt.png',
              size: _png.length,
              readBytes: () async => _png),
        ]),
      ));
      await c.load();
    });

    tearDown(Get.reset);

    test('uploads with the receipt purpose and reuses key + upload on retry',
        () async {
      await c.pickReceipt();
      expect(c.canSubmit, isTrue);

      payments.results.add(const Left(NetworkFailure()));
      final first = c.submit();
      await Future<void>.delayed(Duration.zero);
      uploads.pending.single.complete(const Right(
        UploadedFile(
            uploadId: 45,
            mime: 'image/webp',
            size: 86,
            purpose: 'payment_receipt'),
      ));
      await first;
      expect(uploads.purposes, [UploadPurpose.paymentReceipt]);
      expect(c.submitFailure.value, isA<NetworkFailure>());

      payments.results.add(Right(orderFromJson(
        id: 62,
        status: 'payment_review',
        method: 'bank_transfer',
        paymentStatus: 'transfer_review',
      )));
      await c.submit();
      expect(uploads.pending, hasLength(1), reason: 'no second upload');
      expect(payments.calls[0].$1, 45);
      expect(payments.calls[1], payments.calls[0],
          reason: 'same upload id and key');
      expect(c.order.value!.isReceiptUnderReview, isTrue);
      expect(c.receipt.value, isNull);
    });

    test('quiet refresh picks up the library correction note', () async {
      orders.orderResults
        ..clear()
        ..add(Right(orderFromJson(
          id: 62,
          status: 'awaiting_payment',
          method: 'bank_transfer',
          paymentStatus: 'transfer_pending',
          reviewNote: 'The amount is not readable',
        )));
      await c.refreshQuietly();
      expect(c.order.value!.needsCorrection, isTrue);
      expect(c.order.value!.reviewNote, 'The amount is not readable');
    });

    test('invalid_transition refreshes the order instead of guessing',
        () async {
      await c.pickReceipt();
      payments.results.add(const Left(ServerFailure(
        code: ApiErrorCodes.invalidTransition,
        statusCode: 422,
        details: {'from': 'payment_review', 'to': 'payment_review'},
      )));
      final calls = orders.orderCalls;
      final future = c.submit();
      await Future<void>.delayed(Duration.zero);
      uploads.pending.single.complete(const Right(
        UploadedFile(uploadId: 46, mime: 'image/webp', size: 86),
      ));
      await future;
      expect(c.stateChanged.value, isTrue);
      expect(orders.orderCalls, greaterThan(calls));
    });

    test('rejects a receipt that is not an allowed type', () async {
      Get.reset();
      final session = await signedInSession();
      final api = offlineApi(session);
      final bad = TransferPaymentController(
        orderId: 62,
        config: FakeRemoteConfigRepository(api),
        session: session,
        getOrder: GetOrderUseCase(orders),
        uploads: uploads,
        submitReceipt: SubmitReceiptUseCase(payments),
        files: _Files([
          PickedFile(
            name: 'receipt.pdf',
            size: 10,
            readBytes: () async =>
                Uint8List.fromList('not really a pdf'.codeUnits),
          ),
        ]),
      );
      await bad.load();
      await bad.pickReceipt();
      expect(bad.rejection.value, FileRejection.unsupportedType);
      expect(bad.receipt.value, isNull);
    });
  });
}
