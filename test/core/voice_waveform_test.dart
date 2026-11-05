import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/widgets/voice_waveform.dart';

void main() {
  group('WaveformBuffer', () {
    test('keeps the newest samples in order, oldest first', () {
      final b = WaveformBuffer(4);
      for (final v in [.1, .2, .3, .4, .5, .6]) {
        b.push(v);
      }
      expect(b.length, 4);
      expect([for (var i = 0; i < 4; i++) b.target(i)], [
        closeTo(.3, 1e-6), closeTo(.4, 1e-6), closeTo(.5, 1e-6), closeTo(.6, 1e-6),
      ]);
    });

    test('partially filled: newest at the end, the rest reads 0; clamps input', () {
      final b = WaveformBuffer(4)..push(2)..push(-1);
      expect(b.length, 2);
      expect([for (var i = 0; i < 4; i++) b.target(i)], [0, 0, 1, 0]);
      b.clear();
      expect(b.length, 0);
    });
  });

  group('LevelSmoother', () {
    const s = LevelSmoother(attack: Duration(milliseconds: 30), release: Duration(milliseconds: 180));

    test('rises fast, falls slowly, never overshoots', () {
      final up = s.next(0, 1, .03);
      final down = s.next(1, 0, .03);
      expect(up, closeTo(1 - 0.36788, 1e-3)); // one attack time constant
      expect(1 - down, lessThan(up)); // release moved less than attack
      var v = 0.0;
      for (var i = 0; i < 100; i++) {
        v = s.next(v, .8, 1 / 30);
        expect(v, lessThanOrEqualTo(.8));
      }
      expect(v, closeTo(.8, 1e-3));
    });

    test('zero dt does not move', () => expect(s.next(.4, 1, 0), .4));
  });

  group('FrameThrottle', () {
    int emitted(int hz) {
      final t = FrameThrottle(const Duration(microseconds: 33333));
      var n = 0;
      for (var i = 0; i < hz; i++) {
        if (t.shouldEmit(Duration(microseconds: (i * 1e6 / hz).round()))) n++;
      }
      return n;
    }

    test('caps 60/120/144 Hz ticks at ~30 fps', () {
      expect(emitted(60), inInclusiveRange(29, 31));
      expect(emitted(120), inInclusiveRange(29, 31));
      expect(emitted(144), inInclusiveRange(28, 31));
    });

    test('slower ticks pass through', () => expect(emitted(20), 20));
  });
}
