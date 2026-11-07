import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/pressable.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/motion/entrance.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/core/widgets/auth_shell.dart';

/// اختيار الدور: بطاقتان قابلتان للاختيار ثم «متابعة». يُحفظ الدور فلا يُسأل ثانية.
class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  String? _role;

  void _select(String role) {
    if (_role == role) return;
    Haptics.select();
    setState(() => _role = role);
  }

  Future<void> _continue() async {
    final role = _role;
    if (role == null) return;
    Haptics.tap();
    await Get.find<SessionStore>().setChosenRole(role);
    Get.toNamed(role == 'driver' ? '/driver/login' : '/auth/phone');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = AppLocalizations.of(context)!;
    final label = switch (_role) {
      'customer' => l.roleContinueAs(l.roleCustomer),
      'driver' => l.roleContinueAs(l.roleDriver),
      _ => l.rolePick,
    };
    return AuthShell(
      tall: true,
      showBack: false,
      tagline: l.roleTagline,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Entrance(index: 0, child: AuthTitle(title: l.roleTitle, subtitle: Text(l.roleSubtitle))),
        const SizedBox(height: 20),
        Semantics(
          container: true,
          label: l.rolePick,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Entrance(
              index: 1,
              child: _RoleCard(icon: 'bag', title: l.roleCustomer, sub: l.roleCustomerSub, selected: _role == 'customer', onTap: () => _select('customer')),
            ),
            const SizedBox(height: 12),
            Entrance(
              index: 2,
              child: _RoleCard(icon: 'truck', title: l.roleDriver, sub: l.roleDriverSub, selected: _role == 'driver', onTap: () => _select('driver')),
            ),
          ]),
        ),
      ]),
      foot: Foot(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SBtn(label, full: true, disabled: _role == null, onTap: _continue),
          const SizedBox(height: 8),
          Text(l.roleLegal, textAlign: TextAlign.center, style: T.cap(c.tx2)),
        ]),
      ),
    );
  }
}

/// بطاقة دور قابلة للاختيار: أيقونة + عنوان + وصف + مؤشر اختيار.
class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.icon, required this.title, required this.sub, required this.selected, required this.onTap});
  final String icon, title, sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    const dur = Duration(milliseconds: 160);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: '$title. $sub',
      excludeSemantics: true,
      onTap: onTap,
      child: PressableScale(
        child: Material(
          color: c.sf,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: AnimatedContainer(
              duration: dur,
              constraints: const BoxConstraints(minHeight: 88),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: selected ? c.pri : c.ln, width: selected ? 2 : 1.5),
                boxShadow: selected ? [BoxShadow(color: c.shadow.withValues(alpha: .18), blurRadius: 24, offset: const Offset(0, 10), spreadRadius: -12)] : null,
              ),
              child: Row(children: [
                AnimatedContainer(
                  duration: dur,
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: selected ? c.pri : c.hero, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: SIcon(icon, size: 28, color: selected ? c.onPri : c.onHero)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text(title, style: T.h2(c.tx, size: 18)),
                    const SizedBox(height: 2),
                    Text(sub, style: T.sm(c.tx2)),
                  ]),
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: dur,
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? c.pri : Colors.transparent,
                    border: Border.all(color: selected ? c.pri : c.tx3, width: 2),
                  ),
                  child: selected ? Center(child: SIcon('check', size: 15, color: c.onPri)) : null,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
