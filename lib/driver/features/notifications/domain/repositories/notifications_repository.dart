import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/shared/driver_models.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();
}
