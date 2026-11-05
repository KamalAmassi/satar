import 'package:flutter/animation.dart';

/// رموز الحركة (Motion tokens): هادئة وقصيرة، تتماشى مع الهوية التحريرية.
abstract final class Motion {
  /// طيران صورة المنتج إلى أيقونة السلة.
  static const flyToCart = Duration(milliseconds: 650);
  static const flyToCartCurve = Curves.easeInOutCubic;

  /// الفاصل بين صور «أضف الكل» المتتابعة.
  static const flyStagger = Duration(milliseconds: 90);

  /// نبضة أيقونة السلة عند الوصول (1 → 1.25 → 1).
  static const cartBump = Duration(milliseconds: 350);

  /// مدة الضغط (تصغير البطاقة/الزر).
  static const pressIn = Duration(milliseconds: 90);

  /// مدة الارتداد بعد رفع الإصبع (ارتداد نابضي خفيف).
  static const pressOut = Duration(milliseconds: 220);

  /// مقياس الضغط: 0.97 من الحجم الأصلي.
  static const pressScale = 0.97;

  static const pressInCurve = Curves.easeOutCubic;

  /// easeInBack عند العكس يعطي تجاوزًا طفيفًا فوق 1.0 ثم يستقر (نابض ناعم).
  static const pressOutCurve = Curves.easeInBack;

  /// انتقالات صغيرة عامة (مفاتيح، مؤشرات).
  static const short = Duration(milliseconds: 200);

  /// موجة الصوت: أقصى معدل رسم (~30 إطار/ث).
  static const waveFrame = Duration(microseconds: 33333);

  /// موجة الصوت: صعود سريع وهبوط أهدأ.
  static const waveAttack = Duration(milliseconds: 30);
  static const waveRelease = Duration(milliseconds: 180);

  /// موجة الصوت عند الإيقاف: تجميد قصير ثم تلاشٍ.
  static const waveFreeze = Duration(milliseconds: 250);
  static const waveFade = Duration(milliseconds: 300);

  /// ظهور الصورة بعد تحميلها فوق العنصر النائب.
  static const imageFade = Duration(milliseconds: 220);

  /// فتح/إغلاق عارض الصور (ومدة طيران Hero إليه).
  static const viewerRoute = Duration(milliseconds: 280);

  /// تكبير/تصغير بالنقر المزدوج.
  static const viewerZoom = Duration(milliseconds: 240);

  /// رسم علامة النجاح كخط حبر.
  static const checkDraw = Duration(milliseconds: 450);

  /// انفجار الاحتفال بعد العلامة (يتوقف تلقائيًا).
  static const celebrationBurst = Duration(milliseconds: 2450);

  /// انزلاق علامة السائق بين تحديثين (بدل القفز).
  static const driverGlide = Duration(milliseconds: 1000);

  /// دورة نبض حلقات السائق.
  static const driverPulse = Duration(milliseconds: 2400);

  /// أقصى معدل رسم للتأثيرات فوق الخريطة (~30 إطار/ث).
  static const mapFrame = Duration(microseconds: 33333);

  /// إعادة فحص حداثة الموقع بين الاستطلاعات.
  static const freshnessRecheck = Duration(seconds: 30);

  /// ظهور العناصر المتتابع (Entrance).
  static const entrance = Duration(milliseconds: 420);
  static const entranceStagger = Duration(milliseconds: 60);

  /// اهتزاز الخطأ (رمز خاطئ / بيانات دخول خاطئة).
  static const shake = Duration(milliseconds: 380);
}
