
abstract final class AiConfig {
  /// يُمرَّر وقت البناء فقط: --dart-define=GEMINI_API_KEY=... ولا يُحفظ في المستودع.
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  static const List<String> geminiModels = [
    'gemini-3.5-flash-lite',
    'gemini-3.5-flash',
  ];

  static const geminiBaseUrl = 'https://generativelanguage.googleapis.com';

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
}