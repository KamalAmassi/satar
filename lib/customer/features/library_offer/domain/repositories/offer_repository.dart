import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/library_offer/domain/entities/library_offer.dart';

abstract class OfferRepository {
  /// 404 not_found (reason: no_offer_yet) حتى تسعّر المكتبة الطلب.
  Future<Either<Failure, LibraryOffer>> offer(int orderId);
  Future<Either<Failure, LibraryOffer>> approve(int orderId, String key);
  Future<Either<Failure, LibraryOffer>> reject(int orderId, {String? reason});
}
