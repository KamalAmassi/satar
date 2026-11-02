import 'package:dio/dio.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/utils/money.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_address.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/checkout/domain/entities/quote.dart';
import 'package:project/customer/features/checkout/domain/entities/quote_draft.dart';

abstract class CheckoutRemoteDataSource {
  /// محوّل صغير للقراءة فقط حتى تكتمل ميزة العناوين (محمد).
  Future<List<CheckoutAddress>> addresses();
  Future<Quote> quote(QuoteDraft draft);
  Future<PlacedOrder> placeOrder(Map<String, dynamic> body, String key);
  Future<PlacedOrder> order(int orderId);
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  CheckoutRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<CheckoutAddress>> addresses() async {
    final res = await _api.dio.get<dynamic>('v1/addresses');
    return [
      for (final a in ApiClient.unwrap<List>(res))
        CheckoutAddress.fromJson(Map<String, dynamic>.from(a as Map)),
    ];
  }

  @override
  Future<Quote> quote(QuoteDraft draft) async {
    final res =
        await _api.dio.post<dynamic>('v1/orders/quote', data: draft.body);
    final d = ApiClient.unwrapMap(res);
    return Quote(
      token: d['quote_token'] as String,
      expiresIn: d['expires_in'] as int? ?? 0,
      expiresAt: DateTime.tryParse('${d['expires_at']}'),
      receivedAt: DateTime.now(),
      breakdown: [
        for (final l in d['breakdown'] as List? ?? const [])
          PriceLine(
            key: (l as Map)['key'] as String? ?? '',
            kind: l['kind'] as String? ?? '',
            label: l['label'] as String? ?? '',
            amount: Money(
              amount: l['amount'] as int? ?? 0,
              formatted: l['formatted'] as String?,
            ),
          ),
      ],
      itemsTotal: Money.fromJson(d['items_total']),
      deliveryFee: Money.fromJson(d['delivery_fee']),
      discount: Money.fromJson(d['discount']),
      total: Money.fromJson(d['total']),
      paymentMethod: d['payment_method'] as String? ?? '',
      configVersion: d['config_version'] as int? ?? 0,
      distanceKm: (d['distance_km'] as num?)?.toDouble(),
      fingerprint: draft.fingerprint,
    );
  }

  @override
  Future<PlacedOrder> placeOrder(Map<String, dynamic> body, String key) async {
    final res = await _api.dio.post<dynamic>(
      'v1/orders',
      data: body,
      options: Options(headers: {'Idempotency-Key': key}),
    );
    return PlacedOrder.fromJson(ApiClient.unwrapMap(res));
  }

  @override
  Future<PlacedOrder> order(int orderId) async {
    final res = await _api.dio.get<dynamic>('v1/orders/$orderId');
    return PlacedOrder.fromJson(ApiClient.unwrapMap(res));
  }
}
