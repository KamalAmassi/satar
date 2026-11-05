import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/data/models.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/common_widgets.dart';
import 'package:project/driver/features/orders/presentation/driver_page.dart' show cashMeter;

/// الأرباح: GET /driver/earnings?period= . منقولة من
/// d1d6084:lib/features/driver/driver.dart (DriverEarningsScreen).
class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});
  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  String period = 'week';
  EarningsModel? e;
  Failure? f;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await backend.driverEarnings(period);
    if (!mounted) return;
    r.fold(
      (x) => setState(() => f = x),
      (v) => setState(() {
        e = v;
        f = null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    final x = e;
    final maxV = x == null || x.series.isEmpty ? 1 : x.series.map((s) => s.$3.amount).fold<int>(1, (a, b) => b > a ? b : a);
    final days = l.driverWeekdayInitials.split(',');
    return Page2(
      tab: 'earn',
      role: TabRole.driver,
      top: BigHeadTop(eyebrow: l.driverEarningsEyebrow, title: l.driverEarningsTitle),
      onRefresh: _load,
      body: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Seg(
            items: [('day', l.driverPeriodDay), ('week', l.driverPeriodWeek), ('month', l.driverPeriodMonth)],
            value: period,
            onChanged: (p) {
              setState(() {
                period = p;
                e = null;
              });
              _load();
            },
          ),
          const SizedBox(height: 24),
          if (x == null)
            f == null ? const Skel(h: 160, r: 28) : EmptyState(ill: 'offline', title: l.driverLoadFailed, text: failureText(f!), cta: SBtn(l.commonRetry, full: true, onTap: _load))
          else ...[
            HeroBox(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(switch (period) { 'day' => l.driverEarningsOfDay, 'month' => l.driverEarningsOfMonth, _ => l.driverEarningsOfWeek }, style: T.cap(c.onHero.withValues(alpha: .75))),
                Mny(x.earnings.amount, size: 42, color: c.onHero),
                Row(children: [Text(l.driverTasksAndCash(x.orders), style: T.sm(c.onHero.withValues(alpha: .8))), Mny(x.cashCollected.amount, size: 14, color: c.onHero)]),
              ]),
            ),
            if (x.series.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card2(
                child: SizedBox(
                  height: 120,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    for (var i = 0; i < x.series.length && i < 31; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                            Flexible(
                              child: FractionallySizedBox(
                                heightFactor: (x.series[i].$3.amount / maxV).clamp(.04, 1.0),
                                child: Container(decoration: BoxDecoration(color: x.series[i].$3.amount == maxV ? c.pri : c.sf3, borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(4)))),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(x.series[i].$1 == null ? '' : (x.series.length <= 7 ? days[(x.series[i].$1!.weekday - 1) % days.length] : '${x.series[i].$1!.day}'), style: T.cap(c.tx2).copyWith(fontSize: 11.5)),
                          ]),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ],
          const SizedBox(height: 24),
          SBtn(l.driverCashAndSettlements, kind: BtnKind.sec, icon: 'wallet', full: true, onTap: () => Get.toNamed('/driver/cash')),
        ]),
      ),
    );
  }
}

/// النقد والتسويات: GET /driver/cash. منقولة من d1d6084:lib/features/driver/driver.dart (DriverCashScreen).
class DriverCashScreen extends StatefulWidget {
  const DriverCashScreen({super.key});
  @override
  State<DriverCashScreen> createState() => _DriverCashScreenState();
}

class _DriverCashScreenState extends State<DriverCashScreen> {
  CashModel? cash;
  Failure? f;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await backend.driverCash();
    if (!mounted) return;
    r.fold((x) => setState(() => f = x), (v) => setState(() => cash = v));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    final x = cash;
    return Page2(
      top: TopBar(title: l.driverCashTitle),
      onRefresh: _load,
      body: x == null
          ? (f == null ? const Skel(h: 160, r: 20) : EmptyState(ill: 'offline', title: l.driverLoadFailed, text: failureText(f!), cta: SBtn(l.commonRetry, full: true, onTap: _load)))
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Card2(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  cashMeter(context, x),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l.driverRemainingToLimit, style: T.sm(c.tx2)), Mny(x.remaining?.amount ?? (x.max.amount - x.onHand.amount))]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l.driverUnsettledOrders, style: T.sm(c.tx2)), Text('${x.unsettled}', style: const TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w700))]),
                ]),
              ),
              const SizedBox(height: 24),
              Note('plum', text: l.driverCashNote),
              const SizedBox(height: 24),
              SecHead(l.driverLastSettlements),
              const SizedBox(height: 8),
              if (x.settlements.isEmpty)
                Text(l.driverNoSettlements, style: T.sm(c.tx2))
              else
                Card2(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(children: [
                    for (final s in x.settlements)
                      Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(timeLabel(s.$1), style: T.sm(c.tx2)), Mny(s.$2.amount)])),
                  ]),
                ),
            ]),
    );
  }
}
