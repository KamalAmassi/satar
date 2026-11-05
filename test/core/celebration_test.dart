import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/celebration/celebration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemStore implements CelebrationStore {
  final keys = <String>[];
  @override
  bool contains(String key) => keys.contains(key);
  @override
  void add(String key, int capacity) {
    keys
      ..remove(key)
      ..add(key);
    if (keys.length > capacity) keys.removeRange(0, keys.length - capacity);
  }
}

void main() {
  group('CelebrationGuard', () {
    test('runs once per key (rebuilds / route re-entry)', () {
      final g = CelebrationGuard();
      expect(g.shouldRun('order-placed:1'), isTrue);
      expect(g.shouldRun('order-placed:1'), isFalse);
      expect(g.shouldRun('order-placed:1'), isFalse);
      expect(g.shouldRun('order-placed:2'), isTrue);
    });

    test('persisted keys survive a new session; non-persisted do not', () {
      final store = _MemStore();
      CelebrationGuard(store: store)
        ..shouldRun('order-delivered:7', persist: true)
        ..shouldRun('order-placed:7');
      final next = CelebrationGuard(store: store);
      expect(next.shouldRun('order-delivered:7', persist: true), isFalse);
      expect(next.shouldRun('order-placed:7'), isTrue);
    });

    test('prefs store keeps only the newest N keys', () async {
      SharedPreferences.setMockInitialValues({});
      final store = PrefsCelebrationStore(await SharedPreferences.getInstance());
      final g = CelebrationGuard(store: store, capacity: 3);
      for (var i = 0; i < 5; i++) {
        g.shouldRun('k$i', persist: true);
      }
      expect(store.contains('k0'), isFalse);
      expect(store.contains('k1'), isFalse);
      expect(store.contains('k4'), isTrue);
    });
  });

  group('particles', () {
    List<Object> flat(List<Particle> ps) => [
          for (final p in ps) ...[p.kind, p.vx, p.vy, p.drift, p.wobble, p.rotation, p.spin, p.size, p.delay, p.life, p.colorIndex],
        ];

    test('deterministic with the fixed seed', () {
      final a = generateParticles(count: 48, colors: 4, seconds: 2.45);
      final b = generateParticles(count: 48, colors: 4, seconds: 2.45);
      expect(flat(a), flat(b));
      final c = generateParticles(count: 48, colors: 4, seconds: 2.45, seed: 1);
      expect(flat(a), isNot(flat(c)));
    });

    test('capped, upward, and finished before the burst ends', () {
      expect(generateParticles(count: 500, colors: 4, seconds: 2.45).length, CelebrationConfig.hardCap);
      expect(generateParticles(count: 0, colors: 4, seconds: 2.45), isEmpty);
      for (final p in generateParticles(count: 48, colors: 4, seconds: 2.45)) {
        expect(p.vy, lessThan(0)); // ينطلق للأعلى
        expect(p.delay + p.life, lessThanOrEqualTo(2.45));
        expect(p.colorIndex, inInclusiveRange(0, 3));
      }
    });

    test('intensity scales the count; zero means no burst', () {
      expect(CelebrationConfig.particleCount(1), CelebrationConfig.maxParticles);
      expect(CelebrationConfig.particleCount(0), 0);
    });
  });
}
