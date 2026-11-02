import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/models/masar_models.dart';

abstract class DriverAvailableOrdersRepository {
  /// جلب كافة الطلبات المتاحة حالياً للسائق.
  Future<Either<Failure, List<DriverOrder>>> getAvailableOrders();

  /// قبول طلب؛ يرجع الطلب بعد القبول (فيه next_action و تفاصيل المهمة).
  Future<Either<Failure, DriverOrder>> acceptOrder({required String orderId});
}
