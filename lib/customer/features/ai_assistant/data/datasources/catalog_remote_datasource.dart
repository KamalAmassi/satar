import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:project/core/network/masar_model/masar_models.dart';

abstract class CatalogRemoteDataSource {
  Future<List<Product>> fetchProducts();

  /// بحث على الخادم (?q= يطابق الاسمين العربي والإنجليزي، حتى 60 حرفًا). المصدر الأساسي للمطابقة.
  Future<List<Product>> search(String q);

  /// أسماء الفئات (id ← اسم) لدعم المطابقة؛ تُرجع خريطة فارغة إن تعذّر الجلب.
  Future<Map<int, String>> fetchCategories();
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  CatalogRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// نفس القيمة المستخدمة في Postman (القيم الأكبر قد ترفضها الـ API بـ 422).
  static const _perPage = 50; // الحد الأقصى في العقد؛ المطابقة تحتاج الكتالوج كاملًا
  static const _maxPages = 20;

  @override
  Future<Map<int, String>> fetchCategories() async {
    try {
      final response = await _dio.get<dynamic>('v1/categories');
      final envelope = ApiEnvelope<List<Category>>.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        (data) => (data as List<dynamic>)
            .map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
      return {for (final c in envelope.data ?? const <Category>[]) c.id: c.name};
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<List<Product>> search(String q) async {
    final query = q.trim();
    if (query.isEmpty) return const [];
    final response = await _dio.get<dynamic>(
      'v1/products',
      queryParameters: {'q': query.length > 60 ? query.substring(0, 60) : query, 'per_page': 30},
    );
    final envelope = ApiEnvelope<List<Product>>.fromJson(
      Map<String, dynamic>.from(response.data as Map),
      (data) => (data as List<dynamic>)
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
    return envelope.data ?? const <Product>[];
  }

  @override
  Future<List<Product>> fetchProducts() async {
    final all = <Product>[];
    final seen = <int>{};

    for (var page = 1; page <= _maxPages; page++) {
      try {
        final response = await _dio.get<dynamic>(
          'v1/products',
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