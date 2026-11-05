import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/pressable.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/motion/entrance.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/utils/haptics.dart';

/// اختيار الدور: بطاقتان كبيرتان، نقرة واحدة تختار وتتابع. يُحفظ الدور فلا يُسأل ثانية.
class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  Future<void> _pick(String role, String route) async {
    Haptics.tap();
    await Get.find<SessionStore>().setChosenRole(role);
    Get.toNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _NotebookPainter(line: c.ln, margin: c.coral.withValues(alpha: .35)))),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Entrance(index: 0, child: Center(child: ExcludeSemantics(child: SizedBox(width: 150, height: 110, child: CustomPaint(painter: _BooksPainter(c)))))),
                  const SizedBox(height: 20),
                  Entrance(index: 1, child: Semantics(header: true, child: Text(l.roleTitle, textAlign: TextAlign.center, style: T.d2(c.tx)))),
                  const SizedBox(height: 8),
                  Entrance(index: 1, child: Text(l.roleSubtitle, textAlign: TextAlign.center, style: T.bd(c.tx2))),
                  const SizedBox(height: 28),
                  Entrance(
                    index: 2,
                    child: _RoleCard(
                      icon: 'bag',
                      title: l.roleCustomer,
                      sub: l.roleCustomerSub,
                      fill: c.plumSoft,
                      border: c.pri,
                      chip: c.sf,
                      ink: c.plumInk,
                      onTap: () => _pick('customer', '/auth/phone'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Entrance(
                    index: 3,
                    child: _RoleCard(
                      icon: 'truck',
                      title: l.roleDriver,
                      sub: l.roleDriverSub,
                      fill: c.amberSoft,
                      border: c.amber,
                      chip: c.sf,
                      ink: c.amberInk,
                      onTap: () => _pick('driver', '/driver/login'),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Entrance(index: 4, child: Text(l.roleLegal, textAlign: TextAlign.center, style: T.cap(c.tx3))),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.icon, required this.title, required this.sub, required this.fill, required this.border, required this.chip, required this.ink, required this.onTap});
  final String icon, title, sub;
  final Color fill, border, chip, ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Semantics(
      button: true,
      label: '$title. $sub',
      excludeSemantics: true,
      onTap: onTap,
      child: PressableScale(
        child: Material(
          color: fill,
          borderRadius: BorderRadius.circular(Rad.l),
          child: InkWell(
            borderRadius: BorderRadius.circular(Rad.l),
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 88),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Rad.l), border: Border.all(color: border, width: 1.5)),
              child: Row(children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: chip, borderRadius: BorderRadius.circular(Rad.m)),
                  child: Center(child: SIcon(icon, size: 28, color: ink)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text(title, style: T.h2(c.tx)),
                    const SizedBox(height: 2),
                    Text(sub, style: T.bd(c.tx2)),
                  ]),
                ),
                Icon(Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right, color: c.tx2),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// خلفية دفتر: سطور أفقية خافتة وهامش عمودي.
class _NotebookPainter extends CustomPainter {
  _NotebookPainter({required this.line, required this.margin});
  final Color line, margin;
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = line
      ..strokeWidth = 1;
    for (double y = 40; y < s.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), p);
    }
    final x = s.width * .88;
    canvas.drawLine(Offset(x, 0), Offset(x, s.height), Paint()
      ..color = margin
      ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_NotebookPainter o) => o.line != line || o.margin != margin;
}

/// كتب مكدّسة وقلم رصاص، من ألوان الرموز.
class _BooksPainter extends CustomPainter {
  _BooksPainter(this.c);
  final SatrColors c;

  @override
  void paint(Canvas canvas, Size s) {
    void book(double y, double w, double x, Color fill, Color edge) {
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, 24), const Radius.circular(5));
      canvas.drawRRect(r, Paint()..color = fill);
      canvas.drawRRect(
          r,
          Paint()
            ..color = edge
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
      canvas.drawLine(
          Offset(x + 10, y + 12),
          Offset(x + w - 10, y + 12),
          Paint()
            ..color = edge
            ..strokeWidth = 1.5);
    }

    book(s.height - 26, 120, 10, c.plumSoft, c.pri);
    book(s.height - 52, 100, 22, c.amberSoft, c.amber);
    book(s.height - 78, 84, 14, c.coralSoft, c.coral);
    canvas.save();
    canvas.translate(s.width - 30, s.height - 80);
    canvas.rotate(.7);
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(-5, -52, 10, 52), const Radius.circular(2));
    canvas.drawRRect(body, Paint()..color = c.amber);
    canvas.drawRect(const Rect.fromLTWH(-5, -52, 10, 8), Paint()..color = c.coral);
    final tip = Path()
      ..moveTo(-5, 0)
      ..lineTo(5, 0)
      ..lineTo(0, 12)
      ..close();
    canvas.drawPath(tip, Paint()..color = c.sf3);
    canvas.drawPath(
        Path()
          ..moveTo(-1.8, 7)
          ..lineTo(1.8, 7)
          ..lineTo(0, 12)
          ..close(),
        Paint()..color = c.pri);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BooksPainter o) => o.c != c;
}
