import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AiConfig {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static const List<String> geminiModels = [
    'gemini-3.5-flash-lite',
    'gemini-3.5-flash',
  ];

  static const geminiBaseUrl = 'https://generativelanguage.googleapis.com';

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
}