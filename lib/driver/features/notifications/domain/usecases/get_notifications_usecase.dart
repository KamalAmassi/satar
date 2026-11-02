import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/shared/driver_models.dart';
import 'package:project/driver/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotificationsUseCase
    implements UseCase<List<AppNotification>, NoParams> {
  const GetNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Either<Failure, List<AppNotification>>> call(NoParams params) =>
      _repository.getNotifications();
}
