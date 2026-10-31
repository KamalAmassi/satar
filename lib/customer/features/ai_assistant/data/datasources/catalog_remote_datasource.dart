import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:project/core/network/masar_model/masar_models.dart';

abstract class CatalogRemoteDataSource {
  Future<List<Product>> fetchProducts();
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  CatalogRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// نفس القيمة المستخدمة في Postman (القيم الأكبر قد ترفضها الـ API بـ 422).
  static const _perPage = 20;
  static const _maxPages = 15;

  @override
  Future<List<Product>> fetchProducts() async {
    final all = <Product>[];
    final seen = <int>{};

    for (var page = 1; page <= _maxPages; page++) {
      try {
        final response = await _dio.get<dynamic>(
          '/api/v1/products',
          queryParameters: {
            'per_page': _perPage,
            // الصفحة الأولى بدون page (مطابقة لطلب Postman المضمون).
            if (page > 1) 'page': page,
          },
        );
        final envelope = ApiEnvelope<List<Product>>.fromJson(
          Map<String, dynamic>.from(response.data as Map),
              (data) => (data as List<dynamic>)
              .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList(),
        );

        final batch = envelope.data ?? const <Product>[];
        var added = 0;
        for (final product in batch) {
          if (seen.add(product.id)) {
            all.add(product);
            added++;
          }
        }
        // لا منتجات جديدة = انتهت الصفحات (أو السيرفر تجاهل page).
        if (added == 0) break;
      } on DioException catch (e) {
        if (kDebugMode) {
          debugPrint(
            '[catalog] page=$page status=${e.response?.statusCode} '
                'body=${e.response?.data}',
          );
        }
        // فشلت صفحة لاحقة: نكتفي بما جمعناه بدل ما نفشل كل العملية.
        if (all.isNotEmpty && e.response?.statusCode == 422) break;
        rethrow;
      }
    }
    return all;
  }
}