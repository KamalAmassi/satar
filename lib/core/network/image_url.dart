import 'package:project/core/config/app_env.dart';

/// يحوّل رابط صورة قادمًا من الخادم إلى رابط مطلق: المطلق يبقى كما هو، والنسبي
/// يُحل مقابل مضيف الـ API. لا يسجَّل الرابط الكامل في أي مكان.
String? resolveImageUrl(String? raw, {String? base}) {
  final v = raw?.trim();
  if (v == null || v.isEmpty) return null;
  final uri = Uri.tryParse(v);
  if (uri == null) return null;
  if (uri.hasScheme) return v;
  try {
    final origin = Uri.parse(base ?? AppEnv.apiBaseUrl).origin;
    return Uri.parse(origin).resolve(v.startsWith('//') ? 'https:$v' : v).toString();
  } catch (_) {
    return null;
  }
}
