import 'package:equatable/equatable.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';
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
    this.level = MatchLevel.exact,
    this.note,
    this.close = const [],
    this.similar = const [],
    this.role = '',
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
    MatchLevel level = MatchLevel.exact,
    MatchNote? note,
    List<MatchedProduct> close = const [],
    List<MatchedProduct> similar = const [],
    String role = '',
  }) {
    if (product == null) {
      return SuggestionItem(
        requestText: requestText,
        requestedQty: requestedQty,
        quantity: 0,
        status: SuggestionStatus.notFound,
        close: close,
        similar: similar,
        role: role,
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
        level: level,
        note: note,
        close: close,
        similar: similar,
        role: role,
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
      level: level,
      note: note,
      close: close,
      similar: similar,
      role: role,
    );
  }

  final String requestText;
  final int requestedQty;
  final int quantity;
  final SuggestionStatus status;
  final SuggestedProduct? product;

  /// بدائل مطابقة تمامًا (للاستبدال عند عدم التوفر).
  final List<SuggestedProduct> alternatives;

  /// مستوى مطابقة [product] وسببه إن لم يكن exact.
  final MatchLevel level;
  final MatchNote? note;

  /// "قريب مما طلبت" و"بدائل مقترحة" (لا تُحدَّد مسبقًا).
  final List<MatchedProduct> close;
  final List<MatchedProduct> similar;

  /// دور الصنف في بكج/هدية (فارغ للطلب العادي).
  final String role;

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
    level: level,
    note: note,
    close: close,
    similar: similar,
    role: role,
  );

  SuggestionItem substitutedWith(
    SuggestedProduct replacement, {
    MatchLevel level = MatchLevel.exact,
    MatchNote? note,
  }) =>
      SuggestionItem.resolve(
        requestText: requestText,
        requestedQty: requestedQty,
        product: replacement,
        alternatives: alternatives.where((a) => a.id != replacement.id).toList(),
        level: level,
        note: note,
        close: close.where((m) => m.product.id != replacement.id).toList(),
        similar: similar.where((m) => m.product.id != replacement.id).toList(),
        role: role,
      );

  @override
  List<Object?> get props =>
      [requestText, requestedQty, quantity, status, product, alternatives, level, note, close, similar, role];
}