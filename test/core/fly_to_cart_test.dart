import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/animations/fly_to_cart/cart_target.dart';
import 'package:project/core/animations/fly_to_cart/fly_to_cart.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/utils/haptics.dart';

void main() {
  final source = GlobalKey();

  Widget app({bool withTarget = true}) => MaterialApp(
        theme: ThemeData(extensions: const [SatrColors.light]),
        home: Scaffold(
          body: Stack(children: [
            if (withTarget) const Positioned(top: 10, right: 10, child: CartTargetAnchor(child: SizedBox(width: 48, height: 48))),
            Positioned(top: 300, left: 40, child: SizedBox(key: source, width: 120, height: 120)),
          ]),
        ),
      );

  setUp(() {
    CartTarget.resetForTest();
    Haptics.resetForTest();
    Haptics.platformSupported = () => false;
  });

  testWidgets('no visible cart icon: still flies to the fixed fallback point, then bumps', (tester) async {
    await tester.pumpWidget(app(withTarget: false));
    var arrived = 0;
    FlyToCart.run(tester.element(find.byType(Scaffold)), sourceKey: source, image: null, onArrived: () => arrived++);
    expect(FlyToCart.active, 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(arrived, 1);
    expect(FlyToCart.active, 0);
    expect(CartTarget.bumpTick.value, 1);
  });

  testWidgets('cart icon scrolled off-screen is ignored; fallback anchor is used', (tester) async {
    final off = GlobalKey();
    final fb = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: const [SatrColors.light]),
      home: Scaffold(
        body: Stack(children: [
          Positioned(top: -500, left: 0, child: CartTargetAnchor(child: SizedBox(key: off, width: 48, height: 48))),
          Positioned(bottom: 20, left: 40, child: CartTargetAnchor(fallback: true, child: SizedBox(key: fb, width: 100, height: 50))),
          Positioned(top: 300, left: 40, child: SizedBox(key: source, width: 120, height: 120)),
        ]),
      ),
    ));
    final screen = tester.getRect(find.byType(Scaffold));
    final r = CartTarget.rect(within: screen)!;
    expect(r, tester.getRect(find.byKey(fb)));
    expect(CartTarget.rect(), isNotNull);
  });

  testWidgets('missing source key: skipped safely', (tester) async {
    await tester.pumpWidget(app());
    var arrived = 0;
    FlyToCart.run(tester.element(find.byType(Scaffold)), sourceKey: GlobalKey(), image: null, onArrived: () => arrived++);
    expect(arrived, 1);
    expect(FlyToCart.active, 0);
  });

  testWidgets('max 3 concurrent flights; extras still arrive; overlays cleaned up', (tester) async {
    await tester.pumpWidget(app());
    final ctx = tester.element(find.byType(Scaffold));
    var arrived = 0;
    for (var i = 0; i < 5; i++) {
      FlyToCart.run(ctx, sourceKey: source, image: null, onArrived: () => arrived++);
    }
    expect(FlyToCart.active, 3);
    expect(arrived, 2); // الزائدان: بلا طيران، وصول فوري.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(arrived, 5);
    expect(FlyToCart.active, 0);
    expect(find.byType(IgnorePointer).evaluate().where((e) => e.widget is IgnorePointer && (e.widget as IgnorePointer).ignoring).length, lessThanOrEqualTo(1));
  });

  test('default style is bag, flight is 1100ms', () {
    expect(FlyStyle.values.first, FlyStyle.bag);
    expect(FlyToCartConfig.flightDuration, const Duration(milliseconds: 1100));
  });

  testWidgets('image style still works', (tester) async {
    await tester.pumpWidget(app());
    var arrived = 0;
    FlyToCart.run(tester.element(find.byType(Scaffold)), sourceKey: source, style: FlyStyle.image, onArrived: () => arrived++);
    expect(FlyToCart.active, 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(arrived, 1);
    expect(FlyToCart.active, 0);
  });

  testWidgets('reduce motion: no flight, no bump', (tester) async {
    await tester.pumpWidget(MediaQuery(data: const MediaQueryData(disableAnimations: true), child: app()));
    var arrived = 0;
    FlyToCart.run(tester.element(find.byType(Scaffold)), sourceKey: source, image: null, onArrived: () => arrived++);
    expect(arrived, 1);
    expect(FlyToCart.active, 0);
    expect(CartTarget.bumpTick.value, 0);
  });

  testWidgets('screen disposed mid-flight: no exception, counter released', (tester) async {
    await tester.pumpWidget(app());
    FlyToCart.run(tester.element(find.byType(Scaffold)), sourceKey: source, image: null);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(FlyToCart.active, 0);
  });
}
