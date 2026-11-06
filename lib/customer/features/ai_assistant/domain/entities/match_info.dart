import 'package:equatable/equatable.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';

/// مدى مطابقة منتج للطلب المفهوم.
enum MatchLevel { exact, close, alternative, reject }

/// سبب (رمز + وسيط) يُحوَّل لنص عبر ARB في الواجهة؛ لا نصوص ثابتة هنا.
enum NoteCode {
  /// طُلبت ربطة وهذا مفرد.
  singleNotPack,

  /// طُلب مفرد وهذا عبوة.
  packNotSingle,

  /// يحتوي كلمة غير مطلوبة (arg).
  unwantedTerm,

  /// صفة مختلفة (arg = القيمة المطلوبة).
  attrDiffers,

  /// الصفة غير مؤكدة في الاسم/الوصف (arg).
  attrUnknown,

  /// نفس الاستخدام لكن نوع مختلف (arg = الفئة).
  differentType,

  /// يذكر الوصف عمرًا مناسبًا (arg = نص العمر).
  ageFits,

  /// لا معلومة عمر في الكتالوج: مناسبة غالبًا.
  ageUnknown,

  /// عمر الوصف خارج المطلوب (arg).
  ageOutside,

  /// سبب من الحكم (arg = جملة قصيرة من النموذج).
  judged,
}

class MatchNote extends Equatable {
  const MatchNote(this.code, [this.arg = '']);
  final NoteCode code;
  final String arg;
  @override
  List<Object?> get props => [code, arg];
}

class MatchedProduct extends Equatable {
  const MatchedProduct({required this.product, required this.level, this.note});
  final SuggestedProduct product;
  final MatchLevel level;
  final MatchNote? note;
  @override
  List<Object?> get props => [product, level, note];
}
