import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/otp/presentation/otp_verification_view.dart';
import 'package:project/customer/features/account/presentation/account_page.dart';
import 'package:project/customer/features/ai_assistant/presentation/assistant_page.dart';
import 'package:project/customer/features/ai_assistant/presentation/bindings/voice_binding.dart';
import 'package:project/customer/features/ai_assistant/presentation/views/voice_page.dart';
import 'package:project/customer/features/cart/presentation/cart_page.dart';
import 'package:project/customer/features/catalog/presentation/catalog_page.dart';
import 'package:project/customer/features/checkout/presentation/checkout_page.dart';
import 'package:project/customer/features/entry/presentation/entry_page.dart';
import 'package:project/customer/features/orders/presentation/orders_page.dart';
import 'package:project/customer/features/payment/presentation/payment_page.dart';
import 'package:project/customer/features/printing/presentation/printing_page.dart';
import 'package:project/driver/features/auth/presentation/driver_login_page.dart';
import 'package:project/driver/features/auth/presentation/driver_settings_page.dart';
import 'package:project/driver/features/orders/presentation/driver_page.dart';

GetPage<dynamic> _p(String name, Widget Function() page) => GetPage(name: name, page: page);

abstract final class AppRouter {
  static final unknown = GetPage<dynamic>(name: '/404', page: () => const SplashScreen());

  static final List<GetPage<dynamic>> pages = [
    _p('/', () => const SplashScreen()),
    _p('/role', () => const RoleScreen()),
    _p('/onboarding', () => const OnboardingScreen()),
    _p('/auth/phone', () => const PhoneScreen()),
    _p('/auth/otp', () => const OtpScreen()),
    _p('/otp', () => const OtpVerificationView()),
    _p('/auth/welcome', () => const WelcomeNameScreen()),
    // استكشاف
    _p('/home', () => const HomeScreen()),
    _p('/categories', () => const CategoriesScreen()),
    _p('/products', () => const ProductsScreen()),
    _p('/search', () => const SearchScreen()),
    _p('/product', () => const ProductScreen()),
    // سلة ومساعد
    _p('/cart', () => const CartScreen()),
    _p('/assistant', () => const AssistantScreen()),
    GetPage<dynamic>(name: '/customer/ai-voice', page: () => const VoicePage(), binding: VoiceBinding()),
    // طباعة
    _p('/print', () => const PrintLandingScreen()),
    _p('/print/upload', () => const PrintUploadScreen()),
    _p('/print/specs', () => const PrintSpecsScreen()),
    _p('/print/review', () => const PrintReviewScreen()),
    // توصيل ودفع
    _p('/checkout', () => const CheckoutScreen()),
    _p('/checkout/quote', () => const QuoteScreen()),
    _p('/order-placed', () => const OrderPlacedScreen()),
    _p('/order-uncertain', () => const OrderUncertainScreen()),
    _p('/address/form', () => const AddressFormScreen()),
    _p('/addresses', () => const AddressesScreen()),
    // طلبات
    _p('/orders', () => const OrdersScreen()),
    _p('/order', () => const OrderDetailScreen()),
    _p('/offer', () => const OfferScreen()),
    _p('/offer/approved', () => const OfferApprovedScreen()),
    _p('/pay', () => const PayScreen()),
    _p('/pay/upload', () => const PayUploadScreen()),
    _p('/tracking', () => const TrackingScreen()),
    _p('/track', () => const PublicTrackScreen()),
    _p('/rate', () => const RateScreen()),
    _p('/receipt', () => const ReceiptScreen()),
    _p('/notifications', () => const NotificationsScreen()),
    // حساب
    _p('/account', () => const AccountScreen()),
    _p('/profile', () => const ProfileEditScreen()),
    _p('/account/delete', () => const DeleteAccountScreen()),
    // حالات النظام
    _p('/session-expired', () => const SessionExpiredScreen()),
    _p('/update-required', StateScreens.updateRequired),
    _p('/maintenance', StateScreens.maintenance),
    _p('/service-paused', StateScreens.servicePaused),
    _p('/blocked', StateScreens.blocked),
    _p('/module-off', StateScreens.moduleOff),
    _p('/rate-limited', () => StateScreens.rateLimited((Get.arguments is int ? Get.arguments as int : 30))),
    // أذونات
    _p('/perm/location', () => PermissionExplainScreen(ill: 'pin', title: 'حدّد موقعك بسهولة', text: 'نستخدم موقعك لوضع عنوانك على الخريطة بدقة. تقدر تحرّك الدبوس بنفسك أيضًا.', allowLabel: 'السماح بالموقع', allowIcon: 'pin', badge: 'للزبون: اختياري', onAllow: () async {
          await Permission.locationWhenInUse.request();
          Get.back();
        })),
    _p('/perm/location-denied', () => SystemStateScreen(ill: 'pin', title: 'الموقع غير مفعّل', text: 'يمكنك تحريك الدبوس على الخريطة يدويًا، أو تفعيل الإذن من إعدادات الجهاز.', actions: [SBtn('تحريك الدبوس يدويًا', full: true, onTap: () => Get.back()), SBtn('فتح الإعدادات', kind: BtnKind.ghost, full: true, onTap: openAppSettings)])),
    _p('/perm/notify', () => PermissionExplainScreen(ill: 'assist', title: 'ابقَ على اطلاع بطلبك', text: 'نُعلمك عند جاهزية عرض السعر، وقبول الدفع، ووصول السائق.', allowLabel: 'تفعيل الإشعارات', allowIcon: 'bell', onAllow: () async {
          await Permission.notification.request();
          Get.back();
        })),
    _p('/perm/mic', () => PermissionExplainScreen(ill: 'assist', title: 'تحدّث بدل الكتابة', text: 'نحتاج الميكروفون لتحويل كلامك إلى طلب. لا نسجّل إلا أثناء الضغط.', allowLabel: 'السماح بالميكروفون', allowIcon: 'mic', laterLabel: 'أفضّل الكتابة', onAllow: () async {
          await Permission.microphone.request();
          Get.back();
        })),
    _p('/perm/files', () => PermissionExplainScreen(ill: 'print', title: 'اختر ملفاتك للطباعة', text: 'نحتاج الوصول للملفات أو الصور لتختار ما تريد طباعته. لا نقرأ غير ما تختاره.', allowLabel: 'اختيار الملفات', allowIcon: 'file', laterLabel: 'إلغاء', onAllow: () {
          Get.back();
          Get.toNamed('/print/upload', arguments: {'pick': true});
        })),
    // السائق
    _p('/driver/login', () => const DriverLoginScreen()),
    _p('/driver/home', () => const DriverHomeScreen()),
    _p('/driver/available', () => const AvailableScreen()),
    _p('/driver/order', () => const DriverPreviewScreen()),
    _p('/driver/task', () => const DriverTaskScreen()),
    _p('/driver/deliver', () => const DriverDeliverScreen()),
    _p('/driver/failed', () => const DriverFailedScreen()),
    _p('/driver/failure-recorded', () => const DriverFailureRecordedScreen()),
    _p('/driver/delivered', () => const DriverDeliveredScreen()),
    _p('/driver/history', () => const DriverHistoryScreen()),
    _p('/driver/earnings', () => const DriverEarningsScreen()),
    _p('/driver/cash', () => const DriverCashScreen()),
    _p('/driver/notifications', () => const NotificationsScreen(driver: true)),
    _p('/driver/profile', () => const DriverProfileScreen()),
    _p('/driver/perm-location', () => const DriverLocationPermScreen()),
  ];
}
