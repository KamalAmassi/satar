import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/data/models.dart';
import 'package:project/driver/features/orders/presentation/deliver_order.dart';

DriverOrderModel _order({int id = 7, String status = 'arrived'}) => DriverOrderModel.fromJson({
      'id': id,
      'code': 'ORD-$id',
      'status': {'key': status, 'label': status},
      'earning': {'amount': 1500},
    });

void main() {
  late List<String?> sentOtps;
  late Either<Failure, DriverOrderModel?> deliverResult;
  late Either<Failure, DriverOrderModel?> currentResult;

  DeliverOrderUseCase useCase() => DeliverOrderUseCase(
        deliver: (id, {otp, uploadIds, required key}) async {
          sentOtps.add(otp);
          return deliverResult;
        },
        current: () async => currentResult,
      );

  setUp(() {
    sentOtps = [];
    currentResult = Right(_order());
  });

  test('success returns the delivered order', () async {
    deliverResult = Right(_order(status: 'delivered'));
    final r = await useCase()(order: _order(), otp: '482913', key: 'k');
    expect(r.isRight(), isTrue);
    expect(r.getOrElse(() => _order()).status.key, 'delivered');
    expect(sentOtps, ['482913']);
  });

  test('success without an order in data falls back to the known order', () async {
    deliverResult = const Right(null);
    final r = await useCase()(order: _order(), otp: '4829', key: 'k');
    expect(r.getOrElse(() => _order(id: 0)).id, 7);
  });

  test('422 from the server maps to DeliveryCodeInvalid', () async {
    deliverResult = const Left(ValidationFailure(fieldErrors: {'otp': 'invalid'}));
    final r = await useCase()(order: _order(), otp: '1111', key: 'k');
    expect(r.fold((f) => f, (_) => null), isA<DeliveryCodeInvalid>());
  });

  test('malformed code is rejected locally without calling the server', () async {
    deliverResult = Right(_order());
    for (final bad in ['123', '123456789', '12a4', '']) {
      final r = await useCase()(order: _order(), otp: bad, key: 'k');
      expect(r.fold((f) => f, (_) => null), isA<DeliveryCodeInvalid>(), reason: bad);
    }
    expect(sentOtps, isEmpty);
  });

  test('429 maps to DeliveryTooManyAttempts', () async {
    deliverResult = const Left(ServerFailure(code: ApiErrorCodes.tooManyRequests, statusCode: 429));
    final r = await useCase()(order: _order(), otp: '1234', key: 'k');
    expect(r.fold((f) => f, (_) => null), isA<DeliveryTooManyAttempts>());
  });

  test('invalid state while the order is still current stays an error', () async {
    deliverResult = const Left(ServerFailure(code: ApiErrorCodes.invalidTransition, statusCode: 422));
    final r = await useCase()(order: _order(), otp: '1234', key: 'k');
    expect(r.fold((f) => f, (_) => null), isA<DeliveryInvalidState>());
  });

  test('invalid state but the task is already closed counts as success', () async {
    deliverResult = const Left(ServerFailure(code: ApiErrorCodes.conflict, statusCode: 409));
    currentResult = const Right(null);
    final r = await useCase()(order: _order(), otp: '1234', key: 'k');
    expect(r.isRight(), isTrue);
  });

  test('network failure passes through unchanged', () async {
    deliverResult = const Left(NetworkFailure());
    final r = await useCase()(order: _order(), otp: '1234', key: 'k');
    expect(r.fold((f) => f, (_) => null), isA<NetworkFailure>());
  });

  test('DriverOrderModel parses actions[] next to next_action', () {
    final o = DriverOrderModel.fromJson({
      'id': 1,
      'code': 'X',
      'status': {'key': 'arrived'},
      'next_action': {'action': 'transition', 'to': 'delivery_failed', 'label': 'تعذّر التسليم', 'style': 'danger'},
      'actions': [
        {'action': 'deliver', 'label': 'تسليم الطلب', 'style': 'primary'},
        'junk',
      ],
    });
    expect(o.nextAction!.to, 'delivery_failed');
    expect(o.actions.map((a) => a.action), ['deliver']);
  });
}
