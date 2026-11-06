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

/// استخراج وتجهيز رابط الصورة من استجابة الخادم بأي صيغة (image_url, image, photo, media, path, إلخ)
String? extractImageUrl(dynamic raw, {String? base}) {
  if (raw == null) return null;
  if (raw is String) return resolveImageUrl(raw, base: base);
  if (raw is Map) {
    final candidate = raw['url'] ?? raw['image_url'] ?? raw['original_url'] ?? raw['path'] ?? raw['src'] ?? raw['file'];
    if (candidate is String) return resolveImageUrl(candidate, base: base);
  }
  if (raw is List && raw.isNotEmpty) {
    return extractImageUrl(raw.first, base: base);
  }
  return null;
}
