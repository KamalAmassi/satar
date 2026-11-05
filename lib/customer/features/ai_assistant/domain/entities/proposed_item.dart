import 'package:equatable/equatable.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';

/// صنف مقترح من المحادثة الصوتية؛ لا يدخل السلة قبل تأكيد صريح.
class ProposedItem extends Equatable {
  const ProposedItem({required this.product, required this.quantity, this.selected = true});

  final SuggestedProduct product;
  final int quantity;
  final bool selected;

  static const minQty = 1;
  static const maxQty = 20;

  int get productId => product.id;
  int get lineTotal => product.priceAmount * quantity;

  ProposedItem copyWith({int? quantity, bool? selected}) =>
      ProposedItem(product: product, quantity: (quantity ?? this.quantity).clamp(minQty, maxQty), selected: selected ?? this.selected);

  @override
  List<Object?> get props => [product, quantity, selected];
}
