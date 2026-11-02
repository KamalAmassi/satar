import 'package:get/get.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/printing/domain/entities/print_estimate.dart';
import 'package:project/data/backend.dart';
import 'package:project/data/models.dart';

CartController get cartCtl => CartBinding.ensureCart();
Backend get backend => Get.find<Backend>();

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

/// رسالة عربية مفهومة للزبون بلا رموز تقنية.
String failureText(Failure f) {
  if (f is NetworkFailure) return 'تعذّر الاتصال. تحقق من الإنترنت وحاول مجددًا.';
  if (f is TimeoutFailure) return 'استغرق الاتصال وقتًا طويلًا. حاول مجددًا.';
  if (f is UnauthorizedFailure) return 'انتهت جلستك. سجّل الدخول من جديد.';
  switch (f.code) {
    case ApiErrorCodes.tooManyRequests:
      return 'طلبات كثيرة. انتظر قليلًا ثم حاول.';
    case ApiErrorCodes.outOfZone:
      return 'هذه النقطة خارج منطقة الخدمة.';
    case ApiErrorCodes.vendorClosed:
      return 'المكتبة مغلقة الآن.';
    case ApiErrorCodes.invalidTransition:
      return 'تغيّرت حالة الطلب. حدّث الصفحة.';
    case ApiErrorCodes.notFound:
      return 'لم نجد ما تبحث عنه.';
    case ApiErrorCodes.forbidden:
    case ApiErrorCodes.moduleDisabled:
      return 'هذه الميزة غير متاحة الآن.';
  }
  final m = f.message;
  if (m != null && m.trim().isNotEmpty) return m;
  return 'حدث خلل. حاول مجددًا.';
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
