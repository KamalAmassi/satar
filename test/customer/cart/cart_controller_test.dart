import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/customer/features/cart/domain/entities/stored_cart.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';
import 'package:project/customer/features/printing/domain/entities/print_spec.dart';

import '../../helpers/purchasing_fakes.dart';

const spec =
    PrintSpec(paperSize: 'a4', color: 'bw', sides: 'single', binding: 'none');

void main() {
  late FakeCartRepository repo;
  late FakeUploadRepository uploads;
  late CartController cart;
  late SessionStore session;

  setUp(() async {
    session = await signedInSession(userId: 1);
    repo = FakeCartRepository();
    uploads = FakeUploadRepository(offlineApi(session));
    cart = CartController(repo, uploads, session);
    await cart.ensureLoaded();
  });

  tearDown(Get.reset);

  group('product identity and options', () {
    test('same product + same options merges quantity', () {
      cart.addProduct(
          const CartItemRequest(productId: 59, quantity: 2, options: {
        'cover_color': ['navy'],
      }));
      cart.addProduct(const CartItemRequest(productId: 59, options: {
        'cover_color': ['navy'],
      }));
      expect(cart.products, hasLength(1));
      expect(cart.products.single.quantity, 3);
    });

    test('different options are separate lines', () {
      cart.addProduct(const CartItemRequest(productId: 59, options: {
        'cover_color': ['navy'],
      }));
      cart.addProduct(const CartItemRequest(productId: 59, options: {
        'cover_color': ['green'],
      }));
      expect(cart.products, hasLength(2));
    });

    test('identity ignores option and choice order', () {
      expect(
        CartProductLine.identityOf(1, {
          'b': ['y', 'x'],
          'a': ['z'],
        }),
        CartProductLine.identityOf(1, {
          'a': ['z'],
          'b': ['x', 'y'],
        }),
      );
    });

    test('changing options into an existing combination merges lines', () {
      cart.addProduct(const CartItemRequest(productId: 59, options: {
        'cover_color': ['navy'],
      }));
      final green = cart.addProduct(const CartItemRequest(
        productId: 59,
        quantity: 2,
        options: {
          'cover_color': ['green'],
        },
      ))!;
      cart.setOptions(green.id, {
        'cover_color': ['navy'],
      });
      expect(cart.products, hasLength(1));
      expect(cart.products.single.quantity, 3);
    });

    test('quantity is clamped to the configured maximum', () {
      final line = cart.addProduct(const CartItemRequest(productId: 60))!;
      cart.setQuantity(line.id, 500, maxQty: 99);
      expect(cart.products.single.quantity, 99);
      cart.setQuantity(line.id, 0, maxQty: 99);
      expect(cart.products.single.quantity, 1);
    });
  });

  test('server field errors land on the right line and file', () {
    final a = cart.addProduct(const CartItemRequest(productId: 59))!;
    final b = cart.addProduct(const CartItemRequest(productId: 60))!;
    cart.applyFieldErrors(
      productIndexToLineId: {0: a.id, 1: b.id},
      printIndexToJobId: const {},
      fieldErrors: {'cart.1.options.size': 'no option size'},
    );
    expect(cart.products.firstWhere((l) => l.id == a.id).fieldErrors, isEmpty);
    expect(
      cart.products.firstWhere((l) => l.id == b.id).fieldErrors,
      {'options.size': 'no option size'},
    );
  });

  test('removeSubmitted keeps lines edited while submission was in flight', () {
    final a = cart.addProduct(const CartItemRequest(productId: 59))!;
    final b = cart.addProduct(const CartItemRequest(productId: 60))!;
    final submitted = {a.id: a.revision, b.id: b.revision};
    cart.setQuantity(b.id, 4); // edited after the snapshot
    cart.removeSubmitted(productRevisions: submitted, printRevisions: const {});
    expect(cart.products.map((l) => l.id), [b.id]);
    expect(cart.products.single.quantity, 4);
  });

  group('print files', () {
    test('each file has its own spec and upload state', () async {
      final one = cart.addPrintFile(
        fileName: 'a.pdf',
        size: 10,
        mime: 'application/pdf',
        bytes: Uint8List(10),
        spec: spec,
      );
      final two = cart.addPrintFile(
        fileName: 'b.pdf',
        size: 10,
        mime: 'application/pdf',
        bytes: Uint8List(10),
        spec: spec,
      );
      cart.updateSpec(two.id, spec.copyWith(color: 'color', copies: 3));
      expect(uploads.purposes, everyElement(UploadPurpose.printFile));

      uploads.pending[0].complete(const Right(
        UploadedFile(uploadId: 38, mime: 'application/pdf', size: 10, pages: 3),
      ));
      await Future<void>.delayed(Duration.zero);

      final a = cart.printJobs.firstWhere((j) => j.id == one.id);
      final b = cart.printJobs.firstWhere((j) => j.id == two.id);
      expect(a.status, UploadStatus.uploaded);
      expect(a.pages, 3);
      expect(a.spec.color, 'bw');
      expect(b.status, UploadStatus.uploading);
      expect(b.spec.color, 'color');
      expect(b.spec.copies, 3);
    });

    test('a failed upload can be retried without adding a second file',
        () async {
      final job = cart.addPrintFile(
        fileName: 'a.pdf',
        size: 10,
        mime: 'application/pdf',
        bytes: Uint8List(10),
        spec: spec,
      );
      uploads.pending.single.complete(const Left(NetworkFailure()));
      await Future<void>.delayed(Duration.zero);
      expect(cart.printJobs.single.status, UploadStatus.failed);

      final retry = cart.retryUpload(job.id);
      expect(cart.printJobs.single.status, UploadStatus.uploading);
      uploads.pending.last.complete(const Right(
        UploadedFile(uploadId: 41, mime: 'application/pdf', size: 10, pages: 2),
      ));
      await retry;
      expect(cart.printJobs, hasLength(1));
      expect(cart.printJobs.single.isUploaded, isTrue);
      expect(cart.printJobs.single.uploadId, 41);
    });

    // Process death while a file is uploading: the confirmed upload comes
    // back as uploaded; the in-flight one comes back as interrupted (never
    // dropped, never uploaded without a server id) and blocks quoting until
    // the customer chooses the file again.
    test('after recreation an in-flight upload is restored as interrupted',
        () async {
      cart.addPrintFile(
        fileName: 'done.pdf',
        size: 10,
        mime: 'application/pdf',
        bytes: Uint8List(10),
        spec: spec,
      );
      cart.addPrintFile(
        fileName: 'in-flight.pdf',
        size: 20,
        mime: 'application/pdf',
        bytes: Uint8List(20),
        spec: spec.copyWith(color: 'color', copies: 2),
      );
      uploads.pending.first.complete(const Right(
        UploadedFile(uploadId: 50, mime: 'application/pdf', size: 10, pages: 1),
      ));
      await Future<void>.delayed(Duration.zero);

      // The real local store persists JSON; the fake keeps objects, so
      // round-trip it the same way before "restarting".
      final json = repo.saved[1]!.toJson();
      expect(json.toString(), isNot(contains('bytes')));
      repo.saved[1] = StoredCart.fromJson(json);
      final recreated = CartController(repo, uploads, session);
      await recreated.ensureLoaded();

      final done =
          recreated.printJobs.firstWhere((j) => j.fileName == 'done.pdf');
      final lost =
          recreated.printJobs.firstWhere((j) => j.fileName == 'in-flight.pdf');
      expect(done.isUploaded, isTrue);
      expect(done.uploadId, 50);
      expect(lost.status, UploadStatus.interrupted);
      expect(lost.isUploaded, isFalse);
      expect(lost.uploadId, isNull);
      expect(lost.spec.copies, 2, reason: 'specs survive');
      expect(recreated.hasInterruptedUploads, isTrue);

      // There are no bytes to retry; the customer must reselect.
      await recreated.retryUpload(lost.id);
      expect(recreated.printJobs.firstWhere((j) => j.id == lost.id).status,
          UploadStatus.interrupted);

      final reselect = recreated.reselectPrintFile(lost.id,
          fileName: 'in-flight.pdf',
          size: 20,
          mime: 'application/pdf',
          bytes: Uint8List(20));
      uploads.pending.last.complete(const Right(
        UploadedFile(uploadId: 51, mime: 'application/pdf', size: 20, pages: 4),
      ));
      await reselect;
      final again = recreated.printJobs.firstWhere((j) => j.id == lost.id);
      expect(recreated.printJobs, hasLength(2), reason: 'no duplicate file');
      expect(again.isUploaded, isTrue);
      expect(again.uploadId, 51);
      expect(again.spec.color, 'color');
      expect(recreated.hasInterruptedUploads, isFalse);
    });

    test('a stored uploaded job without a server id is never shown as uploaded',
        () {
      final restored = StoredCart.fromJson({
        'print_jobs': [
          {
            'status': 'uploaded',
            'id': 'x',
            'file_name': 'a.pdf',
            'size': 1,
            'local_mime': 'application/pdf',
            'upload_id': null,
            'spec': spec.toJson(),
          },
        ],
      });
      expect(restored.printJobs.single.status, UploadStatus.interrupted);
    });

    test('an upload finishing after sign-out never touches the new cart',
        () async {
      cart.addPrintFile(
        fileName: 'a.pdf',
        size: 10,
        mime: 'application/pdf',
        bytes: Uint8List(10),
        spec: spec,
      );
      // A different account signs in on the same device (same session store).
      await session.signOut();
      await session.signIn(token: 'other', userId: 2);
      await cart.ensureLoaded();

      uploads.pending.single.complete(const Right(
        UploadedFile(uploadId: 99, mime: 'application/pdf', size: 10, pages: 1),
      ));
      await Future<void>.delayed(Duration.zero);

      // The new account sees an empty cart and the late upload is ignored.
      expect(cart.printJobs, isEmpty);
      expect(repo.saved[2]?.printJobs ?? const [], isEmpty);
    });
  });

  test('carts are stored per user', () async {
    cart.addProduct(const CartItemRequest(productId: 59));
    await Future<void>.delayed(Duration.zero);
    expect(repo.saved[1]!.products, hasLength(1));
    expect(repo.saved.containsKey(2), isFalse);
  });
}
