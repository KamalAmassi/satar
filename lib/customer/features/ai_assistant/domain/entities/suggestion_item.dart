import 'package:equatable/equatable.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';

enum SuggestionStatus {
  /// متوفر بالكمية المطلوبة.
  available,

  /// متوفر بكمية أقل من المطلوبة.
  limited,

  /// موجود لكنه غير متوفر أو الكمية خلصت.
  outOfStock,

  /// ما لقينا منتج مطابق.
  notFound,

  /// طلب طباعة (يُعرض كمعلومة ولا يدخل السلة).
  printJob,
}

/// سطر واحد من الاقتراح: ما طلبه الزبون وما وجدناه له.
class SuggestionItem extends Equatable {
  const SuggestionItem({
    required this.requestText,
    required this.requestedQty,
    required this.quantity,
    required this.status,
    this.product,
    this.alternatives = const [],
  });

  factory SuggestionItem.printJob({required String requestText}) =>
      SuggestionItem(
        requestText: requestText,
        requestedQty: 1,
        quantity: 0,
        status: SuggestionStatus.printJob,
      );

  factory SuggestionItem.resolve({
    required String requestText,
    required int requestedQty,
    SuggestedProduct? product,
    List<SuggestedProduct> alternatives = const [],
  }) {
    if (product == null) {
      return SuggestionItem(
        requestText: requestText,
        requestedQty: requestedQty,
        quantity: 0,
        status: SuggestionStatus.notFound,
      );
    }
    if (!product.isAvailable) {
      return SuggestionItem(
        requestText: requestText,
        requestedQty: requestedQty,
        quantity: 0,
        status: SuggestionStatus.outOfStock,
        product: product,
        alternatives: alternatives,
      );
    }
    final max = product.maxQuantity;
    final limited = requestedQty > max;
    return SuggestionItem(
      requestText: requestText,
      requestedQty: requestedQty,
      quantity: limited ? max : requestedQty,
      status: limited ? SuggestionStatus.limited : SuggestionStatus.available,
      product: product,
      alternatives: alternatives,
    );
  }

  final String requestText;
  final int requestedQty;
  final int quantity;
  final SuggestionStatus status;
  final SuggestedProduct? product;
  final List<SuggestedProduct> alternatives;

  bool get isSelectable =>
      status == SuggestionStatus.available || status == SuggestionStatus.limited;

  int get maxQuantity => product?.maxQuantity ?? 0;

  /// يدخل في السلة؟
  bool get isIncluded => isSelectable && quantity > 0;

  SuggestionItem withQuantity(int value) => SuggestionItem(
    requestText: requestText,
    requestedQty: requestedQty,
    quantity: value.clamp(0, maxQuantity),
    status: status,
    product: product,
    alternatives: alternatives,
  );

  SuggestionItem substitutedWith(SuggestedProduct replacement) =>
      SuggestionItem.resolve(
        requestText: requestText,
        requestedQty: requestedQty,
        product: replacement,
        alternatives:
        alternatives.where((a) => a.id != replacement.id).toList(),
      );

  @override
  List<Object?> get props =>
      [requestText, requestedQty, quantity, status, product, alternatives];
}