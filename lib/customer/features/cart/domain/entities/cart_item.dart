import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.priceLabel,
    this.imageUrl,
    this.options = const {},
  });

  final int productId;
  final String name;
  final int quantity;

  /// سعر الوحدة كما وصل من السيرفر (للعرض فقط).
  final String priceLabel;
  final String? imageUrl;

  /// الخيارات المختارة: مفتاح الخيار ← مفتاح القيمة.
  final Map<String, String> options;

  /// نفس المنتج بنفس الخيارات = نفس السطر.
  String get lineKey {
    final entries = options.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return '$productId|${entries.map((e) => '${e.key}=${e.value}').join(',')}';
  }

  CartItem copyWith({int? quantity}) => CartItem(
    productId: productId,
    name: name,
    quantity: quantity ?? this.quantity,
    priceLabel: priceLabel,
    imageUrl: imageUrl,
    options: options,
  );

  @override
  List<Object?> get props =>
      [productId, name, quantity, priceLabel, imageUrl, options];
}