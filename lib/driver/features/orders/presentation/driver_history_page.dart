import 'package:flutter/material.dart';
import 'package:project/core/data/models.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/common_widgets.dart';

/// سجل المهام: GET /driver/orders/history. منقولة من
/// d1d6084:lib/features/driver/driver.dart (DriverHistoryScreen).
class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});
  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  List<DriverOrderModel>? list;
  Failure? f;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await backend.driverHistory();
    if (!mounted) return;
    r.fold((e) => setState(() => f = e), (v) => setState(() => list = v));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    return Page2(
      tab: 'hist',
      role: TabRole.driver,
      top: BigHeadTop(eyebrow: l.driverHistoryEyebrow, title: l.driverHistoryTitle),
      onRefresh: _load,
      body: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: list == null
            ? (f == null
                ? Column(children: [for (var i = 0; i < 3; i++) const Padding(padding: EdgeInsets.only(bottom: 8), child: Skel(h: 100, r: 20))])
                : EmptyState(ill: 'offline', title: l.driverLoadFailed, text: failureText(f!), cta: SBtn(l.commonRetry, full: true, onTap: _load)))
            : list!.isEmpty
                ? EmptyState(ill: 'books', title: l.driverNoPastTasks, text: l.driverNoPastTasksText)
                : Column(children: [
                    for (final o in list!) ...[
                      Card2(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(o.code, style: T.cap(c.tx2)), StatusPill(o.status.key, label: statusLabel(o.status))]),
                          const SizedBox(height: 8),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('${o.dropoff.label ?? o.dropoff.line} · ${l.driverDistanceKm(o.distanceKm.toStringAsFixed(1))}', style: T.h3(c.tx, size: 15)),
                            Mny(o.earning.amount),
                          ]),
                          const SizedBox(height: 8),
                          Text(timeLabel(o.createdAt), style: T.sm(c.tx2)),
                        ]),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ]),
      ),
    );
  }
}
