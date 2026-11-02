/// أدوات قراءة JSON بشكل متسامح (الـ API مو موثّق بأمثلة ردود، فنقرأ بحذر).
Map<String, dynamic> asMap(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<dynamic> asList(Object? v) => v is List ? v : const <dynamic>[];

/// أول قيمة غير null من مجموعة مفاتيح محتملة.
Object? pick(Map<String, dynamic> m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v != null) return v;
  }
  return null;
}

String? asString(Object? v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

int? asInt(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('${v ?? ''}');
}

double? asDouble(Object? v) {
  if (v is num) return v.toDouble();
  return double.tryParse('${v ?? ''}');
}

bool asBool(Object? v, {bool fallback = false}) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == 'true' || v == '1';
  return fallback;
}

DateTime? asDate(Object? v) => v == null ? null : DateTime.tryParse('$v');

/// يستخرج قائمة من data سواء كانت List مباشرة أو داخل items/data/results.
List<Map<String, dynamic>> extractList(Object? data) {
  Object? raw = data;
  if (data is Map) {
    raw = pick(asMap(data), const [
      'items',
      'data',
      'results',
      'orders',
      'notifications',
      'entries',
      'transactions',
    ]);
  }
  return asList(raw).whereType<Map>().map(asMap).toList();
}

/// بعض الردود تلف الكائن داخل مفتاح (مثل {order: {...}}) وبعضها يرجعه مباشرة.
Map<String, dynamic> unwrapKey(Object? data, String key) {
  final m = asMap(data);
  return m[key] is Map ? asMap(m[key]) : m;
}
