/// تحويل أرقام الجوال إلى E.164 وإخفاؤها للعرض.
abstract final class PhoneNormalizer {
  static const _arabicDigits = {
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4', '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9', //
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4', '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
  };
  // مسافات وشرطات وأقواس، وعلامات الاتجاه (LRM/RLM وعزل الاتجاه U+2066..U+2069).
  static final String _bidiMarks = String.fromCharCodes([0x200E, 0x200F, 0x2066, 0x2067, 0x2068, 0x2069]);
  static final _separators = RegExp('[${r'\s\-().'}$_bidiMarks]');
  static final _digits = RegExp(r'^\d+$');

  /// فلسطين (+970) والداخل (+972): الجوال 9 أرقام تبدأ بـ 5.
  static const _localMobileCodes = {'970', '972'};

  /// يعيد +970599123456 أو null إن كان الرقم غير صالح.
  /// يقبل: 0599123456، 599123456، 00970599123456، 970599123456، +970 59-912-3456، وأرقامًا عربية.
  static String? toE164(String input, {String defaultCountryCode = '+970'}) {
    var s = input.trim();
    if (s.isEmpty) return null;
    s = s.split('').map((ch) => _arabicDigits[ch] ?? ch).join().replaceAll(_separators, '');
    final cc = defaultCountryCode.replaceAll('+', '');
    String digits;
    if (s.startsWith('+')) {
      digits = s.substring(1);
    } else if (s.startsWith('00')) {
      digits = s.substring(2);
    } else if (s.startsWith('0')) {
      digits = '$cc${s.substring(1)}';
    } else if (s.startsWith(cc) && s.length > cc.length + 8) {
      digits = s;
    } else {
      digits = '$cc$s';
    }
    if (!_digits.hasMatch(digits) || digits.startsWith('0')) return null;
    // E.164: حتى 15 رقمًا، ونقبل 8 كحد أدنى.
    if (digits.length < 8 || digits.length > 15) return null;
    for (final code in _localMobileCodes) {
      if (digits.startsWith(code)) {
        final national = digits.substring(code.length);
        if (national.length != 9 || !national.startsWith('5')) return null;
      }
    }
    return '+$digits';
  }

  static bool isValid(String input, {String defaultCountryCode = '+970'}) =>
      toE164(input, defaultCountryCode: defaultCountryCode) != null;

  /// إخفاء للعرض والسجلات: +9705*****12 (لا يُعرض الرقم كاملًا أبدًا).
  static String mask(String e164) {
    if (e164.length <= 7) return e164.replaceAll(RegExp(r'\d'), '*');
    final head = e164.substring(0, 5);
    final tail = e164.substring(e164.length - 2);
    return '$head${'*' * (e164.length - 7)}$tail';
  }
}
