import 'package:project/customer/features/orders/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.status,
    required super.statusLabel,
    required super.itemsCount,
    required super.date,
    required super.price,
    required super.actionLabel,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      itemsCount: json['items_count']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      actionLabel: json['action_label']?.toString() ?? 'عرض التفاصيل',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'status_label': statusLabel,
      'items_count': itemsCount,
      'date': date,
      'price': price,
      'action_label': actionLabel,
    };
  }
}
