import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/library_offer/domain/entities/library_offer.dart';

abstract class OfferRepository {
  /// 404 not_found (reason: no_offer_yet) حتى تسعّر المكتبة الطلب.
  Future<Either<Failure, LibraryOffer>> offer(int orderId);

  /// [offerId] هو العرض الذي رآه الزبون. الخادم يرفض الموافقة بـ
  /// 409 conflict (reason: offer_changed) إن لم يعد هو العرض الحالي.
  Future<Either<Failure, LibraryOffer>> approve(
      int orderId, int offerId, String key);
  Future<Either<Failure, LibraryOffer>> reject(int orderId,
      {int? offerId, String? reason});
}
