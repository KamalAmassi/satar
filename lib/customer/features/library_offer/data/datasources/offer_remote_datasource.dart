import 'package:dio/dio.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/customer/features/library_offer/domain/entities/library_offer.dart';

abstract class OfferRemoteDataSource {
  Future<LibraryOffer> offer(int orderId);
  Future<LibraryOffer> approve(int orderId, String key);
  Future<LibraryOffer> reject(int orderId, String? reason);
}

class OfferRemoteDataSourceImpl implements OfferRemoteDataSource {
  OfferRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<LibraryOffer> offer(int orderId) async {
    final res = await _api.dio.get<dynamic>('v1/orders/$orderId/offer');
    return LibraryOffer.fromJson(ApiClient.unwrapMap(res));
  }

  @override
  Future<LibraryOffer> approve(int orderId, String key) async {
    final res = await _api.dio.post<dynamic>(
      'v1/orders/$orderId/offer/approve',
      data: const <String, dynamic>{},
      options: Options(headers: {'Idempotency-Key': key}),
    );
    return LibraryOffer.fromJson(ApiClient.unwrapMap(res));
  }

  @override
  Future<LibraryOffer> reject(int orderId, String? reason) async {
    final res = await _api.dio.post<dynamic>(
      'v1/orders/$orderId/offer/reject',
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
    return LibraryOffer.fromJson(ApiClient.unwrapMap(res));
  }
}
