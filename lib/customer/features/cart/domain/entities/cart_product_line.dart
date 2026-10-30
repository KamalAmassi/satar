import 'package:equatable/equatable.dart';

/// عقد الإضافة من الكتالوج أو المساعد الذكي إلى السلة.
/// لا يحمل أي سعر: الخادم يسعّر كل سطر.
class CartItemRequest extends Equatable {
  const CartItemRequest({
    required this.productId,
    this.quantity = 1,
    this.options = const {},
    this.note,
  });

  final int productId;
  final int quantity;

  /// مفتاح الخيار → مفاتيح الاختيارات (واحد لـ single، عدة لـ multi).
  final Map<String, List<String>> options;
  final String? note;

  @override
  List<Object?> get props => [productId, quantity, options, note];
}

/// سطر منتج في السلة.
class CartProductLine extends Equatable {
  const CartProductLine({
    required this.id,
    required this.productId,
    required this.quantity,
    this.options = const {},
    this.note = '',
    this.revision = 0,
    this.fieldErrors = const {},
  });

  final String id;
  final int productId;
  final int quantity;
  final Map<String, List<String>> options;
  final String note;
  final int revision;

  /// أخطاء الخادم لهذا السطر فقط (مثل options.cover_color).
  final Map<String, String> fieldErrors;

  /// هوية السطر: نفس المنتج بنفس الخيارات = نفس السطر.
  String get identity => identityOf(productId, options);

  static String identityOf(int productId, Map<String, List<String>> options) {
    final keys = options.keys.toList()..sort();
    final parts = [
      for (final k in keys) '$k=${([...options[k]!]..sort()).join('+')}',
    ];
    return '$productId|${parts.join('&')}';
  }

  CartProductLine copyWith({
    int? quantity,
    Map<String, List<String>>? options,
    String? note,
    Map<String, String>? fieldErrors,
    bool bumpRevision = false,
  }) =>
      CartProductLine(
        id: id,
        productId: productId,
        quantity: quantity ?? this.quantity,
        options: options ?? this.options,
        note: note ?? this.note,
        revision: bumpRevision ? revision + 1 : revision,
        fieldErrors: fieldErrors ?? this.fieldErrors,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'qty': quantity,
        'options': options,
        'note': note,
        'revision': revision,
      };

  factory CartProductLine.fromJson(Map<String, dynamic> json) =>
      CartProductLine(
        id: json['id'] as String,
        productId: json['product_id'] as int,
        quantity: json['qty'] as int? ?? 1,
        options: {
          for (final e in (json['options'] as Map? ?? const {}).entries)
            '${e.key}': [for (final v in e.value as List) '$v'],
        },
        note: json['note'] as String? ?? '',
        revision: json['revision'] as int? ?? 0,
      );

  @override
  List<Object?> get props =>
      [id, productId, quantity, options, note, revision, fieldErrors];
}
