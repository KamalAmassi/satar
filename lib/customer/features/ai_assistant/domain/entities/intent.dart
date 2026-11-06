import 'package:equatable/equatable.dart';

enum IntentKind { specificItem, bundleForPurpose, giftOrToyForPurpose, question, unclear }

enum PackMode { single, pack }

/// صنف واحد مطلوب بصورة مفهومة: نوع المنتج + عبوة/مفرد + صفات + مرفوضات.
class ItemSpec extends Equatable {
  const ItemSpec({
    required this.productType,
    this.pack = PackMode.single,
    this.quantity = 1,
    this.attributes = const {},
    this.mustHave = const [],
    this.mustNot = const [],
    this.originalText = '',
    this.role = '',
    this.essential = true,
    this.isPrint = false,
    this.similar = const [],
  });

  /// الاسم الرئيسي المعياري ("دفتر"، "قلم"، "مقص").
  final String productType;
  final PackMode pack;
  final int quantity;

  /// size, pages, ruling, color, brand, grade (القيم الفارغة محذوفة).
  final Map<String, String> attributes;
  final List<String> mustHave;
  final List<String> mustNot;
  final String originalText;

  /// دور الصنف داخل بكج/هدية ("حقيبة"، "دفاتر").
  final String role;
  final bool essential;
  final bool isPrint;

  /// أنواع قريبة/مرادفات تُجرَّب فقط إن لم يوجد الأصل (بدائل مشابهة).
  final List<String> similar;

  ItemSpec copyWith({int? quantity, PackMode? pack}) => ItemSpec(
        productType: productType,
        pack: pack ?? this.pack,
        quantity: quantity ?? this.quantity,
        attributes: attributes,
        mustHave: mustHave,
        mustNot: mustNot,
        originalText: originalText,
        role: role,
        essential: essential,
        isPrint: isPrint,
        similar: similar,
      );

  @override
  List<Object?> get props => [productType, pack, quantity, attributes, mustHave, mustNot, originalText, role, essential, isPrint, similar];
}

class Clarification extends Equatable {
  const Clarification({required this.question, required this.options});
  final String question;
  final List<String> options;
  @override
  List<Object?> get props => [question, options];
}

/// طلب واحد مفهوم من كلام المستخدم.
class IntentRequest extends Equatable {
  const IntentRequest({
    required this.kind,
    this.item,
    this.purpose = '',
    this.audience = '',
    this.age,
    this.budget,
    this.neededItems = const [],
    this.recipient = '',
    this.occasion = '',
    this.interests = const [],
    this.desiredTraits = const [],
    this.searchIntents = const [],
    this.originalText = '',
  });

  final IntentKind kind;

  /// لـ specific_item.
  final ItemSpec? item;

  /// bundle_for_purpose
  final String purpose;
  final String audience;

  /// gift_or_toy_for_purpose
  final int? age;
  final String recipient;
  final String occasion;
  final List<String> interests;
  final List<String> desiredTraits;
  final List<ItemSpec> searchIntents;

  /// بالشيكل (وحدات كاملة).
  final int? budget;
  final List<ItemSpec> neededItems;
  final String originalText;

  @override
  List<Object?> get props => [kind, item, purpose, audience, age, budget, neededItems, recipient, occasion, interests, desiredTraits, searchIntents, originalText];
}
