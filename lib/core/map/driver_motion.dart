import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// منطق حركة السائق على الخريطة (نقي وقابل للاختبار).
abstract final class DriverMotion {
  /// قفزة أبعد من هذا (أول موقع، أو انقطاع طويل) تُعرض مباشرة بلا انزلاق.
  static const maxGlideMeters = 2000.0;

  /// أقل مسافة لاستنتاج الاتجاه من نقطتين (تتجاهل ارتعاش GPS).
  static const minBearingMeters = 3.0;

  /// اتجاه أيقونة 'nav' في رسمها الأصلي (تشير للشمال الشرقي).
  static const iconBearing = 45.0;

  /// مساحة حلقات النبض نسبةً لقطر نقطة السائق.
  static const ringExtentFactor = 2.6;

  static const _distance = Distance();

  static double meters(LatLng a, LatLng b) => _distance.as(LengthUnit.Meter, a, b);
}

/// يطبّع الزاوية إلى [0, 360).
double normalizeDeg(double d) => ((d % 360) + 360) % 360;

/// أقصر فرق زاوي من [from] إلى [to] في (-180, 180].
double shortestAngleDelta(double from, double to) {
  final d = normalizeDeg(to - from);
  return d > 180 ? d - 360 : d;
}

/// استيفاء زاوي عبر أقصر طريق، والنتيجة مطبّعة.
double lerpAngle(double from, double to, double t) =>
    normalizeDeg(from + shortestAngleDelta(from, to) * t.clamp(0.0, 1.0));

/// استيفاء خطي للموقع (يعبر خط الطول 180 بالطريق الأقصر).
LatLng lerpLatLng(LatLng a, LatLng b, double t) {
  final k = t.clamp(0.0, 1.0);
  var dLng = b.longitude - a.longitude;
  if (dLng > 180) dLng -= 360;
  if (dLng < -180) dLng += 360;
  var lng = a.longitude + dLng * k;
  if (lng > 180) lng -= 360;
  if (lng < -180) lng += 360;
  return LatLng(a.latitude + (b.latitude - a.latitude) * k, lng);
}

/// الاتجاه (0 = شمال، باتجاه عقارب الساعة) من [a] إلى [b]، أو null إن كانت الحركة أقصر من [minMeters].
double? bearingBetween(LatLng a, LatLng b, {double minMeters = DriverMotion.minBearingMeters}) {
  if (DriverMotion.meters(a, b) < minMeters) return null;
  final lat1 = a.latitudeInRad, lat2 = b.latitudeInRad;
  final dLng = (b.longitude - a.longitude) * math.pi / 180;
  final y = math.sin(dLng) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
  return normalizeDeg(math.atan2(y, x) * 180 / math.pi);
}

enum DriverFreshness { live, stale, none }

/// حداثة موقع السائق.
abstract final class DriverStaleness {
  /// يطابق TrackingModel.isStale (دقيقتان).
  static const threshold = Duration(minutes: 2);

  /// [seenAt] = null مع وجود موقع ⇒ حداثة غير معروفة، تُعامل كمباشرة.
  static DriverFreshness of({
    required bool hasLocation,
    required DateTime now,
    DateTime? seenAt,
    Duration limit = threshold,
  }) {
    if (!hasLocation) return DriverFreshness.none;
    if (seenAt == null) return DriverFreshness.live;
    return now.difference(seenAt) >= limit ? DriverFreshness.stale : DriverFreshness.live;
  }

  /// دقائق منذ آخر موقع (لا تقل عن صفر عند اختلاف ساعة الخادم).
  static int minutesAgo(DateTime seenAt, DateTime now) => math.max(0, now.difference(seenAt).inMinutes);
}
