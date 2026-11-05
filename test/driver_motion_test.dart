import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:project/core/map/driver_motion.dart';

void main() {
  group('position interpolation', () {
    const a = LatLng(31.90, 35.20);
    const b = LatLng(31.92, 35.24);

    test('endpoints, midpoint and clamping', () {
      expect(lerpLatLng(a, b, 0), a);
      expect(lerpLatLng(a, b, 1), b);
      final m = lerpLatLng(a, b, .5);
      expect(m.latitude, closeTo(31.91, 1e-9));
      expect(m.longitude, closeTo(35.22, 1e-9));
      expect(lerpLatLng(a, b, 2), b);
      expect(lerpLatLng(a, b, -1), a);
    });

    test('crosses the antimeridian the short way', () {
      final m = lerpLatLng(const LatLng(0, 179), const LatLng(0, -179), .5);
      expect(m.longitude.abs(), closeTo(180, 1e-9));
    });
  });

  group('shortest-angle rotation', () {
    test('delta takes the short way round', () {
      expect(shortestAngleDelta(350, 10), closeTo(20, 1e-9));
      expect(shortestAngleDelta(10, 350), closeTo(-20, 1e-9));
      expect(shortestAngleDelta(0, 180), closeTo(180, 1e-9));
      expect(shortestAngleDelta(90, 90), 0);
    });

    test('lerpAngle wraps and normalizes', () {
      expect(lerpAngle(350, 10, .5), closeTo(0, 1e-9));
      expect(lerpAngle(10, 350, .5), closeTo(0, 1e-9));
      expect(lerpAngle(-90, 0, 1), closeTo(0, 1e-9));
      expect(normalizeDeg(-30), closeTo(330, 1e-9));
    });

    test('bearing from movement; jitter yields null', () {
      expect(bearingBetween(const LatLng(31.9, 35.2), const LatLng(31.91, 35.2))!, closeTo(0, .5)); // north
      expect(bearingBetween(const LatLng(31.9, 35.2), const LatLng(31.9, 35.21))!, closeTo(90, .5)); // east
      expect(bearingBetween(const LatLng(31.9, 35.2), const LatLng(31.900001, 35.2)), isNull);
    });
  });

  group('stale threshold', () {
    final now = DateTime(2026, 11, 3, 12);

    test('live below the threshold, stale at or after it', () {
      DriverFreshness at(Duration ago) => DriverStaleness.of(hasLocation: true, seenAt: now.subtract(ago), now: now);
      expect(at(const Duration(seconds: 119)), DriverFreshness.live);
      expect(at(const Duration(minutes: 2)), DriverFreshness.stale);
      expect(at(const Duration(minutes: 10)), DriverFreshness.stale);
    });

    test('no location → none; unknown time → live; future time → live', () {
      expect(DriverStaleness.of(hasLocation: false, now: now), DriverFreshness.none);
      expect(DriverStaleness.of(hasLocation: true, now: now), DriverFreshness.live);
      expect(DriverStaleness.of(hasLocation: true, seenAt: now.add(const Duration(minutes: 5)), now: now), DriverFreshness.live);
    });

    test('minutesAgo never goes negative', () {
      expect(DriverStaleness.minutesAgo(now.subtract(const Duration(minutes: 7, seconds: 30)), now), 7);
      expect(DriverStaleness.minutesAgo(now.add(const Duration(minutes: 3)), now), 0);
    });
  });
}
