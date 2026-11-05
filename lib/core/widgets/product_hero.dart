import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:project/core/motion/motion_settings.dart';

/// وسم Hero فريد ومحدد النطاق: `product-image:{scope}:{id}`.
/// النطاق يمنع تكرار الوسم إن ظهر المنتج نفسه في مكانين على الشاشة.
String productHeroTag(String scope, Object id) {
  final s = scope.trim().isEmpty ? 'default' : scope.trim().replaceAll(':', '-');
  return 'product-image:$s:$id';
}

/// عرض فك الترميز بالبكسل مقرّبًا لأعلى لمضاعفات 128 (لإعادة استخدام الذاكرة المؤقتة)،
/// ومحدودًا بـ [maxPx] كي لا تُفك صور عملاقة. يعيد null إن كان العرض غير معروف.
int? productImageCacheWidth(double logicalWidth, double dpr, {int maxPx = 2048}) {
  if (!logicalWidth.isFinite || logicalWidth <= 0 || !dpr.isFinite || dpr <= 0) return null;
  const step = 128;
  final px = ((logicalWidth * dpr) / step).ceil() * step;
  return px.clamp(step, maxPx);
}

/// عرض فك صورة التفاصيل (عرض الشاشة) — نفس القيمة للتحميل المسبق وللعرض كي يطابق مفتاح الكاش.
int? largeImageCacheWidth(BuildContext context) =>
    productImageCacheWidth(MediaQuery.sizeOf(context).width, MediaQuery.devicePixelRatioOf(context));

/// تحميل مسبق لصورة التفاصيل عند الضغط على البطاقة. يفشل بصمت (ويب/ويندوز/CORS).
void precacheProductImage(BuildContext context, String? url) {
  if (url == null || url.isEmpty) return;
  final w = largeImageCacheWidth(context);
  final ImageProvider provider = w == null ? NetworkImage(url) : ResizeImage(NetworkImage(url), width: w);
  precacheImage(provider, context, onError: (_, __) {});
}

/// صورة منتج قابلة للطيران بين الشاشات مع تحويل ناعم لنصف قطر الحواف.
/// [tag] = null ⇒ قص بالحواف فقط بلا Hero. عند تقليل الحركة يُعطَّل Hero (تلاشي الصفحة فقط).
class ProductHero extends StatelessWidget {
  const ProductHero({super.key, required this.tag, required this.radius, required this.child});

  final Object? tag;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final body = _HeroBody(radius: radius, child: child);
    if (tag == null) return body;
    return HeroMode(
      enabled: !MotionSettings.of(context).reduceMotion,
      child: Hero(tag: tag!, flightShuttleBuilder: _shuttle, child: body),
    );
  }

  static Widget _shuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    final from = (fromContext.widget as Hero).child;
    final to = (toContext.widget as Hero).child;
    if (from is! _HeroBody || to is! _HeroBody) return (toContext.widget as Hero).child;
    // الصورة العليا (الأكبر/المحمّلة مسبقًا) هي التي تطير كي تبقى حادة.
    final top = direction == HeroFlightDirection.push ? to : from;
    final bottom = direction == HeroFlightDirection.push ? from : to;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        child: top.child,
        builder: (_, child) => ClipRRect(
          borderRadius: BorderRadius.circular(lerpDouble(bottom.radius, top.radius, animation.value) ?? top.radius),
          child: child,
        ),
      ),
    );
  }
}

class _HeroBody extends StatelessWidget {
  const _HeroBody({required this.radius, required this.child});

  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      radius <= 0 ? child : ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
}
