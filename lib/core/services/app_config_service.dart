import 'package:project/core/network/api_client.dart';
import 'package:project/core/network/api_endpoints.dart';
import 'package:project/core/network/models/masar_models.dart';
import 'package:project/core/utils/json_utils.dart';

/// يحمّل GET /app/config?app=driver مرة واحدة ويخزّنه.
/// يعطينا: فترة إرسال الموقع، وخيارات سبب تعذّر التسليم (لو موجودة بالإعدادات).
class AppConfigService {
  AppConfigService(this._api);

  final ApiClient _api;

  AppConfig? config;
  bool _loading = false;

  Future<void> load() async {
    if (config != null || _loading) return;
    _loading = true;
    try {
      final data = await _api.getData(
        ApiEndpoints.appConfig,
        queryParameters: {'app': 'driver'},
      );
      config = AppConfig.fromJson(asMap(data));
    } catch (_) {
      config = null; // نكمل بالقيم الافتراضية
    } finally {
      _loading = false;
    }
  }

  /// أقل فاصل بين إرسالات الموقع (ثانية).
  int get locationIntervalSeconds =>
      (config?.driver?.locationMinIntervalSeconds ?? 30).clamp(10, 300).toInt();

  /// خيارات `delivery_failure_reason` من الإعدادات: قائمة من {key,label?}.
  /// شكل تعريف الحقل غير موثّق، فنقرأ بتسامح: options / choices / enum بصيغة نص أو {value,label}.
  List<({String key, String? label})> get failureReasonOptions {
    final def = config?.fields['delivery_failure_reason'];
    final raw = def is Map
        ? pick(asMap(def), const ['options', 'choices', 'enum', 'values'])
        : def;
    final out = <({String key, String? label})>[];
    for (final o in asList(raw)) {
      if (o is String && o.isNotEmpty) {
        out.add((key: o, label: null));
      } else if (o is Map) {
        final m = asMap(o);
        final key = asString(pick(m, const ['value', 'key', 'id']));
        if (key != null) {
          out.add((key: key, label: asString(pick(m, const ['label', 'name', 'title']))));
        }
      }
    }
    return out;
  }
}
