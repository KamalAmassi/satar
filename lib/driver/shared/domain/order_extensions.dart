import 'package:project/core/network/models/masar_models.dart';

/// امتدادات صغيرة فوق مودلز masar (لا نعدّل الملف المُولَّد).
extension MoneyX on Money {
  bool get isZero => amount <= 0;

  /// النص الجاهز للعرض كما يرجع من السيرفر (مثلاً "18.00 ₪").
  String get display => formatted;
}

extension PlaceX on Place {
  bool get hasCoords => lat != null && lng != null;

  String get summary => [label, details]
      .whereType<String>()
      .where((s) => s.trim().isNotEmpty)
      .join(' - ');
}

extension NextActionX on NextAction {
  bool get needsFailureReason => fields.contains('delivery_failure_reason');

  /// الخطوة تطلب صورة إثبات؟ (القيم الدقيقة لـ requires غير موثّقة، نبحث عن photo).
  bool get requiresPhoto => requires.any((r) => r.toLowerCase().contains('photo'));
}

extension DriverOrderX on DriverOrder {
  Money get cashToCollect => payment.collect;
  bool get hasCashToCollect => payment.collect.amount > 0;
  bool get isDelivered => status.key == StatusKeys.delivered;
  bool get isFailed => status.key == StatusKeys.deliveryFailed;
  String? get customerPhone => customer?.phone;
  String? get failureReason => fields.deliveryFailureReason;

  /// إجراء "تعذّر التسليم" لو السيرفر يسمح فيه حالياً.
  NextAction? get failureAction {
    for (final a in actions) {
      if (a.to == StatusKeys.deliveryFailed) return a;
    }
    return null;
  }
}
