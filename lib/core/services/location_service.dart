import 'package:geolocator/geolocator.dart';

enum LocationIssue { none, serviceDisabled, denied, deniedForever }

/// غلاف بسيط حول geolocator.
class LocationService {
  Future<LocationIssue> checkAndRequest() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationIssue.serviceDisabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationIssue.deniedForever;
    }
    if (permission == LocationPermission.denied) return LocationIssue.denied;
    return LocationIssue.none;
  }

  Future<Position?> current() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
    await Geolocator.openLocationSettings();
  }
}
