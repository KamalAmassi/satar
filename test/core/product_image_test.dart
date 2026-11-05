import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/widgets/image_viewer.dart';
import 'package:project/core/widgets/product_hero.dart';

void main() {
  group('productHeroTag', () {
    test('is scoped and unique per scope', () {
      expect(productHeroTag('home', 7), 'product-image:home:7');
      expect(productHeroTag('home', 7), isNot(productHeroTag('grid', 7)));
      expect(productHeroTag('home', 7), isNot(productHeroTag('home', 8)));
    });

    test('sanitizes empty scopes and colons', () {
      expect(productHeroTag('  ', 1), 'product-image:default:1');
      expect(productHeroTag('a:b', 1), 'product-image:a-b:1');
    });
  });

  group('productImageCacheWidth', () {
    test('buckets to 128px steps and caps at 2048', () {
      expect(productImageCacheWidth(150, 3), 512); // 450 → 512
      expect(productImageCacheWidth(10, 1), 128);
      expect(productImageCacheWidth(2000, 3), 2048);
    });

    test('unknown width → null', () {
      expect(productImageCacheWidth(double.infinity, 2), isNull);
      expect(productImageCacheWidth(0, 2), isNull);
    });
  });

  group('zoom clamping', () {
    test('clampScale stays within 1..4', () {
      expect(ViewerMath.clampScale(.5), 1);
      expect(ViewerMath.clampScale(10), 4);
      expect(ViewerMath.clampScale(double.nan), 1);
      expect(ViewerMath.clampScale(2.5), 2.5);
    });

    test('zoomAt keeps the focal point fixed and clamps scale', () {
      const focal = Offset(120, 300);
      final m = ViewerMath.zoomAt(focal, 2.5);
      final mapped = MatrixUtils.transformPoint(m, focal);
      expect(mapped.dx, closeTo(focal.dx, 1e-6));
      expect(mapped.dy, closeTo(focal.dy, 1e-6));
      expect(ViewerMath.zoomAt(focal, 99).getMaxScaleOnAxis(), closeTo(4, 1e-9));
    });
  });

  group('dismiss threshold', () {
    const h = 800.0;
    test('distance or fling dismisses, small drags do not', () {
      expect(ViewerMath.shouldDismiss(offset: 100, velocity: 0, extent: h), isFalse);
      expect(ViewerMath.shouldDismiss(offset: 150, velocity: 0, extent: h), isTrue);
      expect(ViewerMath.shouldDismiss(offset: -150, velocity: 0, extent: h), isTrue);
      expect(ViewerMath.shouldDismiss(offset: 20, velocity: 1200, extent: h), isTrue);
      expect(ViewerMath.shouldDismiss(offset: 500, velocity: 0, extent: 0), isFalse);
    });

    test('drag progress and scale are clamped', () {
      expect(ViewerMath.dragProgress(0, h), 0);
      expect(ViewerMath.dragProgress(10000, h), 1);
      expect(ViewerMath.dragScale(1), closeTo(ViewerMath.minDragScale, 1e-9));
      expect(ViewerMath.dragScale(0), 1);
    });
  });
}
