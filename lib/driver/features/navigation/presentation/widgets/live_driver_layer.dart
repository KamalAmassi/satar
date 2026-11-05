import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/tokens.dart';

class LiveDriverLayer extends StatelessWidget {
  const LiveDriverLayer({
    super.key,
    required this.position,
    this.heading = 0.0,
    this.pulse = true,
  });

  final LatLng position;
  final double heading;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return MarkerLayer(
      markers: [
        Marker(
          point: position,
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (pulse)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.coral.withValues(alpha: 0.25),
                  ),
                ),
              Transform.rotate(
                angle: heading * (3.141592653589793 / 180),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.pri,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: c.shadow.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SIcon('truck', size: 20, color: c.onPri),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
