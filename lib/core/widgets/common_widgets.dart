import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/errors/failure_messages.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/data/backend.dart';
import 'package:project/core/data/models.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/printing/domain/entities/print_estimate.dart';

Backend get backend => Get.find<Backend>();
CartController get cartCtl => Get.find<CartController>();

String failureText(Failure f) => f.describe(Get.context!);

/// تقدير مجموع السلة للعرض فقط (الخادم هو المرجع في التسعيرة).
({num products, num printing, bool productsKnown}) cartEstimate() {
  final cart = cartCtl;
  final prod = cart.displayedProductsTotal;
  final cfg = Get.find<RemoteConfigRepository>().current?.printing;
  num print = 0;
  if (cfg != null) {
    for (final j in cart.printJobs) {
      print += PrintEstimate.forJob(j, cfg)?.amount ?? 0;
    }
  }
  return (products: prod?.amount ?? 0, printing: print, productsKnown: prod != null || cart.products.isEmpty);
}

String two(int n) => n.toString().padLeft(2, '0');

const _months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];

String timeLabel(DateTime? d) {
  if (d == null) return '';
  final now = DateTime.now();
  final t = '${two(d.hour)}:${two(d.minute)}';
  final sameDay = now.year == d.year && now.month == d.month && now.day == d.day;
  if (sameDay) return 'اليوم · $t';
  final y = now.subtract(const Duration(days: 1));
  if (y.year == d.year && y.month == d.month && y.day == d.day) return 'أمس · $t';
  return '${d.day} ${_months[d.month - 1]} · $t';
}

String dateLabel(DateTime? d) {
  if (d == null) return '';
  return '${d.day} ${_months[d.month - 1]}';
}

String statusLabel(StatusModel s) => s.label.isNotEmpty ? s.label : s.key;

/// وصف قصير لحالة الطلب للزبون (يُعرض تحت اسم الحالة).
String statusDesc(String key) => switch (key) {
      'pending' || 'new' || 'submitted' => 'وصل طلبك وننتظر مراجعة المكتبة.',
      'priced' => 'جهّزت المكتبة عرض السعر. راجعه وأكّد.',
      'awaiting_payment' => 'بانتظار إتمام الدفع لنبدأ التجهيز.',
      'paid' || 'preparing' || 'processing' => 'نجهّز طلبك الآن.',
      'ready' || 'ready_for_pickup' => 'طلبك جاهز وبانتظار السائق.',
      'assigned' || 'accepted' => 'تم إسناد طلبك إلى سائق.',
      'picked_up' => 'استلم السائق طلبك.',
      'on_the_way' => 'طلبك في الطريق إليك.',
      'arrived' => 'وصل السائق. جهّز كود التسليم.',
      'delivered' || 'completed' => 'تم تسليم طلبك. شكرًا لك!',
      'cancelled' || 'canceled' => 'أُلغي هذا الطلب.',
      _ => '',
    };
