import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project/core/widgets/satr_network_image.dart';
import 'package:flutter/services.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/motion.dart';
import 'package:project/core/design/pressable.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/core/widgets/product_hero.dart';

/// ===== مكوّنات التصميم المعتمد (ui.js + app.css) =====

String fmtMinor(num minor, {String symbol = '₪'}) =>
    '$symbol ${(minor / 100).toStringAsFixed(2)}';

/// مبلغ بخط عريض واتجاه LTR (‎.mny).
class Mny extends StatelessWidget {
  const Mny(this.minor, {super.key, this.size, this.color, this.strike = false, this.weight = FontWeight.w700, this.symbol = '₪'});
  final num minor;
  final double? size;
  final Color? color;
  final bool strike;
  final FontWeight weight;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Text(
      fmtMinor(minor, symbol: symbol),
      textDirection: TextDirection.ltr,
      style: TextStyle(
        fontFamily: Fonts.ui,
        fontSize: size ?? 16,
        height: 1.4,
        fontWeight: strike ? FontWeight.w500 : weight,
        color: strike ? c.tx3 : (color ?? c.tx),
        decoration: strike ? TextDecoration.lineThrough : null,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// رقم بخط tabular واتجاه LTR (.num).
class Num extends StatelessWidget {
  const Num(this.text, {super.key, this.style});
  final String text;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) => Text(text,
      textDirection: TextDirection.ltr,
      style: (style ?? T.sm(context.sc.tx)).copyWith(
          fontFeatures: const [FontFeature.tabularFigures()]));
}

enum BtnKind { pri, sec, ghost, warm, danger }

enum BtnSize { normal, sm, xs }

class SBtn extends StatelessWidget {
  const SBtn(this.label,
      {super.key,
      this.onTap,
      this.kind = BtnKind.pri,
      this.size = BtnSize.normal,
      this.icon,
      this.full = false,
      this.loading = false,
      this.disabled = false,
      this.hapticOnPress = true});

  final String label;
  final VoidCallback? onTap;
  final BtnKind kind;
  final BtnSize size;
  final String? icon;
  final bool full;
  final bool loading;
  final bool disabled;

  /// false للأزرار التي تُبلّغ نتيجة غير متزامنة: تستدعي هي Haptics.confirm/
  /// success/error بنفسها فلا تتكرر النبضة.
  final bool hapticOnPress;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final h = switch (size) { BtnSize.normal => 52.0, BtnSize.sm => 44.0, BtnSize.xs => 40.0 };
    final fs = switch (size) { BtnSize.normal => 16.0, BtnSize.sm => 14.5, BtnSize.xs => 14.0 };
    final px = switch (size) { BtnSize.normal => 22.0, BtnSize.sm => 16.0, BtnSize.xs => 14.0 };
    final r = size == BtnSize.xs ? 12.0 : Rad.m;
    final (bg, fg) = switch (kind) {
      BtnKind.pri => (c.pri, c.onPri),
      BtnKind.sec => (c.sf2, c.tx),
      BtnKind.ghost => (Colors.transparent, c.plumInk),
      BtnKind.warm => (c.amber, const Color(0xFF2A1626)),
      BtnKind.danger => (c.errSoft, c.errInk),
    };
    final off = disabled || onTap == null && !loading;
    final child = Row(
      mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
          )
        else ...[
          if (icon != null) ...[SIcon(icon!, size: 20, color: fg), const SizedBox(width: 8)],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  maxLines: 1,
                  style: TextStyle(
                      fontFamily: Fonts.ui,
                      fontSize: fs,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: fg)),
            ),
          ),
        ],
      ],
    );
    final live = !(off || loading);
    return Opacity(
      opacity: off ? .42 : 1,
      child: PressableScale(
        enabled: live,
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(r),
          child: InkWell(
            borderRadius: BorderRadius.circular(r),
            onTap: live ? () => Haptics.press(onTap!, haptic: hapticOnPress) : null,
            child: Container(
              constraints: BoxConstraints(minHeight: h, minWidth: full ? double.infinity : 0),
              padding: EdgeInsets.symmetric(horizontal: kind == BtnKind.ghost ? 12 : px),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class SIconBtn extends StatelessWidget {
  const SIconBtn(this.icon,
      {super.key, this.onTap, this.tonal = false, this.size = 24, this.badge, this.box = 48, this.bg, this.fg});
  final String icon;
  final VoidCallback? onTap;
  final bool tonal;
  final double size;
  final double box;
  final String? badge;
  final Color? bg;
  final Color? fg;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PressableScale(
            enabled: onTap != null,
            child: Material(
              color: bg ?? (tonal ? c.sf2 : Colors.transparent),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap == null ? null : () => Haptics.press(onTap!),
                child: SizedBox(
                  width: box,
                  height: box,
                  child: Center(child: SIcon(icon, size: size, color: fg ?? c.tx)),
                ),
              ),
            ),
          ),
          if (badge != null && badge!.isNotEmpty)
            PositionedDirectional(
              top: 5,
              start: 4,
              // تغيّر الرقم ⇒ نبضة تكبير قصيرة (بلا حركة عند تقليل الحركة).
              child: AnimatedSwitcher(
                duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false) ? Duration.zero : Motion.short,
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                child: Container(
                key: ValueKey(badge),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    color: c.coralTag, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text(badge!,
                    style: const TextStyle(
                        fontFamily: Fonts.ui,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SLink extends StatelessWidget {
  const SLink(this.text, {super.key, this.onTap, this.color});
  final String text;
  final VoidCallback? onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Text(text,
            style: TextStyle(
                fontFamily: Fonts.ui,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: color ?? c.plumInk,
                decoration: TextDecoration.underline,
                decorationThickness: 1.5,
                decorationColor: (color ?? c.plumInk).withValues(alpha: .35))),
      ),
    );
  }
}

class SChip extends StatelessWidget {
  const SChip(this.label, {super.key, this.on = false, this.icon, this.onTap, this.leading, this.height = 40});
  final String label;
  final bool on;
  final String? icon;
  final VoidCallback? onTap;
  final Widget? leading;
  final double height;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final fg = on ? c.onPri : c.tx;
    return PressableScale(
      enabled: onTap != null,
      child: Material(
        color: on ? c.pri : c.sf2,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap == null
              ? null
              : () {
                  Haptics.select();
                  onTap!();
                },
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              if (icon != null) ...[SIcon(icon!, size: 18, color: fg), const SizedBox(width: 6)],
              Text(label,
                  style: TextStyle(
                      fontFamily: Fonts.ui,
                      fontSize: 14.5,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                      color: fg)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// حالات الطلب: (النغمة، الاسم) كما في TONE.
const Map<String, (String, String)> kStatusTone = {
  'awaiting_pricing': ('wait', 'بانتظار تسعير المكتبة'),
  'priced': ('act', 'عرض السعر جاهز'),
  'pending': ('prog', 'تم اعتماد السعر'),
  'awaiting_payment': ('act', 'بانتظار الدفع'),
  'payment_review': ('wait', 'الدفع قيد المراجعة'),
  'preparing': ('prog', 'قيد التحضير'),
  'ready_for_delivery': ('prog', 'جاهز للتوصيل'),
  'accepted': ('prog', 'السائق في الطريق للمكتبة'),
  'picked_up': ('prog', 'استلم السائق الطلب'),
  'on_the_way': ('prog', 'في الطريق إليك'),
  'arrived': ('prog', 'وصل السائق'),
  'delivery_failed': ('err', 'تعذّر التسليم'),
  'delivered': ('ok', 'تم التسليم'),
  'cancelled': ('err', 'ملغي'),
};

class StatusPill extends StatelessWidget {
  const StatusPill(this.statusKey, {super.key, this.label, this.tone, this.fallbackLabel});
  final String statusKey;
  final String? label;
  final String? tone;
  final String? fallbackLabel;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final t = tone ?? kStatusTone[statusKey]?.$1 ?? 'x';
    final txt = label ?? kStatusTone[statusKey]?.$2 ?? fallbackLabel ?? statusKey;
    final (bg, fg) = switch (t) {
      'wait' => (c.amberSoft, c.amberInk),
      'act' => (c.coralSoft, c.coralInk),
      'prog' => (c.plumSoft, c.plumInk),
      'ok' => (c.okSoft, c.okInk),
      'err' => (c.errSoft, c.errInk),
      _ => (c.sf2, c.tx2),
    };
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Text(txt, style: TextStyle(fontFamily: Fonts.ui, fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }
}

class STag extends StatelessWidget {
  const STag(this.text, {super.key, this.kind = 'coral'});
  final String text;
  /// coral | soft | gray | plum | err
  final String kind;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final (bg, fg) = switch (kind) {
      'soft' => (c.amberSoft, c.amberInk),
      'gray' => (c.sf3, c.tx2),
      'plum' => (c.plumSoft, c.plumInk),
      'err' => (c.errSoft, c.errInk),
      _ => (c.coralTag, Colors.white),
    };
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(fontFamily: Fonts.ui, fontSize: 12, fontWeight: FontWeight.w700, height: 1, color: fg)),
    );
  }
}

/// بنر داخل الصفحة (.note). [kind]: plum | warn | err | ok | cream
class Note extends StatelessWidget {
  const Note(this.kind, {super.key, this.title, this.text, this.icon, this.action, this.onActionTap, this.child, this.onTap, this.compact = false});
  final String kind;
  final String? title;
  final String? text;
  final String? icon;
  final String? action;
  final VoidCallback? onActionTap;
  final VoidCallback? onTap;
  final Widget? child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final (bg, fg) = switch (kind) {
      'warn' => (c.amberSoft, c.amberInk),
      'err' => (c.errSoft, c.errInk),
      'ok' => (c.okSoft, c.okInk),
      'cream' => (c.hero, c.onHero),
      _ => (c.plumSoft, c.plumInk),
    };
    final ic = icon ??
        switch (kind) { 'warn' => 'alert', 'err' => 'alertC', 'ok' => 'checkC', _ => 'info' };
    final style = TextStyle(fontFamily: Fonts.ui, fontSize: 14, height: 1.65, color: fg);
    final box = Container(
      padding: compact ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10) : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Rad.m)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: SIcon(ic, size: 20, color: fg)),
        const SizedBox(width: 12),
        Expanded(
          child: DefaultTextStyle(
            style: style,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (child != null) child!,
              if (child == null)
                Text.rich(TextSpan(children: [
                  if (title != null) TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (title != null && text != null) const TextSpan(text: ' '),
                  if (text != null) TextSpan(text: text),
                ])),
              if (action != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: InkWell(
                    onTap: onActionTap,
                    child: Text(action!,
                        style: style.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline)),
                  ),
                ),
            ]),
          ),
        ),
      ]),
    );
    return onTap == null ? box : InkWell(borderRadius: BorderRadius.circular(Rad.m), onTap: onTap, child: box);
  }
}

class Card2 extends StatelessWidget {
  const Card2({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color, this.onTap, this.clip = false});
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  final bool clip;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final deco = BoxDecoration(
        color: color ?? c.sf,
        borderRadius: BorderRadius.circular(Rad.l),
        boxShadow: c.cardShadow);
    final inner = Container(
        decoration: deco,
        clipBehavior: clip ? Clip.antiAlias : Clip.none,
        padding: padding,
        width: double.infinity,
        child: child);
    if (onTap == null) return inner;
    return PressableScale(child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: inner));
  }
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.color, this.padding = const EdgeInsets.all(16), this.onTap, this.radius = Rad.l});
  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final w = Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(color: color ?? c.sf2, borderRadius: BorderRadius.circular(radius)),
        child: child);
    return onTap == null ? w : PressableScale(child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: w));
  }
}

class HeroBox extends StatelessWidget {
  const HeroBox({super.key, required this.child, this.color, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Container(
      width: double.infinity,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: color ?? c.hero, borderRadius: BorderRadius.circular(Rad.xl)),
      child: DefaultTextStyle.merge(style: TextStyle(color: c.onHero), child: child),
    );
  }
}

class Divider2 extends StatelessWidget {
  const Divider2({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 2), color: context.sc.ln);
}

/// قيمة بصيغة (مفتاح ... قيمة) (.kv)
class KV extends StatelessWidget {
  const KV(this.k, this.v, {super.key, this.total = false, this.vWidget});
  final String k;
  final String? v;
  final Widget? vWidget;
  final bool total;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text(k,
                style: TextStyle(
                    fontFamily: Fonts.ui,
                    fontSize: total ? 18 : 15,
                    fontWeight: total ? FontWeight.w700 : FontWeight.w400,
                    color: total ? c.tx : c.tx2,
                    height: 1.6))),
        const SizedBox(width: 12),
        vWidget ?? Text(v ?? '', style: TextStyle(fontFamily: Fonts.ui, fontSize: total ? 18 : 15, fontWeight: total ? FontWeight.w700 : FontWeight.w400, color: c.tx)),
      ],
    );
    if (!total) return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: row);
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.ln))),
      child: row,
    );
  }
}

class PriceBox extends StatelessWidget {
  const PriceBox({super.key, required this.rows, required this.totalMinor, this.totalLabel = 'الإجمالي'});
  final List<(String, Widget)> rows;
  final num totalMinor;
  final String totalLabel;
  @override
  Widget build(BuildContext context) => Panel(
          child: Column(children: [
        for (final r in rows) KV(r.$1, null, vWidget: r.$2),
        KV(totalLabel, null, total: true, vWidget: Mny(totalMinor, size: 18)),
      ]));
}

class Stepper2 extends StatelessWidget {
  const Stepper2({super.key, required this.value, this.onInc, this.onDec, this.lg = false, this.min = 1, this.maxed = false});
  final int value;
  final VoidCallback? onInc;
  final VoidCallback? onDec;
  final bool lg;
  final int min;
  final bool maxed;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = AppLocalizations.of(context);
    final d = lg ? 46.0 : 40.0;
    // منطقة لمس ≥ 48dp مع بقاء الدائرة المرئية بنفس الحجم.
    final hit = lg ? 52.0 : 48.0;
    Widget b(String icon, String? label, VoidCallback? fn, bool atLimit) {
      final dis = fn == null || atLimit;
      return Semantics(
        button: true,
        enabled: !dis,
        label: label,
        excludeSemantics: true,
        onTap: dis ? null : fn,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // عند الحد يبقى الزر قابلًا للمس ليعطي إشارة خطأ فقط، دون تغيير القيمة.
          onTap: fn == null
              ? null
              : () {
                  if (atLimit) {
                    Haptics.error();
                    return;
                  }
                  Haptics.select();
                  fn();
                },
          child: PressableScale(
            enabled: !dis,
            child: SizedBox(
              width: hit,
              height: hit,
              child: Center(
                child: Opacity(
                  opacity: dis ? .35 : 1,
                  child: Container(
                    width: d,
                    height: d,
                    decoration: BoxDecoration(
                        color: c.sf, shape: BoxShape.circle, boxShadow: dis ? null : c.cardShadow),
                    child: Center(child: SIcon(icon, size: 18, color: c.tx)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        b('plus', l?.stepperIncrease, onInc, maxed),
        SizedBox(
            width: 38,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w700, fontSize: 16)
                      .copyWith(color: c.tx, fontFeatures: const [FontFeature.tabularFigures()])),
            )),
        b('minus', l?.stepperDecrease, onDec, value <= min),
      ]),
    );
  }
}

class Stars extends StatelessWidget {
  const Stars(this.n, {super.key, this.big = false, this.onPick});
  final int n;
  final bool big;
  final ValueChanged<int>? onPick;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 1; i <= 5; i++)
        Padding(
          padding: EdgeInsets.all(big ? 4 : 1.5),
          child: GestureDetector(
            onTap: onPick == null ? null : () => onPick!(i),
            child: SIcon('star', size: big ? 38 : (onPick == null ? 16 : 18), color: c.amber, filled: i <= n),
          ),
        ),
    ]);
  }
}

class Avatar extends StatelessWidget {
  const Avatar(this.text, {super.key, this.large = false, this.bg, this.fg, this.radius});
  final String text;
  final bool large;
  final Color? bg;
  final Color? fg;
  final double? radius;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final d = large ? 72.0 : 48.0;
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
          color: bg ?? c.hero,
          shape: radius == null ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: radius == null ? null : BorderRadius.circular(radius!)),
      alignment: Alignment.center,
      child: Text(text,
          style: TextStyle(fontFamily: Fonts.dis, fontWeight: FontWeight.w700, fontSize: large ? 28 : 18, color: fg ?? c.onHero)),
    );
  }
}

class SSwitch extends StatelessWidget {
  const SSwitch(this.on, {super.key, this.onChanged});
  final bool on;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      toggled: on,
      enabled: onChanged != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null
            ? null
            : () {
                Haptics.select();
                onChanged!(!on);
              },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 50, minHeight: 48),
          child: Center(
            widthFactor: 1,
            child: AnimatedContainer(
              duration: reduce ? Duration.zero : Motion.short,
              width: 50,
              height: 30,
              padding: const EdgeInsets.all(3),
              alignment: on ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
              decoration: BoxDecoration(color: on ? c.pri : c.sf3, borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    color: on ? c.onPri : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 3, offset: Offset(0, 1))]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SCheck extends StatelessWidget {
  const SCheck(this.on, {super.key, this.onTap});
  final bool on;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              Haptics.select();
              onTap!();
            },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
            color: on ? c.pri : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: on ? null : Border.all(color: c.tx3, width: 2)),
        child: on ? Center(child: SIcon('check', size: 16, color: c.onPri)) : null,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.ill, required this.title, required this.text, this.cta, this.illWidth = 170});
  final String ill;
  final String title;
  final String text;
  final Widget? cta;
  final double illWidth;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Ill(ill, width: illWidth),
        const SizedBox(height: 10),
        Text(title, textAlign: TextAlign.center, style: T.d2(c.tx, size: 26)),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontFamily: Fonts.ui, fontSize: 15, height: 1.7, color: c.tx2)),
        ),
        if (cta != null) ...[const SizedBox(height: 10), cta!],
      ]),
    );
  }
}

class SecHead extends StatelessWidget {
  const SecHead(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: T.h2(context.sc.tx, size: 19)),
          if (trailing != null) trailing!,
        ],
      );
}

/// عنصر قائمة (.li)
class LiTile extends StatelessWidget {
  const LiTile(this.icon, this.title, {super.key, this.sub, this.onTap, this.end, this.iconBg, this.first = true});
  final String icon;
  final String title;
  final String? sub;
  final VoidCallback? onTap;
  final Widget? end;
  final Color? iconBg;
  final bool first;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Container(
      decoration: BoxDecoration(border: first ? null : Border(top: BorderSide(color: c.ln))),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: iconBg ?? c.sf2, borderRadius: BorderRadius.circular(14)),
                child: Center(child: SIcon(icon, size: 22, color: c.plumInk))),
            const SizedBox(width: 14),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w600, fontSize: 15.5, height: 1.5, color: c.tx)),
              if (sub != null && sub!.isNotEmpty) Text(sub!, style: TextStyle(fontFamily: Fonts.ui, fontSize: 13.5, height: 1.5, color: c.tx2)),
            ])),
            const SizedBox(width: 14),
            end ?? SIcon('chevL', size: 20, color: c.tx3),
          ]),
        ),
      ),
    );
  }
}

/// بطاقة خيار (.opt-card): شعاع اختيار أو مربع.
class OptCard extends StatelessWidget {
  const OptCard({super.key, required this.on, required this.title, this.sub, this.icon, this.onTap, this.dis = false, this.trailing, this.check = true});
  final bool on;
  final String title;
  final String? sub;
  final String? icon;
  final VoidCallback? onTap;
  final bool dis;
  final Widget? trailing;
  final bool check;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final live = !dis && onTap != null;
    return Opacity(
      opacity: dis ? .5 : 1,
      child: PressableScale(
       enabled: live,
       child: Material(
        color: on ? c.plumSoft : c.sf,
        borderRadius: BorderRadius.circular(Rad.m),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rad.m),
          onTap: live
              ? () {
                  Haptics.select();
                  onTap!();
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Rad.m),
                border: Border.all(color: on ? c.pri : c.ln, width: on ? 2 : 1)),
            child: Row(children: [
              if (icon != null) ...[
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: on ? c.sf : c.sf2, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: SIcon(icon!, size: 22, color: c.plumInk))),
                const SizedBox(width: 12),
              ],
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w600, fontSize: 15.5, height: 1.5, color: c.tx)),
                if (sub != null) Text(sub!, style: T.sm(c.tx2)),
              ])),
              if (trailing != null) trailing!,
              if (check) ...[
                const SizedBox(width: 12),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: on ? c.pri : null,
                      border: on ? null : Border.all(color: c.tx3, width: 2)),
                  child: on ? Center(child: SIcon('check', size: 14, color: c.onPri)) : null,
                ),
              ],
            ]),
          ),
        ),
       ),
      ),
    );
  }
}

/// مربع اختيار عمودي (qgrid).
class OptTile extends StatelessWidget {
  const OptTile({super.key, required this.on, required this.label, required this.onTap, this.icon, this.child, this.dis = false, this.compact = false});
  final bool on;
  final String label;
  final VoidCallback? onTap;
  final String? icon;
  final Widget? child;
  final bool dis;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final live = !dis && onTap != null;
    return Opacity(
      opacity: dis ? .5 : 1,
      child: PressableScale(
       enabled: live,
       child: Material(
        color: on ? c.plumSoft : c.sf,
        borderRadius: BorderRadius.circular(Rad.m),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rad.m),
          onTap: live
              ? () {
                  Haptics.select();
                  onTap!();
                }
              : null,
          child: Container(
            constraints: BoxConstraints(minHeight: compact ? 0 : 98),
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: compact ? 6 : 14),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Rad.m),
                border: Border.all(color: on ? c.pri : c.ln, width: on ? 2 : 1)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (child != null) child! else if (icon != null) SIcon(icon!, size: 26, color: c.plumInk),
              const SizedBox(height: 8),
              Text(label, style: T.sm(c.tx, w: FontWeight.w600)),
            ]),
          ),
        ),
       ),
      ),
    );
  }
}

class Seg extends StatelessWidget {
  const Seg({super.key, required this.items, required this.value, required this.onChanged});
  final List<(String, String)> items;
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(Rad.m)),
      child: Row(children: [
        for (final it in items)
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (it.$1 != value) Haptics.select();
                onChanged(it.$1);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                    color: it.$1 == value ? c.sf : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: it.$1 == value ? c.cardShadow : null),
                alignment: Alignment.center,
                child: Text(it.$2,
                    style: TextStyle(
                        fontFamily: Fonts.ui,
                        fontSize: 14.5,
                        fontWeight: it.$1 == value ? FontWeight.w700 : FontWeight.w500,
                        color: it.$1 == value ? c.tx : c.tx2)),
              ),
            ),
          ),
      ]),
    );
  }
}

/// حقل نص (.fld)
class Fld extends StatefulWidget {
  const Fld({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.controller,
    this.pre,
    this.suffix,
    this.optional = false,
    this.maxLines = 1,
    this.ltr = false,
    this.keyboard,
    this.obscure = false,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.ok = false,
    this.maxLength,
    this.formatters,
    this.autofocus = false,
    this.textAlign,
    this.focusNode,
    this.textInputAction,
    this.autofillHints,
  });
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final TextEditingController? controller;
  final String? pre;
  final Widget? suffix;
  final bool optional;
  final int maxLines;
  final bool ltr;
  final TextInputType? keyboard;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool ok;
  final int? maxLength;
  final List<TextInputFormatter>? formatters;
  final bool autofocus;
  final TextAlign? textAlign;

  /// اختياري: للتحكم بترتيب التركيز من الخارج (لا يُتخلَّص منه هنا).
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  State<Fld> createState() => _FldState();
}

class _FldState extends State<Fld> {
  FocusNode? _own;
  FocusNode get _focus => widget.focusNode ?? (_own ??= FocusNode());
  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void didUpdateWidget(Fld old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _own)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final focused = _focus.hasFocus;
    final hasErr = widget.error != null && widget.error!.isNotEmpty;
    final ta = widget.maxLines > 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.label != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Text.rich(TextSpan(children: [
            TextSpan(text: widget.label, style: TextStyle(fontFamily: Fonts.ui, fontSize: 14, fontWeight: FontWeight.w600, color: c.tx)),
            if (widget.optional)
              TextSpan(text: '  اختياري', style: TextStyle(fontFamily: Fonts.ui, fontSize: 14, fontWeight: FontWeight.w400, color: c.tx3)),
          ])),
        ),
      Opacity(
        opacity: widget.enabled ? 1 : .5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: (focused || hasErr) ? c.sf : c.sf2,
            borderRadius: BorderRadius.circular(Rad.m),
            border: Border.all(
                color: hasErr ? c.err : (widget.ok ? c.ok : (focused ? c.pri : Colors.transparent)), width: 2),
            boxShadow: focused && !hasErr
                ? [BoxShadow(color: c.pri.withValues(alpha: .14), spreadRadius: 4, blurRadius: 0)]
                : null,
          ),
          child: Row(crossAxisAlignment: ta ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
            if (widget.pre != null) ...[
              Container(
                padding: const EdgeInsetsDirectional.only(end: 10),
                decoration: BoxDecoration(border: BorderDirectional(end: BorderSide(color: c.ln, width: 1.5))),
                child: Text(widget.pre!, textDirection: TextDirection.ltr, style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w600, color: c.tx2)),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                minLines: ta ? widget.maxLines : 1,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                obscureText: widget.obscure,
                keyboardType: widget.keyboard,
                textInputAction: widget.textInputAction,
                autofillHints: widget.autofillHints,
                inputFormatters: widget.formatters,
                textDirection: widget.ltr ? TextDirection.ltr : null,
                textAlign: widget.textAlign ?? (widget.ltr ? TextAlign.start : TextAlign.start),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                cursorColor: c.pri,
                style: TextStyle(fontFamily: Fonts.ui, fontSize: 16, fontWeight: FontWeight.w500, color: c.tx, height: ta ? 1.6 : 1.3),
                decoration: InputDecoration(
                  isCollapsed: false,
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  hintText: widget.hint,
                  hintStyle: TextStyle(fontFamily: Fonts.ui, fontSize: 16, fontWeight: FontWeight.w400, color: c.tx3),
                ),
              ),
            ),
            if (widget.suffix != null) widget.suffix!,
          ]),
        ),
      ),
      if (hasErr)
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SIcon('alertC', size: 16, color: c.dark ? c.err : c.errInk),
            const SizedBox(width: 6),
            Expanded(child: Text(widget.error!, style: TextStyle(fontFamily: Fonts.ui, fontSize: 13, height: 1.55, fontWeight: FontWeight.w500, color: c.dark ? c.err : c.errInk))),
          ]),
        )
      else if (widget.helper != null)
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(widget.helper!, style: TextStyle(fontFamily: Fonts.ui, fontSize: 13, height: 1.55, color: c.tx2)),
        ),
    ]);
  }
}

class FieldError extends StatelessWidget {
  const FieldError(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final col = c.dark ? c.err : c.errInk;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SIcon('alertC', size: 16, color: col),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: TextStyle(fontFamily: Fonts.ui, fontSize: 13, height: 1.55, fontWeight: FontWeight.w500, color: col))),
    ]);
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text(text, style: T.eyebrow(color ?? context.sc.tx2));
}

/// أداة الهيكل العظمي (.sk)
class Skel extends StatefulWidget {
  const Skel({super.key, this.w, this.h = 14, this.r = 10});
  final double? w;
  final double h;
  final double r;
  @override
  State<Skel> createState() => _SkelState();
}

class _SkelState extends State<Skel> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, __) => Container(
        width: widget.w,
        height: widget.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.r),
          gradient: LinearGradient(
            begin: Alignment(-1 + _ctl.value * 3, 0),
            end: Alignment(1 + _ctl.value * 3, 0),
            colors: [c.sf2, c.sf3, c.sf2],
            stops: const [.3, .5, .7],
          ),
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar(this.value, {super.key, this.color});
  final double value;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 6,
        child: Stack(children: [
          Container(color: c.sf3),
          FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              alignment: AlignmentDirectional.centerStart,
              child: Container(decoration: BoxDecoration(color: color ?? c.pri, borderRadius: BorderRadius.circular(3)))),
        ]),
      ),
    );
  }
}

class StepsBar extends StatelessWidget {
  const StepsBar({super.key, required this.step, required this.total, required this.labels});
  final int step;
  final int total;
  final List<String> labels;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Row(children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
                child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                        color: i < step - 1 ? c.pri : (i == step - 1 ? c.amber : c.sf3),
                        borderRadius: BorderRadius.circular(3)))),
          ],
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(labels[step - 1], style: TextStyle(fontFamily: Fonts.ui, fontSize: 12.5, fontWeight: FontWeight.w700, color: c.tx)),
          Text('الخطوة $step من $total', style: TextStyle(fontFamily: Fonts.ui, fontSize: 12.5, fontWeight: FontWeight.w500, color: c.tx2)),
        ]),
      ),
    ]);
  }
}

class TimelineItem {
  const TimelineItem(this.title, this.time, {this.done = false, this.cur = false, this.next = false, this.check = true});
  final String title;
  final String? time;
  final bool done;
  final bool cur;
  final bool next;
  final bool check;
}

class SatrTimeline extends StatelessWidget {
  const SatrTimeline(this.items, {super.key});
  final List<TimelineItem> items;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Column(children: [
      for (var i = 0; i < items.length; i++)
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              width: 24,
              child: Column(children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: items[i].cur ? c.amber : (items[i].done ? c.pri : (items[i].next ? Colors.transparent : c.sf3)),
                    border: items[i].next ? Border.all(color: c.sf3, width: 2) : null,
                    boxShadow: items[i].cur ? [BoxShadow(color: c.amber.withValues(alpha: .28), spreadRadius: 5)] : null,
                  ),
                  child: (items[i].done && items[i].check) ? Center(child: SIcon('check', size: 14, color: c.onPri)) : null,
                ),
                if (i < items.length - 1)
                  Expanded(child: Container(width: 2, color: items[i].done ? c.pri : c.sf3)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: i < items.length - 1 ? 20 : 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(items[i].title,
                      style: TextStyle(fontFamily: Fonts.ui, fontSize: 15, height: 1.5, fontWeight: items[i].next ? FontWeight.w500 : FontWeight.w600, color: items[i].next ? c.tx3 : c.tx)),
                  if (items[i].time != null)
                    Text(items[i].time!, textDirection: TextDirection.ltr, textAlign: TextAlign.start, style: T.sm(c.tx2).copyWith(fontSize: 13)),
                ]),
              ),
            ),
          ]),
        ),
    ]);
  }
}

/// مؤقّت عدّ تنازلي (data-timer).
class CountdownText extends StatefulWidget {
  const CountdownText(this.seconds, {super.key, this.onDone, this.style});
  final int seconds;
  final VoidCallback? onDone;
  final TextStyle? style;
  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  late int _left = widget.seconds;
  Timer? _t;
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_left <= 0) {
        _t?.cancel();
        return;
      }
      setState(() => _left--);
      if (_left == 0) widget.onDone?.call();
    });
  }

  @override
  void didUpdateWidget(covariant CountdownText old) {
    super.didUpdateWidget(old);
    if (old.seconds != widget.seconds) _left = widget.seconds;
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = (_left ~/ 60).toString().padLeft(2, '0');
    final s = (_left % 60).toString().padLeft(2, '0');
    return Text('$m:$s',
        textDirection: TextDirection.ltr,
        style: (widget.style ?? const TextStyle(fontWeight: FontWeight.w700)).copyWith(fontFeatures: const [FontFeature.tabularFigures()]));
  }
}

class PagerDots extends StatelessWidget {
  const PagerDots(this.index, this.count, {super.key});
  final int index;
  final int count;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (var i = 0; i < count; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == index ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(color: i == index ? c.pri : c.sf3, borderRadius: BorderRadius.circular(4)),
        ),
    ]);
  }
}

/// خانات رمز التحقق (.otp)
class OtpBoxes extends StatelessWidget {
  const OtpBoxes({super.key, required this.digits, this.length = 4, this.bad = false, this.current = true});
  final String digits;
  final int length;
  final bool bad;
  final bool current;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Container(
            width: 62,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bad ? c.errSoft : (i == digits.length && current ? c.sf : c.sf2),
              borderRadius: BorderRadius.circular(Rad.m),
              border: Border.all(color: bad ? c.err : (i == digits.length && current ? c.pri : Colors.transparent), width: 2),
              boxShadow: (i == digits.length && current && !bad)
                  ? [BoxShadow(color: c.pri.withValues(alpha: .14), spreadRadius: 4)]
                  : null,
            ),
            child: Text(i < digits.length ? digits[i] : '',
                style: TextStyle(fontFamily: Fonts.ui, fontSize: 28, fontWeight: FontWeight.w700, color: c.tx)),
          ),
        ],
      ]),
    );
  }
}

/// لوحة الأرقام (.keypad)
class Keypad extends StatelessWidget {
  const Keypad({super.key, required this.onKey, this.disabled = false});
  final ValueChanged<String> onKey;
  final bool disabled;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return Container(
      color: c.sf2,
      padding: EdgeInsets.fromLTRB(20, 10, 20, 6 + MediaQuery.of(context).padding.bottom),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: [
            for (final k in keys)
              k.isEmpty
                  ? const SizedBox()
                  : Opacity(
                      opacity: disabled ? .42 : 1,
                      child: Material(
                        color: c.sf,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: disabled ? null : () => onKey(k),
                          child: Center(child: Text(k, style: TextStyle(fontFamily: Fonts.ui, fontSize: 22, fontWeight: FontWeight.w600, color: c.tx))),
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}

class CodeBox extends StatelessWidget {
  const CodeBox(this.code, {super.key, this.bg, this.size = 28});
  final String code;
  final Color? bg;
  final double size;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: bg ?? c.sf2, borderRadius: BorderRadius.circular(Rad.m)),
      child: Text(code.split('').join(' '),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: TextStyle(fontFamily: Fonts.ui, fontSize: size, fontWeight: FontWeight.w700, letterSpacing: 4, color: c.tx)),
    );
  }
}

class LiveDot extends StatefulWidget {
  const LiveDot({super.key, this.color});
  final Color? color;
  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final _ctl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final col = widget.color ?? context.sc.ok;
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, __) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(shape: BoxShape.circle, color: col, boxShadow: [
          BoxShadow(color: col.withValues(alpha: (1 - _ctl.value).clamp(0, .6)), spreadRadius: _ctl.value * 8),
        ]),
      ),
    );
  }
}

class PinDot extends StatelessWidget {
  const PinDot({super.key, this.color});
  final Color? color;
  @override
  Widget build(BuildContext context) =>
      Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color ?? context.sc.ok));
}

/// صورة مصغّرة للمنتج (.thumb)
class ProdThumb extends StatelessWidget {
  const ProdThumb({super.key, this.imageUrl, required this.name, this.seed = 0, this.size = 64, this.heroTag});
  final String? imageUrl;
  final String name;
  final int seed;
  final double size;

  /// وسم Hero اختياري (انظر productHeroTag).
  final Object? heroTag;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: ProductHero(tag: heroTag, radius: Rad.m, child: ProductArt(imageUrl: imageUrl, name: name, seed: seed, semanticLabel: name.isEmpty ? null : name)),
      );
}

/// صورة المنتج من الخادم إن وُجدت، وإلا الرسم البديل المعتمد.
/// عنصر نائب هادئ ثم ظهور تدريجي بعد التحميل، وفك ترميز بحجم العرض فقط.
class ProductArt extends StatelessWidget {
  const ProductArt({super.key, this.imageUrl, required this.name, this.seed = 0, this.fit = false, this.decodeWidth, this.semanticLabel});
  final String? imageUrl;
  final String name;
  final int seed;
  final bool fit;

  /// عرض فك الترميز بالبكسل؛ null ⇒ يُحسب من عرض التخطيط.
  final int? decodeWidth;
  final String? semanticLabel;
  @override
  Widget build(BuildContext context) {
    final fallback = ProductCover(kind: ProductCover.kindFor(name), tone: ProductCover.toneFor(seed), fit: fit);
    return SatrNetworkImage(url: imageUrl, semanticLabel: semanticLabel, decodeWidth: decodeWidth, fallback: fallback);
  }
}

/// مربع إسقاط الملفات (.drop) بحدود متقطعة.
class DropZone extends StatelessWidget {
  const DropZone({super.key, required this.icon, required this.title, this.sub, this.onTap, this.compact = false});
  final String icon;
  final String title;
  final String? sub;
  final VoidCallback? onTap;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashPainter(c.pri.withValues(alpha: .28)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: compact ? 16 : 24, horizontal: 16),
          decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(Rad.l)),
          child: Column(children: [
            SIcon(icon, size: compact ? 26 : 30, color: c.tx),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: compact ? T.sm(c.tx, w: FontWeight.w600) : T.h3(c.tx)),
            if (sub != null) Text(sub!, textAlign: TextAlign.center, style: T.sm(c.tx2)),
          ]),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(Rad.l)).deflate(1));
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 6), p);
        d += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

/// سطر ملف طباعة/إشعار (.file)
class FileRow extends StatelessWidget {
  const FileRow({super.key, required this.name, required this.ext, this.meta, this.progress, this.error, this.state = 'ready', this.onAction, this.actionLabel, this.onRemove, this.onCancel});
  final String name;
  final String ext;
  final String? meta;
  final double? progress;
  final String? error;
  /// ready | up | bad | int
  final String state;
  final VoidCallback? onAction;
  final String? actionLabel;
  final VoidCallback? onRemove;
  final VoidCallback? onCancel;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final bad = state == 'bad' || state == 'int';
    final img = ext != 'PDF';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: bad ? c.errSoft : c.sf,
          borderRadius: BorderRadius.circular(Rad.m),
          border: bad ? null : Border.all(color: c.ln)),
      child: Row(children: [
        Container(
          width: 46,
          height: 56,
          decoration: BoxDecoration(color: img ? c.plumSoft : c.hero, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: img
              ? SIcon('image', size: 22, color: c.plumInk)
              : Text(ext, style: TextStyle(fontFamily: Fonts.ui, fontSize: 11, fontWeight: FontWeight.w700, color: c.onHero)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, textDirection: TextDirection.ltr, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w600, fontSize: 15, height: 1.4, color: c.tx)),
            if (state == 'ready' && meta != null) Text(meta!, style: T.sm(c.tx2).copyWith(fontSize: 13)),
            if (state == 'up') ...[
              Padding(padding: const EdgeInsets.only(top: 6, bottom: 2), child: ProgressBar(progress ?? 0)),
              Text(meta ?? '', style: T.sm(c.tx2).copyWith(fontSize: 13)),
            ],
            if (bad && error != null) FieldError(error!),
          ]),
        ),
        if (state == 'ready') ...[
          SIcon('checkC', size: 24, color: c.ok),
          if (onRemove != null) SIconBtn('trash', size: 20, box: 40, onTap: onRemove),
        ],
        if (state == 'up' && onCancel != null) SIconBtn('x', size: 20, box: 40, onTap: onCancel),
        if (bad && actionLabel != null) SBtn(actionLabel!, size: BtnSize.xs, kind: BtnKind.sec, onTap: onAction),
      ]),
    );
  }
}
