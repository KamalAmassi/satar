import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ساعة ومؤقتات وهمية: لا انتظار حقيقي ولا اعتماد على fake_async.
class FakeTime {
  Duration now = Duration.zero;
  final _tasks = <_Task>[];

  HapticCancel schedule(Duration d, VoidCallback fn) {
    final t = _Task(now + d, fn);
    _tasks.add(t);
    return () => t.cancelled = true;
  }

  void advance(Duration d) {
    final end = now + d;
    while (true) {
      final due = _tasks.where((t) => !t.cancelled && t.at <= end).toList()
        ..sort((a, b) => a.at.compareTo(b.at));
      if (due.isEmpty) break;
      final t = due.first;
      _tasks.remove(t);
      now = t.at;
      t.fn();
    }
    now = end;
  }

  void ms(int v) => advance(Duration(milliseconds: v));
}

class _Task {
  _Task(this.at, this.fn);
  final Duration at;
  final VoidCallback fn;
  bool cancelled = false;
}

void main() {
  late FakeTime time;
  late List<(int, HapticKind)> fired;

  setUp(() {
    Haptics.resetForTest();
    time = FakeTime();
    fired = [];
    Haptics.clock = () => time.now;
    Haptics.schedule = time.schedule;
    Haptics.platformSupported = () => true;
    Haptics.sink = (k) => fired.add((time.now.inMilliseconds, k));
  });

  tearDown(Haptics.resetForTest);

  group('debounce', () {
    test('two taps inside 80 ms produce one haptic', () {
      Haptics.tap();
      time.ms(40);
      Haptics.tap();
      expect(fired, [(0, HapticKind.light)]);
    });

    test('a tap after the gap fires again', () {
      Haptics.tap();
      time.ms(80);
      Haptics.select();
      expect(fired, [(0, HapticKind.light), (80, HapticKind.selection)]);
    });

    test('a result inside the gap is deferred, never dropped, and wins over later taps', () {
      Haptics.tap();
      time.ms(30);
      Haptics.confirm();
      time.ms(20);
      Haptics.tap(); // dropped: a result is pending
      time.ms(100);
      expect(fired, [(0, HapticKind.light), (80, HapticKind.medium)]);
    });

    test('a newer pending result replaces the older one', () {
      Haptics.tap();
      time.ms(10);
      Haptics.confirm();
      time.ms(10);
      Haptics.error();
      time.ms(200);
      expect(fired, [(0, HapticKind.light), (80, HapticKind.heavy)]);
    });

    test('success pattern: two impacts ~90 ms apart, other haptics wait for it', () {
      Haptics.success();
      time.ms(120);
      Haptics.tap(); // still inside the pattern window (0 + 90 + 80)
      time.ms(50);
      Haptics.tap(); // 170 ms: allowed
      expect(fired, [
        (0, HapticKind.light),
        (90, HapticKind.medium),
        (170, HapticKind.light),
      ]);
    });
  });

  group('press (hapticOnPress logic)', () {
    test('plain press gives one tap', () {
      var ran = false;
      Haptics.press(() => ran = true);
      expect(ran, isTrue);
      expect(fired, [(0, HapticKind.light)]);
    });

    test('a synchronous result inside the action replaces the press tap', () {
      Haptics.press(Haptics.confirm);
      time.ms(200);
      expect(fired, [(0, HapticKind.medium)]);
    });

    test('haptic: false fires nothing on press; the later result fires once', () {
      Haptics.press(() {}, haptic: false);
      time.ms(500); // network
      Haptics.error();
      time.ms(200);
      expect(fired, [(500, HapticKind.heavy)]);
    });
  });

  group('setting', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('defaults to enabled', () async {
      Haptics.init(await SharedPreferences.getInstance());
      expect(Haptics.enabled.value, isTrue);
    });

    test('is persisted and restored', () async {
      final prefs = await SharedPreferences.getInstance();
      Haptics.init(prefs);
      await Haptics.setEnabled(false);
      expect(prefs.getBool(Haptics.prefKey), isFalse);

      Haptics.enabled.value = true;
      Haptics.init(prefs);
      expect(Haptics.enabled.value, isFalse);
    });

    test('everything is a no-op when disabled', () async {
      Haptics.init(await SharedPreferences.getInstance());
      await Haptics.setEnabled(false);
      Haptics.tap();
      Haptics.select();
      Haptics.confirm();
      Haptics.error();
      Haptics.success();
      Haptics.press(() {});
      time.ms(500);
      expect(fired, isEmpty);
    });

    test('disabling cancels a pending result and the rest of a pattern', () async {
      Haptics.init(await SharedPreferences.getInstance());
      Haptics.success();
      await Haptics.setEnabled(false);
      time.ms(500);
      expect(fired, [(0, HapticKind.light)]);
    });

    test('enabling gives one confirming selection click', () async {
      Haptics.init(await SharedPreferences.getInstance());
      await Haptics.setEnabled(false);
      await Haptics.setEnabled(true);
      expect(fired, [(0, HapticKind.selection)]);
    });
  });

  test('unsupported platform (web / desktop) is silent', () {
    Haptics.platformSupported = () => false;
    Haptics.tap();
    Haptics.success();
    time.ms(500);
    expect(fired, isEmpty);
  });
}
