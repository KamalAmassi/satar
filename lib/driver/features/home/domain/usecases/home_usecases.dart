import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/models/masar_models.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/driver/features/home/domain/repositories/driver_home_repository.dart';

class GetDriverProfileUseCase implements UseCase<Driver, NoParams> {
  GetDriverProfileUseCase({required this.repository});

  final DriverHomeRepository repository;

  @override
  Future<Either<Failure, Driver>> call(NoParams params) => repository.getProfile();
}

class SetOnlineStatusParams {
  SetOnlineStatusParams({required this.online});

  final bool online;
}

class SetOnlineStatusUseCase implements UseCase<bool, SetOnlineStatusParams> {
  SetOnlineStatusUseCase({required this.repository});

  final DriverHomeRepository repository;

  @override
  Future<Either<Failure, bool>> call(SetOnlineStatusParams params) =>
      repository.setOnline(online: params.online);
}

class SendLocationParams {
  SendLocationParams({required this.lat, required this.lng, this.accuracy});

  final double lat;
  final double lng;
  final double? accuracy;
}

class SendLocationUseCase implements UseCase<bool, SendLocationParams> {
  SendLocationUseCase({required this.repository});

  final DriverHomeRepository repository;

  @override
  Future<Either<Failure, bool>> call(SendLocationParams p) =>
      repository.sendLocation(lat: p.lat, lng: p.lng, accuracy: p.accuracy);
}
