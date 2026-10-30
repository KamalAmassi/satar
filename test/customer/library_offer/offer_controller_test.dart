import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/library_offer/domain/entities/library_offer.dart';
import 'package:project/customer/features/library_offer/domain/repositories/offer_repository.dart';
import 'package:project/customer/features/library_offer/presentation/controllers/offer_controller.dart';

import '../../helpers/purchasing_fakes.dart';

Map<String, dynamic> offerJson({
  int id = 23,
  String status = 'sent',
  bool substitute = false,
  String expires = '2026-10-29T14:38:03+00:00',
}) =>
    {
      'id': id,
      'order_id': 63,
      'status': status,
      'items': [
        {
          'id': 1,
          'name': 'Notebook navy',
          'qty': 1,
          'unit_price': {'amount': 800},
          'available': !substitute,
          'substitute': substitute
              ? {
                  'name': 'Notebook green',
                  'unit_price': {'amount': 900},
                }
              : null,
          'line_total': {'amount': 800},
          'note': null,
        },
      ],
      'items_total': {'amount': 800},
      'delivery_fee': {'amount': 2300},
      'total': {'amount': 3100},
      'note': 'Priced by the library',
      'expires_at': expires,
      'created_at': '2026-10-29T13:38:03+00:00',
    };

class _Offers implements OfferRepository {
  final List<Either<Failure, LibraryOffer>> gets = [];
  final List<Either<Failure, LibraryOffer>> approves = [];
  final List<String> approveKeys = [];

  @override
  Future<Either<Failure, LibraryOffer>> offer(int orderId) async =>
      gets.length == 1 ? gets.first : gets.removeAt(0);

  @override
  Future<Either<Failure, LibraryOffer>> approve(int orderId, String key) async {
    approveKeys.add(key);
    return approves.removeAt(0);
  }

  @override
  Future<Either<Failure, LibraryOffer>> reject(int orderId,
          {String? reason}) async =>
      Right(LibraryOffer.fromJson(offerJson(status: 'rejected')));
}

void main() {
  late _Offers repo;
  late DateTime now;

  Future<OfferController> make() async {
    final session = await signedInSession();
    final c = Get.put(OfferController(
      orderId: 63,
      repository: repo,
      session: session,
      clock: () => now,
    ));
    await c.load();
    return c;
  }

  setUp(() {
    repo = _Offers();
    now = DateTime.utc(2026, 10, 29, 14);
  });

  tearDown(Get.reset);

  test('no offer yet is its own state', () async {
    repo.gets.add(const Left(ServerFailure(
      code: ApiErrorCodes.notFound,
      statusCode: 404,
      details: {'reason': 'no_offer_yet'},
    )));
    final c = await make();
    expect(c.viewState.value, OfferViewState.notReady);
  });

  test('substitutions need explicit consent; price difference is shown',
      () async {
    repo.gets.add(Right(LibraryOffer.fromJson(offerJson(substitute: true))));
    final c = await make();
    expect(c.viewState.value, OfferViewState.open);
    expect(c.offer.value!.items.single.substituteDifference!.amount, 100);
    expect(c.canApprove, isFalse);
    c.substitutionsAccepted.value = true;
    expect(c.canApprove, isTrue);
  });

  test('an expired offer cannot be approved', () async {
    repo.gets.add(Right(LibraryOffer.fromJson(offerJson())));
    now = DateTime.utc(2026, 10, 29, 15);
    final c = await make();
    expect(c.viewState.value, OfferViewState.expired);
    expect(c.canApprove, isFalse);
  });

  test('a concurrently decided offer refreshes and shows the change', () async {
    repo.gets.add(Right(LibraryOffer.fromJson(offerJson())));
    final c = await make();
    repo.approves.add(const Left(ServerFailure(
      code: ApiErrorCodes.invalidTransition,
      statusCode: 422,
      details: {'reason': 'no_open_offer'},
    )));
    repo.gets
      ..clear()
      ..add(Right(LibraryOffer.fromJson(offerJson(id: 24))));
    await c.approve();
    expect(c.viewState.value, OfferViewState.changed);
  });

  test('approval retries reuse the same idempotency key for the same offer',
      () async {
    repo.gets.add(Right(LibraryOffer.fromJson(offerJson())));
    final c = await make();
    repo.approves
      ..add(const Left(NetworkFailure()))
      ..add(Right(LibraryOffer.fromJson(offerJson(status: 'approved'))));
    await c.approve();
    await c.approve();
    expect(repo.approveKeys, hasLength(2));
    expect(repo.approveKeys[0], repo.approveKeys[1]);
    expect(c.viewState.value, OfferViewState.approved);
  });

  // Reproduces the live sandbox case (STR-000025): the library re-priced
  // while the customer had the old offer open. POST /offer/approve has no
  // offer id, so approving must not be sent for contents the customer did
  // not see.
  test('a revised offer is shown for review instead of being approved',
      () async {
    repo.gets.add(Right(LibraryOffer.fromJson(offerJson(id: 25))));
    final c = await make();
    final revised = offerJson(id: 26)
      ..['delivery_fee'] = {'amount': 2500}
      ..['total'] = {'amount': 3300};
    repo.gets
      ..clear()
      ..add(Right(LibraryOffer.fromJson(revised)));

    await c.approve();

    expect(repo.approveKeys, isEmpty, reason: 'approve must not be sent');
    expect(c.viewState.value, OfferViewState.changed);
    expect(c.offer.value!.id, 26);
    expect(c.offer.value!.total.amount, 3300);
  });

  test('quiet refresh moves from waiting to the offer, then flags revisions',
      () async {
    repo.gets.add(const Left(ServerFailure(
      code: ApiErrorCodes.notFound,
      statusCode: 404,
      details: {'reason': 'no_offer_yet'},
    )));
    final c = await make();
    expect(c.viewState.value, OfferViewState.notReady);

    repo.gets
      ..clear()
      ..add(Right(LibraryOffer.fromJson(offerJson(id: 30))));
    await c.refreshQuietly();
    expect(c.viewState.value, OfferViewState.open);

    repo.gets
      ..clear()
      ..add(Right(LibraryOffer.fromJson(offerJson(id: 31))));
    await c.refreshQuietly();
    expect(c.viewState.value, OfferViewState.changed);
    expect(c.offer.value!.id, 31);
  });
}
