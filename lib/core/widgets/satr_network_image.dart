import 'package:flutter/material.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/motion.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/widgets/product_hero.dart';

/// صورة الشبكة الوحيدة في التطبيق: عنصر نائب ورقي أثناء التحميل، ظهور تدريجي،
/// فك ترميز بحجم الصندوق، وبديل (أيقونة كتاب أو [fallback]) عند غياب الرابط أو فشله.
class SatrNetworkImage extends StatelessWidget {
  const SatrNetworkImage({
    super.key,
    required this.url,
    this.semanticLabel,
    this.fit = BoxFit.cover,
    this.radius,
    this.decodeWidth,
    this.fallback,
  });

  /// رابط مطلق (يُحَل النسبي عند التحليل: resolveImageUrl).
  final String? url;
  final String? semanticLabel;
  final BoxFit fit;
  final double? radius;
  final int? decodeWidth;

  /// بديل مخصص؛ الافتراضي أيقونة كتاب على لون ورقي.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final fb = fallback ??
        ColoredBox(color: c.sf2, child: Center(child: SIcon('book', size: 28, color: c.tx3)));
    Widget child;
    final u = url;
    if (u == null || u.isEmpty) {
      child = fb;
    } else {
      child = LayoutBuilder(builder: (context, box) {
        final w = decodeWidth ?? productImageCacheWidth(box.maxWidth, MediaQuery.devicePixelRatioOf(context));
        return Image.network(
          u,
          fit: fit,
          cacheWidth: w,
          semanticLabel: semanticLabel,
          excludeFromSemantics: semanticLabel == null,
          errorBuilder: (_, __, ___) => fb,
          frameBuilder: (_, img, frame, sync) => sync
              ? img
              : Stack(fit: StackFit.expand, children: [
                  ColoredBox(color: c.sf2),
                  AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: Motion.imageFade, curve: Curves.easeOut, child: img),
                ]),
        );
      });
    }
    if (radius != null) child = ClipRRect(borderRadius: BorderRadius.circular(radius!), child: child);
    return child;
  }
}
