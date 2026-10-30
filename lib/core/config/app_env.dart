/// إعدادات البيئة تُمرَّر وقت البناء عبر --dart-define ولا تُحفظ في المستودع.
///
/// flutter run \
///   --dart-define=SATR_PROJECT_KEY=pk_test_... \
///   --dart-define=SATR_BASE_URL=https://masar.toldpath.com
abstract final class AppEnv {
  static const String projectKey = String.fromEnvironment('SATR_PROJECT_KEY');

  static const String _baseUrl = String.fromEnvironment(
    'SATR_BASE_URL',
    defaultValue: 'https://masar.toldpath.com',
  );

  /// اسم عضو الفريق في بيئة التدريب (ترويسة X-Dev-Member)، اختياري.
  static const String devMember = String.fromEnvironment('SATR_DEV_MEMBER');

  /// لغة البدء (ar افتراضيًا). للتجربة: --dart-define=SATR_LOCALE=en
  static const String locale =
      String.fromEnvironment('SATR_LOCALE', defaultValue: 'ar');

  static bool get hasProjectKey => projectKey.isNotEmpty;

  /// مفاتيح pk_test_ و pk_preview_ تعمل على بيئة التجربة فقط.
  static bool get isSandboxKey =>
      projectKey.startsWith('pk_test_') || projectKey.startsWith('pk_preview_');

  /// عنوان الـ API بصيغة واحدة: `<host>/api` بدون تكرار /api أو الشرطة الأخيرة.
  static String get apiBaseUrl => normalizeApiBase(_baseUrl);

  static String normalizeApiBase(String raw) {
    var url = raw.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (url.endsWith('/v1')) url = url.substring(0, url.length - 3);
    if (!url.endsWith('/api')) url = '$url/api';
    return url;
  }
}
