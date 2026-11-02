abstract final class ArabicText {
  static final _marks = RegExp(r'[\u064B-\u065F\u0670\u0640]');
  static final _nonWord = RegExp(r'[^\u0621-\u064Aa-z0-9\s]');
  static final _spaces = RegExp(r'\s+');

  static const _plurals = {
    'دفاتر': 'دفتر',
    'اقلام': 'قلم',
    'كتب': 'كتاب',
    'الوان': 'لون',
    'اوراق': 'ورق',
    'العاب': 'لعب',
    'هدايا': 'هدي',
    'مساطر': 'مسطر',
    'حقايب': 'حقيب',
    'اغلفه': 'غلاف',
    'كراريس': 'كراس',
    'كراسه': 'كراس',
    'محايات': 'ممحا',
    'محايه': 'ممحا',
    'برايات': 'مبرا',
    'برايه': 'مبرا',
    'مقصات': 'مقص',
  };

  static String normalize(String input) {
    var s = input.toLowerCase().replaceAll(_marks, '');
    s = s
        .replaceAll(RegExp('[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي');
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    for (var i = 0; i < arabicDigits.length; i++) {
      s = s.replaceAll(arabicDigits[i], '$i');
    }
    return s.replaceAll(_nonWord, ' ').replaceAll(_spaces, ' ').trim();
  }

  /// جذع الكلمة (الكلمة يجب أن تكون مطبّعة).
  static String stem(String token) {
    final direct = _plurals[token];
    if (direct != null) return direct;

    var t = token;
    if (t.length > 4 && t.startsWith('ال')) t = t.substring(2);
    final afterArticle = _plurals[t];
    if (afterArticle != null) return afterArticle;

    for (final suffix in const ['تين', 'ات', 'ين', 'ون', 'ان']) {
      if (t.length > suffix.length + 2 && t.endsWith(suffix)) {
        t = t.substring(0, t.length - suffix.length);
        break;
      }
    }
    if (t.length > 3 && t.endsWith('ه')) t = t.substring(0, t.length - 1);
    return _plurals[t] ?? t;
  }
}