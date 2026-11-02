import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/uploads/picked_file.dart';
import 'package:project/customer/features/cart/domain/entities/stored_cart.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_details.dart';
import 'package:project/customer/features/checkout/domain/entities/quote_draft.dart';
import 'package:project/customer/features/printing/domain/entities/file_check.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';
import 'package:project/customer/features/printing/presentation/controllers/printing_controller.dart';

import '../../helpers/purchasing_fakes.dart';

final _pdf = Uint8List.fromList('%PDF-1.4\n%fake but signed\n'.codeUnits);

class _Files implements FileSource {
  _Files(this.files);
  final List<PickedFile> files;

  @override
  Future<List<PickedFile>> pick({required bool multiple}) async => files;
}

PickedFile _file(String name, {int? size, Uint8List? bytes}) {
  final b = bytes ?? _pdf;
  var reads = 0;
  return PickedFile(
    name: name,
    size: size ?? b.length,
    readBytes: () async {
      reads++;
      if (size != null && size > 10 * 1024 * 1024) {
        fail('$name ($reads) is too large and must not be read');
      }
      return b;
    },
  );
}

void main() {
  late CartController cart;

  Future<PrintingController> make(List<PickedFile> files) async {
    final session = await signedInSession();
    final api = offlineApi(session);
    cart = CartController(
        FakeCartRepository(), FakeUploadRepository(api), session);
    final c = PrintingController(
      cart: cart,
      config: FakeRemoteConfigRepository(api),
      session: session,
      files: _Files(files),
    );
    await c.load();
    return c;
  }

  tearDown(Get.reset);

  test('the configured file limit stops adding and shows the limit state',
      () async {
    final c = await make([for (var i = 0; i < 22; i++) _file('f$i.pdf')]);
    expect(c.maxJobs, 20);
    await c.pickFiles();
    expect(cart.printJobs, hasLength(20));
    expect(c.limitReached.value, isTrue);

    c.dismissLimit();
    await c.pickFiles();
    expect(cart.printJobs, hasLength(20), reason: 'no slots left');
    expect(c.limitReached.value, isTrue);
  });

  test('oversize and unsupported files are rejected, valid ones still added',
      () async {
    final c = await make([
      _file('big.pdf', size: 11 * 1024 * 1024),
      _file('not-really.pdf', bytes: Uint8List.fromList('just text'.codeUnits)),
      _file('ok.pdf'),
    ]);
    await c.pickFiles();
    expect(c.rejected.map((r) => (r.name, r.reason)), [
      ('big.pdf', FileRejection.tooLarge),
      ('not-really.pdf', FileRejection.unsupportedType),
    ]);
    expect(cart.printJobs.map((j) => j.fileName), ['ok.pdf']);
  });

  test('cancelling the picker changes nothing', () async {
    final c = await make(const []);
    await c.pickFiles();
    expect(cart.printJobs, isEmpty);
    expect(c.rejected, isEmpty);
    expect(c.picking.value, isFalse);
  });

  group('interrupted upload after process death', () {
    Future<PrintingController> withInterrupted(List<PickedFile> files) async {
      final session = await signedInSession();
      final api = offlineApi(session);
      final repo = FakeCartRepository();
      final first = CartController(repo, FakeUploadRepository(api), session);
      await first.ensureLoaded();
      first.addPrintFile(
        fileName: 'thesis.pdf',
        size: _pdf.length,
        mime: 'application/pdf',
        bytes: _pdf,
        spec: CartController.defaultSpec(testConfig().printing!),
      );
      // "Restart": JSON round trip, then a fresh controller.
      repo.saved[1] = StoredCart.fromJson(repo.saved[1]!.toJson());
      cart = CartController(repo, FakeUploadRepository(api), session);
      final c = PrintingController(
        cart: cart,
        config: FakeRemoteConfigRepository(api),
        session: session,
        files: _Files(files),
      );
      await c.load();
      return c;
    }

    test('blocks quoting until the file is chosen again', () async {
      await withInterrupted(const []);
      final (draft, blockers) = QuoteDraft.build(
        products: const [],
        printJobs: cart.printJobs.toList(),
        substitutionPreference: null,
        details: const CheckoutDetails(
            addressId: 1, paymentMethod: PaymentMethod.cash),
      );
      expect(draft, isNull);
      expect(blockers, contains(DraftBlocker.uploadsFailed));
    });

    test('reselect checks the new file like any other and re-uploads it',
        () async {
      final c = await withInterrupted([_file('thesis.pdf')]);
      final id = cart.printJobs.single.id;
      expect(cart.printJobs.single.status, UploadStatus.interrupted);
      await c.reselect(id);
      expect(cart.printJobs.single.id, id);
      expect(cart.printJobs.single.status, UploadStatus.uploading);
    });

    test('an unsupported reselected file is rejected and stays interrupted',
        () async {
      final c = await withInterrupted([
        _file('thesis.pdf', bytes: Uint8List.fromList('text'.codeUnits)),
      ]);
      await c.reselect(cart.printJobs.single.id);
      expect(c.rejected.single.reason, FileRejection.unsupportedType);
      expect(cart.printJobs.single.status, UploadStatus.interrupted);
    });
  });
}
