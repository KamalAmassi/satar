import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/library_offer/data/datasources/offer_remote_datasource.dart';
import 'package:project/customer/features/library_offer/domain/entities/library_offer.dart';
import 'package:project/customer/features/library_offer/domain/repositories/offer_repository.dart';

class OfferRepositoryImpl implements OfferRepository {
  OfferRepositoryImpl(this._remote);

  final OfferRemoteDataSource _remote;

  @override
  Future<Either<Failure, LibraryOffer>> offer(int orderId) =>
      ErrorHandler.guard(() => _remote.offer(orderId));

  @override
  Future<Either<Failure, LibraryOffer>> approve(
          int orderId, int offerId, String key) =>
      ErrorHandler.guard(() => _remote.approve(orderId, offerId, key));

  @override
  Future<Either<Failure, LibraryOffer>> reject(int orderId,
          {int? offerId, String? reason}) =>
      ErrorHandler.guard(() => _remote.reject(orderId, offerId, reason));
}
