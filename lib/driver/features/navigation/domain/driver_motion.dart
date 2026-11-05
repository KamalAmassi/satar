import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

class DriverMotionState {
  const DriverMotionState({required this.position, required this.heading, required this.isAnim});

  final LatLng position;
  final double heading;
  final bool isAnim;
}

abstract final class DriverMotionCalculator {
  static DriverMotionState interpolate({
    required LatLng fromPos,
    required LatLng toPos,
    required double fromHeading,
    required double toHeading,
    required double progress,
  }) {
    final lat = fromPos.latitude + (toPos.latitude - fromPos.latitude) * progress;
    final lng = fromPos.longitude + (toPos.longitude - fromPos.longitude) * progress;
    final hd = fromHeading + (toHeading - fromHeading) * progress;

    return DriverMotionState(
      position: LatLng(lat, lng),
      heading: hd,
      isAnim: progress > 0 && progress < 1,
    );
  }
}
