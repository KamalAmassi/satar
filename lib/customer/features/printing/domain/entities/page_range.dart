/// تحقق مبكر من نطاق الصفحات بصيغة الخادم: "1-5, 8, 10-12".
/// الخادم يتحقق أيضًا وقراره هو النهائي.
abstract final class PageRange {
  static final _token = RegExp(r'^(\d+)(?:\s*-\s*(\d+))?$');

  /// كلمات "الكل" تعني ترك الحقل فارغًا؛ الخادم يرفض النص "All".
  static const _allWords = {'all', 'الكل', 'كل الصفحات'};

  static bool isAll(String input) {
    final t = input.trim().toLowerCase();
    return t.isEmpty || _allWords.contains(t);
  }

  /// القيمة التي تُرسل في print_page_range (null = كل الصفحات).
  static String? toRequest(String input) {
    if (isAll(input)) return null;
    return input
        .split(',')
        .map((p) => p.trim().replaceAll(RegExp(r'\s*-\s*'), '-'))
        .where((p) => p.isNotEmpty)
        .join(',');
  }

  /// الصفحات المختارة بلا تكرار، أو null إذا كان النطاق غير صالح.
  /// [totalPages] = null عندما لا يعرف التطبيق عدد الصفحات بعد.
  static Set<int>? parse(String input, {int? totalPages}) {
    if (isAll(input)) {
      if (totalPages == null) return const {};
      return {for (var i = 1; i <= totalPages; i++) i};
    }
    final pages = <int>{};
    for (final raw in input.split(',')) {
      final part = raw.trim();
      if (part.isEmpty) return null;
      final m = _token.firstMatch(part);
      if (m == null) return null;
      final start = int.parse(m.group(1)!);
      final end = m.group(2) == null ? start : int.parse(m.group(2)!);
      if (start < 1 || end < start) return null;
      if (totalPages != null && end > totalPages) return null;
      if (end - start > 100000) return null;
      for (var p = start; p <= end; p++) {
        pages.add(p);
      }
    }
    return pages;
  }

  static bool isValid(String input, {int? totalPages}) =>
      parse(input, totalPages: totalPages) != null;
}
