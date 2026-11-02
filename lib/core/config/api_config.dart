/// إعدادات الاتصال الخاصة بواجهة Masar API لمشروع سطر.
/// يُفضّل نقل projectKey إلى --dart-define في بيئة الإنتاج.
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://masar.toldpath.com',
  );
  static const String projectKey = String.fromEnvironment(
    'PROJECT_KEY',
    defaultValue: 'pk_test_fFiQyTDZSHzrbtj9O2uz9yHo0FMYOS4XG1MBbYwa',
  );
  static const String devMember = String.fromEnvironment(
    'DEV_MEMBER',
    defaultValue: 'postman',
  );
  static const String defaultLocale = 'ar';
}
