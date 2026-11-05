import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/design/pressable.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/utils/haptics.dart';

void main() {
  late List<HapticKind> fired;
  late List<VoidCallback> scheduled;

  setUp(() {
    Haptics.resetForTest();
    fired = [];
    scheduled = [];
    var t = Duration.zero;
    Haptics.clock = () => t += const Duration(seconds: 1); // every call is outside the gap
    Haptics.schedule = (d, fn) {
      scheduled.add(fn);
      return () => scheduled.remove(fn);
    };
    Haptics.platformSupported = () => true;
    Haptics.sink = fired.add;
  });

  tearDown(Haptics.resetForTest);

  Widget host(Widget child, {bool reduceMotion = false}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: Scaffold(body: Center(child: child)),
        ),
      );

  group('SBtn hapticOnPress', () {
    testWidgets('default: one light tap on press', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(SBtn('ok', onTap: () => taps++)));
      await tester.tap(find.text('ok'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(fired, [HapticKind.light]);
    });

    testWidgets('false: no press haptic, the result haptic fires exactly once', (tester) async {
      await tester.pumpWidget(host(SBtn('send', hapticOnPress: false, onTap: Haptics.error)));
      await tester.tap(find.text('send'));
      await tester.pumpAndSettle();
      expect(fired, [HapticKind.heavy]);
    });

    testWidgets('true + synchronous result: the result wins, no double fire', (tester) async {
      await tester.pumpWidget(host(SBtn('add', onTap: Haptics.confirm)));
      await tester.tap(find.text('add'));
      await tester.pumpAndSettle();
      expect(fired, [HapticKind.medium]);
    });

    testWidgets('disabled / loading buttons are silent', (tester) async {
      await tester.pumpWidget(host(Column(children: [
        SBtn('a', disabled: true, onTap: () {}),
        SBtn('b', loading: true, onTap: () {}),
      ])));
      await tester.tap(find.text('a'), warnIfMissed: false);
      await tester.tap(find.byType(CircularProgressIndicator), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300)); // spinner never settles
      expect(fired, isEmpty);
    });
  });

  group('Stepper2', () {
    testWidgets('select on change, error at the limit without changing value', (tester) async {
      var inc = 0, dec = 0;
      await tester.pumpWidget(host(Stepper2(value: 1, maxed: true, onInc: () => inc++, onDec: () => dec++)));
      final buttons = find.byType(GestureDetector);
      await tester.tap(buttons.first); // plus while maxed
      await tester.pumpAndSettle();
      await tester.tap(buttons.last); // minus at min (1)
      await tester.pumpAndSettle();
      expect(inc, 0);
      expect(dec, 0);
      expect(fired, [HapticKind.heavy, HapticKind.heavy]);
    });

    testWidgets('normal change gives a selection click', (tester) async {
      var inc = 0;
      await tester.pumpWidget(host(Stepper2(value: 2, onInc: () => inc++, onDec: () {})));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(inc, 1);
      expect(fired, [HapticKind.selection]);
    });

    testWidgets('touch targets are at least 48dp', (tester) async {
      await tester.pumpWidget(host(Stepper2(value: 2, onInc: () {}, onDec: () {})));
      for (final e in find.byType(GestureDetector).evaluate()) {
        final s = tester.getSize(find.byWidget(e.widget));
        expect(s.width, greaterThanOrEqualTo(48));
        expect(s.height, greaterThanOrEqualTo(48));
      }
    });
  });

  group('PressableScale', () {
    // MaterialApp's page transition also uses ScaleTransition: look only inside PressableScale.
    final ours = find.descendant(of: find.byType(PressableScale), matching: find.byType(ScaleTransition));

    testWidgets('scales down while pressed and springs back', (tester) async {
      await tester.pumpWidget(host(PressableScale(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}, child: const SizedBox(width: 100, height: 100)))));
      final scale = tester.widget<ScaleTransition>(ours).scale;
      final g = await tester.startGesture(tester.getCenter(find.byType(PressableScale)));
      await tester.pumpAndSettle();
      expect(scale.value, closeTo(.97, .001));
      await g.up();
      await tester.pumpAndSettle();
      expect(scale.value, 1);
    });

    testWidgets('moving past touch slop (scroll) releases the press', (tester) async {
      await tester.pumpWidget(host(PressableScale(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}, child: const SizedBox(width: 100, height: 100)))));
      final scale = tester.widget<ScaleTransition>(ours).scale;
      final g = await tester.startGesture(tester.getCenter(find.byType(PressableScale)));
      await tester.pumpAndSettle();
      await g.moveBy(const Offset(0, 40));
      await tester.pumpAndSettle();
      expect(scale.value, 1);
      await g.up();
    });

    testWidgets('reduce motion: no animation at all', (tester) async {
      await tester.pumpWidget(host(PressableScale(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}, child: const SizedBox(width: 100, height: 100))), reduceMotion: true));
      expect(ours, findsNothing);
    });
  });
}
