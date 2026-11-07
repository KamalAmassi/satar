import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/motion/motion_settings.dart';
import 'package:project/core/widgets/auth_header.dart' show AuthRole;

/// قالب شاشات الدخول (اختيار الدور، دخول الزبون والسائق، رمز التحقق):
/// رأس بلون سطر يحمل الشعار، وورقة فاتحة تتداخل معه وتحمل المحتوى، وتذييل ثابت.
/// عند فتح لوحة مفاتيح النظام ينكمش الرأس إلى شعار صغير ليبقى الحقل والزر ظاهرين.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.body,
    this.foot,
    this.role,
    this.tagline,
    this.tall = false,
    this.showBack = true,
    this.onBack,
  });

  final Widget body;
  final Widget? foot;

  /// شارة الدور في الرأس؛ null = بلا شارة (شاشة اختيار الدور).
  final AuthRole? role;
  final String? tagline;

  /// رأس أطول (شاشة اختيار الدور).
  final bool tall;
  final bool showBack;
  final VoidCallback? onBack;

  static const _overlap = 28.0;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    // يُقرأ هنا فوق Scaffold: Scaffold يُصفّر viewInsets لجسمه عند resizeToAvoidBottomInset.
    final mq = MediaQuery.of(context);
    final keyboard = mq.viewInsets.bottom > 0;
    final reduce = MotionSettings.of(context).reduceMotion;
    final dur = reduce ? Duration.zero : const Duration(milliseconds: 240);
    final screenH = mq.size.height;
    final heroBody = keyboard
        ? 58.0
        : tall
            ? (screenH * .34).clamp(250.0, 330.0)
            : (screenH * .30).clamp(224.0, 290.0);
    final heroH = mq.padding.top + heroBody + _overlap;
    final heroBg = c.dark ? c.hero : c.pri;
    final ink = c.dark ? c.onHero : c.hero;
    final canBack = showBack && (onBack != null || (ModalRoute.of(context)?.canPop ?? false));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: c.bg,
        resizeToAvoidBottomInset: true,
        body: Stack(children: [
          AnimatedPositioned(
            duration: dur,
            curve: Curves.easeOutCubic,
            top: 0,
            left: 0,
            right: 0,
            height: heroH,
            child: _Hero(
              bg: heroBg,
              ink: ink,
              topInset: mq.padding.top,
              compact: keyboard,
              tall: tall,
              role: role,
              tagline: keyboard ? null : tagline,
              onBack: canBack ? (onBack ?? () => Get.back()) : null,
              dur: dur,
            ),
          ),
          AnimatedPositioned(
            duration: dur,
            curve: Curves.easeOutCubic,
            top: heroH - _overlap,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(color: c.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(26))),
              child: Column(children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                    child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: body)),
                  ),
                ),
                if (foot != null) foot!,
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.bg,
    required this.ink,
    required this.topInset,
    required this.compact,
    required this.tall,
    required this.role,
    required this.tagline,
    required this.onBack,
    required this.dur,
  });

  final Color bg, ink;
  final double topInset;
  final bool compact, tall;
  final AuthRole? role;
  final String? tagline;
  final VoidCallback? onBack;
  final Duration dur;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final logoH = compact ? 40.0 : (tall ? 108.0 : 96.0);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      child: ColoredBox(
        color: bg,
        child: CustomPaint(
          painter: _RulePainter(ink.withValues(alpha: .07)),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, topInset + (compact ? 4 : 8), 16, AuthShell._overlap + (compact ? 6 : 18)),
            child: Column(children: [
              SizedBox(
                height: 44,
                child: Row(children: [
                  if (onBack != null)
                    Semantics(
                      button: true,
                      label: MaterialLocalizations.of(context).backButtonTooltip,
                      child: Material(
                        color: ink.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: onBack,
                          child: SizedBox.square(dimension: 44, child: Center(child: SIcon('back', size: 22, color: ink))),
                        ),
                      ),
                    ),
                  if (compact) ...[
                    // لوحة المفاتيح مفتوحة: شعار صغير في منتصف الشريط بدل الشعار الكبير.
                    Expanded(child: Center(child: SatrLogo(height: 30, color: ink))),
                    const SizedBox(width: 44),
                  ] else ...[
                    const Spacer(),
                    if (role != null) _RolePill(role: role!, ink: ink, label: role == AuthRole.driver ? l.roleDriver : l.roleCustomer),
                  ],
                ]),
              ),
              if (!compact)
                Expanded(
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: logoH),
                      duration: dur,
                      curve: Curves.easeOutCubic,
                      builder: (context, h, child) => SatrLogo(height: h, color: ink),
                    ),
                  ),
                ),
              if (tagline != null) ...[
                Text(tagline!, textAlign: TextAlign.center, style: T.sm(ink.withValues(alpha: .84))),
                const SizedBox(height: 4),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role, required this.ink, required this.label});
  final AuthRole role;
  final Color ink;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 12, 6),
      decoration: BoxDecoration(color: ink.withValues(alpha: .14), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        SIcon(role == AuthRole.driver ? 'truck' : 'bag', size: 16, color: ink),
        const SizedBox(width: 6),
        Text(label, style: T.sm(ink, w: FontWeight.w600)),
      ]),
    );
  }
}

/// شعار سطر من الأصل الموجود، مقصوصًا من هوامشه ومُلوّنًا بلون [color].
class SatrLogo extends StatelessWidget {
  const SatrLogo({super.key, required this.height, required this.color});
  final double height;
  final Color color;

  // الرسم يشغل نحو 80% × 49% من مربع الصورة (500×500) في منتصفه.
  static const _wf = .8, _hf = .49;

  @override
  Widget build(BuildContext context) {
    final full = height / _hf;
    return Semantics(
      image: true,
      label: 'سطر',
      child: SizedBox(
        height: height,
        width: full * _wf,
        child: ClipRect(
          child: OverflowBox(
            minWidth: full,
            maxWidth: full,
            minHeight: full,
            maxHeight: full,
            child: Image.asset('assets/images/Satr_logo.png', width: full, height: full, color: color, colorBlendMode: BlendMode.srcIn, filterQuality: FilterQuality.medium),
          ),
        ),
      ),
    );
  }
}

/// سطور دفتر خافتة في الرأس.
class _RulePainter extends CustomPainter {
  _RulePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double y = 31; y < s.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_RulePainter o) => o.color != color;
}

/// عنوان ووصف الورقة في شاشات الدخول.
class AuthTitle extends StatelessWidget {
  const AuthTitle({super.key, required this.title, this.subtitle});
  final String title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Semantics(header: true, child: Text(title, style: T.h1(c.tx))),
      if (subtitle != null) ...[
        const SizedBox(height: 6),
        DefaultTextStyle.merge(style: T.bd(c.tx2), child: subtitle!),
      ],
    ]);
  }
}
