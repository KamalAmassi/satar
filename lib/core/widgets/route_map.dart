import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/widgets/live_driver_layer.dart';

/// خريطة حقيقية (OSM) بعلامات بتصميم المعتمد: المكتبة، وجهة التسليم، السائق.
class RouteMap extends StatelessWidget {
  const RouteMap({super.key, required this.height, this.pickup, this.drop, this.driver, this.tail = const [], this.radius = 0, this.driverHeading, this.driverSeenAt, this.live = true});
  final double height;
  final LatLng? pickup;
  final LatLng? drop;
  final LatLng? driver;
  final List<LatLng> tail;
  final double radius;

  /// اتجاه السائق بالدرجات إن توفر (وإلا يُستنتج من الحركة).
  final double? driverHeading;

  /// وقت آخر موقع للسائق (للقِدم والتعتيم).
  final DateTime? driverSeenAt;

  /// false بعد انتهاء الطلب: علامة بلا نبض.
  final bool live;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final pts = [if (pickup != null) pickup!, if (drop != null) drop!, if (driver != null) driver!];
    final center = pts.isEmpty ? const LatLng(31.9, 35.2) : LatLng(pts.map((p) => p.latitude).reduce((a, b) => a + b) / pts.length, pts.map((p) => p.longitude).reduce((a, b) => a + b) / pts.length);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 14, initialCameraFit: pts.length >= 2 ? CameraFit.coordinates(coordinates: pts, padding: const EdgeInsets.all(48), maxZoom: 16) : null, interactionOptions: const InteractionOptions(flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag)),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.project'),
            if (tail.length > 1) PolylineLayer(polylines: [Polyline(points: tail, color: c.pri, strokeWidth: 5)]),
            MarkerLayer(markers: [
              if (pickup != null) Marker(point: pickup!, width: 26, height: 26, child: Container(decoration: BoxDecoration(color: c.amber, borderRadius: BorderRadius.circular(8)), child: Center(child: SIcon('home', size: 16, color: c.amberInk)))),
              if (drop != null) Marker(point: drop!, width: 40, height: 46, alignment: Alignment.topCenter, child: SIcon('pin', size: 40, color: c.pri)),
            ]),
            // طبقة مستقلة: انزلاق السائق ونبضه لا يعيدان بناء العلامات الأخرى.
            if (driver != null) LiveDriverLayer(key: const ValueKey('live-driver'), position: driver!, heading: driverHeading, seenAt: driverSeenAt, live: live),
          ],
        ),
      ),
    );
  }
}
