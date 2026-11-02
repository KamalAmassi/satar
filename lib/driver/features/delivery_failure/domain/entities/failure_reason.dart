import 'package:project/core/services/app_config_service.dart';

/// سبب تعذّر التسليم. المصدر الأول إعدادات السيرفر (app/config → fields)،
/// وإلا نستخدم القائمة الاحتياطية (المؤكد منها فقط customer_unreachable).
class FailureReason {
  const FailureReason(this.key, {this.label});

  final String key;
  final String? label;

  @override
  bool operator ==(Object other) => other is FailureReason && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

abstract final class FailureReasons {
  static const unreachable = FailureReason('customer_unreachable');
  static const wrongAddress = FailureReason('wrong_address');
  static const refused = FailureReason('customer_refused');
  static const notHome = FailureReason('customer_not_available');
  static const other = FailureReason('other');

  static const fallback = [unreachable, wrongAddress, refused, notHome, other];

  static List<FailureReason> from(AppConfigService config) {
    final fromConfig = config.failureReasonOptions;
    if (fromConfig.isEmpty) return fallback;
    return [for (final o in fromConfig) FailureReason(o.key, label: o.label)];
  }
}
