import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_address.dart';
import 'package:project/customer/features/checkout/domain/entities/order_submission.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/checkout/domain/entities/quote.dart';
import 'package:project/customer/features/checkout/domain/entities/quote_draft.dart';
import 'package:project/customer/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  CheckoutRepositoryImpl(this._remote, this._prefs);

  final CheckoutRemoteDataSource _remote;
  final SharedPreferences _prefs;

  static String _pendingKey(int userId) =>
      'checkout_pending_submission_$userId';

  @override
  Future<Either<Failure, List<CheckoutAddress>>> addresses() =>
      ErrorHandler.guard(_remote.addresses);

  @override
  Future<Either<Failure, Quote>> quote(QuoteDraft draft) =>
      ErrorHandler.guard(() => _remote.quote(draft));

  @override
  Future<SubmitOutcome> placeOrder(OrderSubmission submission) async {
    try {
      final order = await _remote.placeOrder(
        submission.toBody(),
        submission.idempotencyKey,
      );
      return SubmitCreated(order);
    } on DioException catch (e) {
      return SubmitOutcome.fromFailure(ErrorHandler.fromDio(e));
    } on Failure catch (f) {
      return SubmitOutcome.fromFailure(f);
    } catch (_) {
      // رد غير متوقع: لا يمكن الجزم بعدم إنشاء الطلب.
      return const SubmitUncertain(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, PlacedOrder>> order(int orderId) =>
      ErrorHandler.guard(() => _remote.order(orderId));

  @override
  OrderSubmission? pendingSubmission(int userId) {
    final raw = _prefs.getString(_pendingKey(userId));
    if (raw == null) return null;
    try {
      return OrderSubmission.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePendingSubmission(
    int userId,
    OrderSubmission? submission,
  ) async {
    if (submission == null) {
      await _prefs.remove(_pendingKey(userId));
    } else {
      await _prefs.setString(
        _pendingKey(userId),
        jsonEncode(submission.toJson()),
      );
    }
  }
}
