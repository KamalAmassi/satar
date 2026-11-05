import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project/core/design/motion.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/map/driver_motion.dart';

/// شريحة الحالة/الوصول فوق خريطة التتبع (بنمط Note الكريمي الحالي).
/// تعرض الحالة نصًا دائمًا (ليس بالحركة فقط) وتعيد فحص القِدم كل [Motion.freshnessRecheck].
class DriverStatusChip extends StatefulWidget {
  const DriverStatusChip({super.key, required this.hasLocation, this.seenAt, this.etaMinutes, this.live = true});

  final bool hasLocation;
  final DateTime? seenAt;
  final int? etaMinutes;

  /// false بعد انتهاء الطلب ⇒ لا تُعرض.
  final bool live;

  @override
  State<DriverStatusChip> createState() => _DriverStatusChipState();
}

class _DriverStatusChipState extends State<DriverStatusChip> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(Motion.freshnessRecheck, (_) {
      if (mounted) setState(() {}); // الشريحة فقط
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.live) return const SizedBox.shrink();
    final c = context.sc;
    final l = context.l10n;
    final now = DateTime.now();
    final f = DriverStaleness.of(hasLocation: widget.hasLocation, seenAt: widget.seenAt, now: now);
    final eta = widget.etaMinutes;
    final text = switch (f) {
      DriverFreshness.live => eta == null ? l.driverLocationLive : '${l.driverLocationLive} · ${l.driverEtaShort(eta)}',
      DriverFreshness.stale => l.driverLocationStale(DriverStaleness.minutesAgo(widget.seenAt!, now)),
      DriverFreshness.none => l.driverLocationNone,
    };
    return Semantics(
      container: true,
      label: text,
      child: ExcludeSemantics(
        child: Note(
          'cream',
          icon: f == DriverFreshness.live ? null : 'alert',
          child: Row(children: [
            if (f == DriverFreshness.live) ...[const LiveDot(), const SizedBox(width: 12)],
            Expanded(child: Text(text, style: T.sm(c.tx))),
          ]),
        ),
      ),
    );
  }
}
