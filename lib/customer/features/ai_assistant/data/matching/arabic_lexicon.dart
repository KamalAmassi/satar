import 'package:project/core/utils/arabic_text.dart';

/// قاموس صغير قابل للتعديل لمفردات القرطاسية (لهجة شامية/فلسطينية).
/// كل الكلمات تُمرَّر عبر نفس التطبيع/التجذيع المستخدم للفهرسة، فلا فرق بين
/// "ربطة/ربطه" أو "أقلام/اقلام". يُفحص تغطيته على الكتالوج الحقيقي عبر
/// [CatalogIndex.lexiconCoverage] في وضع التطوير.
abstract final class ArabicLexicon {
  /// جذوع كلمات نص حرّ (تطبيع + تجذيع)، بترتيبها.
  static List<String> stems(String text) => [
    for (final t in ArabicText.normalize(text).split(' '))
      if (t.isNotEmpty) ArabicText.stem(t),
  ];

  static String stemOf(String word) => ArabicText.stem(ArabicText.normalize(word));

  // ---- العبوات ----
  /// "ربطة/باكيت/طقم..." = عبوة من عدة وحدات.
  static final Set<String> packStems = {
    for (final w in const ['ربطة', 'باكيت', 'باكت', 'عبوة', 'طقم', 'دزينة', 'علبة', 'مجموعة', 'بكج', 'سيت'])
      stemOf(w),
  };

  /// بعد رقم >= 2 تدل على عبوة ("12 قلم").
  static final Set<String> unitStems = {
    for (final w in const ['قطعة', 'حبة', 'دفتر', 'قلم', 'كراسة', 'ممحاة', 'مبراة', 'مسطرة', 'لون', 'مقص'])
      stemOf(w),
  };

  // ---- مرادفات نوع المنتج ----
  static final List<Set<String>> _synonymGroups = [
    {for (final w in const ['حقيبة', 'شنطة', 'جنطة', 'شنطه']) stemOf(w)},
    {for (final w in const ['ممحاة', 'محاية', 'محاه']) stemOf(w)},
    {for (final w in const ['مبراة', 'براية', 'برايه']) stemOf(w)},
    {for (final w in const ['لعبة', 'العاب']) stemOf(w)},
    {for (final w in const ['مسطرة', 'مساطر']) stemOf(w)},
    {for (final w in const ['كراسة', 'كراريس']) stemOf(w)},
  ];

  /// المجموعة المرادفة لجذع (تشمل الجذع نفسه).
  static Set<String> synonymsOf(String stem) {
    for (final g in _synonymGroups) {
      if (g.contains(stem)) return g;
    }
    return {stem};
  }

  // ---- أصناف متقاربة تُسبّب نتائج خاطئة ما لم يذكرها الزبون ----
  /// جذع نوع المنتج ← مصطلحات تجعل النتيجة "قريبة" لا "مطابقة" إن لم يطلبها المستخدم.
  static final Map<String, Set<String>> confusables = {
    stemOf('دفتر'): {
      for (final w in const ['سلك', 'سلكي', 'حلزوني', 'نوتة', 'ملاحظات', 'مفكرة'])
        stemOf(w),
    },
    stemOf('كراسة'): {stemOf('سلك'), stemOf('نوتة')},
  };

  // ---- الألوان (كل لون ← صيغه) ----
  static final List<Set<String>> colorGroups = [
    {for (final w in const ['أزرق', 'زرقاء', 'ازرق']) stemOf(w)},
    {for (final w in const ['أحمر', 'حمراء']) stemOf(w)},
    {for (final w in const ['أخضر', 'خضراء']) stemOf(w)},
    {for (final w in const ['أصفر', 'صفراء']) stemOf(w)},
    {for (final w in const ['أسود', 'سوداء']) stemOf(w)},
    {for (final w in const ['أبيض', 'بيضاء']) stemOf(w)},
    {for (final w in const ['وردي', 'زهري']) stemOf(w)},
    {for (final w in const ['بنفسجي', 'موف']) stemOf(w)},
    {for (final w in const ['برتقالي']) stemOf(w)},
    {for (final w in const ['رمادي']) stemOf(w)},
    {for (final w in const ['بني']) stemOf(w)},
  ];

  static Set<String>? colorGroupOf(String stem) {
    for (final g in colorGroups) {
      if (g.contains(stem)) return g;
    }
    return null;
  }

  /// أسماء الأعداد بالكلمات (للكمية).
  static const numberWords = {
    'واحد': 1, 'اثنين': 2, 'ثلاث': 3, 'ثلاثه': 3, 'اربع': 4, 'اربعه': 4,
    'خمس': 5, 'خمسه': 5, 'ست': 6, 'سته': 6, 'سبع': 7, 'سبعه': 7,
    'ثمان': 8, 'ثمانيه': 8, 'تسع': 9, 'تسعه': 9, 'عشر': 10, 'عشره': 10,
  };
}
