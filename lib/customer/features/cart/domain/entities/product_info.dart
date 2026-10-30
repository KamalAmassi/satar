import 'package:equatable/equatable.dart';
import 'package:project/core/utils/money.dart';

/// بيانات عرض المنتج في السلة (قراءة فقط من GET /v1/products/{id}).
/// الأسعار هنا للعرض؛ لا تُرسل إلى الخادم أبدًا.
class ProductInfo extends Equatable {
  const ProductInfo({
    required this.id,
    required this.name,
    required this.price,
    required this.inStock,
    required this.priceMode,
    this.imageUrl,
    this.stock,
    this.options = const [],
  });

  final int id;
  final String name;
  final Money price;
  final bool inStock;
  final int? stock;

  /// fixed أو inspection (يسعّرها المشغّل).
  final String priceMode;
  final String? imageUrl;
  final List<ProductOptionInfo> options;

  bool get isInspectionPriced => priceMode == 'inspection';

  ProductOptionInfo? option(String key) =>
      options.where((o) => o.key == key).firstOrNull;

  factory ProductInfo.fromJson(Map<String, dynamic> json) => ProductInfo(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        price: Money.fromJson(json['price']),
        inStock: json['in_stock'] as bool? ?? true,
        stock: json['stock'] as int?,
        priceMode: json['price_mode'] as String? ?? 'fixed',
        imageUrl: json['image_url'] as String?,
        options: [
          for (final o in json['options'] as List? ?? const [])
            ProductOptionInfo.fromJson(Map<String, dynamic>.from(o as Map)),
        ],
      );

  @override
  List<Object?> get props =>
      [id, name, price, inStock, stock, priceMode, options];
}

class ProductOptionInfo extends Equatable {
  const ProductOptionInfo({
    required this.key,
    required this.label,
    required this.multi,
    required this.required,
    required this.choices,
  });

  final String key;
  final String label;
  final bool multi;
  final bool required;
  final List<ProductChoiceInfo> choices;

  factory ProductOptionInfo.fromJson(Map<String, dynamic> json) =>
      ProductOptionInfo(
        key: json['key'] as String,
        label: json['label'] as String? ?? json['key'] as String,
        multi: json['type'] == 'multi',
        required: json['required'] as bool? ?? false,
        choices: [
          for (final c in json['choices'] as List? ?? const [])
            ProductChoiceInfo(
              key: (c as Map)['key'] as String,
              label: c['label'] as String? ?? c['key'] as String,
              price: Money.fromJson(c['price']),
            ),
        ],
      );

  @override
  List<Object?> get props => [key, label, multi, required, choices];
}

class ProductChoiceInfo extends Equatable {
  const ProductChoiceInfo({
    required this.key,
    required this.label,
    required this.price,
  });

  final String key;
  final String label;
  final Money price;

  @override
  List<Object?> get props => [key, label, price];
}
