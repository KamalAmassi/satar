import 'package:equatable/equatable.dart';

class SuggestedProduct extends Equatable {
  const SuggestedProduct({
    required this.id,
    required this.name,
    required this.priceAmount,
    required this.priceLabel,
    required this.inStock,
    this.imageUrl,
    this.stock,
    this.categoryId,
    this.selectedOptions = const {},
    this.optionLabels = const [],
  });

  final int id;
  final String name;
  final String? imageUrl;

  /// بالأغورة، للمقارنة فقط (لا يُجمع في التطبيق).
  final int priceAmount;
  final String priceLabel;
  final bool inStock;
  final int? stock;
  final int? categoryId;

  /// الخيارات المطلوبة المختارة افتراضياً: مفتاح الخيار ← مفتاح القيمة.
  final Map<String, String> selectedOptions;
  final List<String> optionLabels;

  bool get isAvailable => inStock && (stock == null || stock! > 0);

  /// أقصى كمية يمكن طلبها (سقف 99 عند عدم تحديد مخزون).
  int get maxQuantity {
    if (!isAvailable) return 0;
    final s = stock;
    return s == null || s > 99 ? 99 : s;
  }

  @override
  List<Object?> get props => [id, name, priceAmount, inStock, stock, selectedOptions];
}