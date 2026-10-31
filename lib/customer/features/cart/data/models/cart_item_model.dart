import 'package:project/customer/features/cart/domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.productId,
    required super.name,
    required super.quantity,
    required super.priceLabel,
    super.imageUrl,
    super.options,
  });

  factory CartItemModel.fromEntity(CartItem item) => CartItemModel(
    productId: item.productId,
    name: item.name,
    quantity: item.quantity,
    priceLabel: item.priceLabel,
    imageUrl: item.imageUrl,
    options: item.options,
  );

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    productId: (json['product_id'] as num).toInt(),
    name: json['name'] as String,
    quantity: (json['qty'] as num).toInt(),
    priceLabel: json['price_label'] as String,
    imageUrl: json['image_url'] as String?,
    options: Map<String, String>.from(json['options'] as Map? ?? const {}),
  );

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'name': name,
    'qty': quantity,
    'price_label': priceLabel,
    'image_url': imageUrl,
    'options': options,
  };
}