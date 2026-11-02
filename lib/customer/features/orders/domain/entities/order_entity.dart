class OrderEntity {
  final String id;
  final String status;
  final String statusLabel;
  final String itemsCount;
  final String date;
  final String price;
  final String actionLabel;

  const OrderEntity({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.itemsCount,
    required this.date,
    required this.price,
    required this.actionLabel,
  });
}
