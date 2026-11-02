import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/driver/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() =>
      ErrorHandler.guard<List<AppNotification>>(() => _remote.list());
}
