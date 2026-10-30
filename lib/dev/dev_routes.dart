import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';
import 'package:project/dev/purchasing_dev_hub.dart';

/// مسارات تطوير فقط — لا تُسجَّل في نسخ الإصدار.
abstract final class DevRoutes {
  static const purchasingHub = '/dev/purchasing';

  /// مفعّلة في debug، أو صراحةً عبر --dart-define=SATR_DEV_TOOLS=true.
  /// لا تُفعَّل أبدًا في نسخة إصدار عادية.
  static bool get enabled =>
      kDebugMode || const bool.fromEnvironment('SATR_DEV_TOOLS');

  /// --dart-define=SATR_INITIAL_ROUTE=/dev/purchasing (أدوات التطوير فقط).
  static String? get initialOverride {
    const route = String.fromEnvironment('SATR_INITIAL_ROUTE');
    return enabled && route.isNotEmpty ? route : null;
  }

  static List<GetPage<dynamic>> get pages => [
        GetPage(
          name: purchasingHub,
          page: () => const PurchasingDevHub(),
          binding: CartBinding(),
        ),
      ];
}
