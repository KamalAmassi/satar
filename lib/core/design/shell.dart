import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';

/// ThemeData مبني على الرموز المعتمدة.
abstract final class SatrTheme {
  static ThemeData build(Brightness b) {
    final c = b == Brightness.dark ? SatrColors.darkMode : SatrColors.light;
    final scheme = ColorScheme.fromSeed(seedColor: c.pri, brightness: b).copyWith(
      primary: c.pri,
      onPrimary: c.onPri,
      surface: c.sf,
      onSurface: c.tx,
      error: c.err,
      secondary: c.amber,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      fontFamily: Fonts.ui,
      extensions: [c],
      splashFactory: InkRipple.splashFactory,
      splashColor: c.pri.withValues(alpha: .06),
      highlightColor: Colors.transparent,
      dividerColor: c.ln,
      textSelectionTheme: TextSelectionThemeData(cursorColor: c.pri, selectionColor: c.pri.withValues(alpha: .2), selectionHandleColor: c.pri),
      textTheme: ThemeData(brightness: b).textTheme.apply(fontFamily: Fonts.ui, bodyColor: c.tx, displayColor: c.tx),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}

/// شريط علوي (tbar): رجوع + عنوان في الوسط + يمين.
class TopBar extends StatelessWidget {
  const TopBar({super.key, this.title = '', this.back = true, this.right, this.start = false, this.onBack, this.tonalBack = false});
  final String title;
  final bool back;
  final Widget? right;
  final bool start;
  final VoidCallback? onBack;
  final bool tonalBack;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          if (back)
            SIconBtn('back', tonal: tonalBack, onTap: onBack ?? () => Get.back())
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: start ? TextAlign.start : TextAlign.center,
                style: TextStyle(fontFamily: Fonts.ui, fontSize: 18, fontWeight: FontWeight.w700, color: c.tx)),
          ),
          right ?? const SizedBox(width: 48),
        ]),
      ),
    );
  }
}

/// عنوان كبير مع eyebrow (bigHeadTop).
class BigHeadTop extends StatelessWidget {
  const BigHeadTop({super.key, required this.eyebrow, required this.title, this.right});
  final String eyebrow;
  final String title;
  final Widget? right;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Eyebrow(eyebrow),
            Text(title, style: T.d2(c.tx)),
          ]),
          if (right != null) right!,
        ]),
      ),
    );
  }
}

class Foot extends StatelessWidget {
  const Foot({super.key, required this.child, this.transparent = false});
  final Widget child;
  final bool transparent;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        gradient: transparent
            ? null
            : LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [c.bg, c.bg, c.bg.withValues(alpha: 0)], stops: const [0, .78, 1]),
      ),
      child: child,
    );
  }
}

class FootBar extends StatelessWidget {
  const FootBar({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: c.sf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: c.upShadow,
      ),
      child: child,
    );
  }
}

enum TabRole { customer, driver }

/// صفحة التطبيق الأساسية (page): أعلى + جسم + تذييل + شريط تبويب.
class Page2 extends StatelessWidget {
  const Page2({
    super.key,
    this.top,
    required this.body,
    this.foot,
    this.tab,
    this.role = TabRole.customer,
    this.flush = false,
    this.center = false,
    this.bg,
    this.padding,
    this.floating,
    this.onRefresh,
    this.scroll = true,
  });
  final Widget? top;
  final Widget body;
  final Widget? foot;
  final String? tab;
  final TabRole role;
  final bool flush;
  final bool center;
  final Color? bg;
  final EdgeInsets? padding;
  final Widget? floating;
  final Future<void> Function()? onRefresh;
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final pad = padding ?? EdgeInsets.fromLTRB(flush ? 0 : 20, 4, flush ? 0 : 20, 28);
    Widget content = center
        ? Center(child: SingleChildScrollView(padding: pad, child: body))
        : (scroll ? SingleChildScrollView(padding: pad, physics: const AlwaysScrollableScrollPhysics(), child: body) : Padding(padding: pad, child: body));
    if (onRefresh != null && scroll && !center) {
      content = RefreshIndicator(onRefresh: onRefresh!, color: c.pri, backgroundColor: c.sf, child: content);
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (c.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: bg ?? c.bg,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            if (top != null) top!,
            Expanded(child: floating == null ? content : Stack(children: [Positioned.fill(child: content), Positioned(left: 0, right: 0, bottom: 0, child: floating!)])),
            if (foot != null) foot!,
            if (tab != null) (role == TabRole.driver ? DriverTabs(tab!) : CustomerTabs(tab!)) else if (foot == null) SizedBox(height: 0),
          ]),
        ),
      ),
    );
  }
}

Widget _tabButton(BuildContext context, {required String icon, required String label, required bool on, required VoidCallback onTap}) {
  final c = context.sc;
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            width: 58,
            height: 32,
            decoration: BoxDecoration(color: on ? c.hero : Colors.transparent, borderRadius: BorderRadius.circular(16)),
            child: Center(child: SIcon(icon, size: 24, color: on ? c.tx : c.tx2)),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontFamily: Fonts.ui, fontSize: 12, fontWeight: on ? FontWeight.w700 : FontWeight.w500, color: on ? c.tx : c.tx2)),
        ]),
      ),
    ),
  );
}

void goTab(String route) {
  if (Get.currentRoute == route) return;
  Get.offAllNamed(route);
}

class CustomerTabs extends StatelessWidget {
  const CustomerTabs(this.active, {super.key});
  final String active;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final items = [
      ('home', 'home', 'الرئيسية', '/home'),
      ('print', 'printer', 'الطباعة', '/print'),
      ('ai', 'sparkles', 'المساعد', '/assistant'),
      ('orders', 'orders', 'طلباتي', '/orders'),
      ('acc', 'user', 'حسابي', '/account'),
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(4, 6, 4, 6 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: c.sf, border: Border(top: BorderSide(color: c.ln))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final t in items)
          if (t.$1 == 'ai')
            Expanded(
              child: GestureDetector(
                onTap: () => goTab(t.$4),
                behavior: HitTestBehavior.opaque,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Transform.translate(
                      offset: const Offset(0, -8),
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active == 'ai' ? c.priHi : c.pri,
                          boxShadow: [
                            BoxShadow(color: c.sf, spreadRadius: 5),
                            BoxShadow(color: const Color(0xFF30142A).withValues(alpha: .55), blurRadius: 18, spreadRadius: -6, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Center(child: SIcon('sparkles', size: 26, color: c.onPri)),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -8),
                      child: Text(t.$3, style: TextStyle(fontFamily: Fonts.ui, fontSize: 12, fontWeight: active == 'ai' ? FontWeight.w700 : FontWeight.w500, color: active == 'ai' ? c.tx : c.tx2)),
                    ),
                  ]),
                ),
              ),
            )
          else
            _tabButton(context, icon: t.$2, label: t.$3, on: active == t.$1, onTap: () => goTab(t.$4)),
      ]),
    );
  }
}

class DriverTabs extends StatelessWidget {
  const DriverTabs(this.active, {super.key});
  final String active;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final items = [
      ('home', 'truck', 'مهمتي', '/driver/home'),
      ('av', 'box', 'المتاحة', '/driver/available'),
      ('hist', 'orders', 'السجل', '/driver/history'),
      ('earn', 'wallet', 'الأرباح', '/driver/earnings'),
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(4, 6, 4, 6 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: c.sf, border: Border(top: BorderSide(color: c.ln))),
      child: Row(children: [
        for (final t in items) _tabButton(context, icon: t.$2, label: t.$3, on: active == t.$1, onTap: () => goTab(t.$4)),
      ]),
    );
  }
}

// ------------------------------------------------------------------ overlays

/// ورقة سفلية (sheet): grab + عنوان + جسم + أزرار.
Future<R?> showSheet<R>(BuildContext context, {String? title, required Widget body, List<Widget> foot = const [], bool dismissible = true}) {
  final c = context.sc;
  return showModalBottomSheet<R>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xFF1A0816).withValues(alpha: .46),
    isDismissible: dismissible,
    builder: (ctx) => Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .88),
      decoration: BoxDecoration(color: c.sf, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 30 + MediaQuery.of(ctx).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: c.sf3, borderRadius: BorderRadius.circular(3)))),
          const SizedBox(height: 14),
          if (title != null) ...[Text(title, style: T.h2(c.tx)), const SizedBox(height: 12)],
          body,
          if (foot.isNotEmpty) ...[
            const SizedBox(height: 18),
            for (var i = 0; i < foot.length; i++) ...[if (i > 0) const SizedBox(height: 8), foot[i]],
          ],
        ]),
      ),
    ),
  );
}

/// حوار (dlg): فقاعة أيقونة + عنوان + نص + أزرار. [kind]: plum | err | warn | ok
Future<R?> showDlg<R>(BuildContext context, {String kind = 'plum', required String icon, required String title, required String text, required List<Widget> foot, bool dismissible = true}) {
  final c = context.sc;
  final (bg, fg) = switch (kind) {
    'err' => (c.errSoft, c.errInk),
    'warn' => (c.amberSoft, c.amberInk),
    'ok' => (c.okSoft, c.okInk),
    _ => (c.plumSoft, c.plumInk),
  };
  return showDialog<R>(
    context: context,
    barrierDismissible: dismissible,
    barrierColor: const Color(0xFF1A0816).withValues(alpha: .46),
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(28),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(Rad.xl)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Center(child: SIcon(icon, size: 28, color: fg))),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: T.h2(c.tx)),
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.center, style: T.sm(c.tx2)),
          const SizedBox(height: 18),
          for (var i = 0; i < foot.length; i++) ...[if (i > 0) const SizedBox(height: 8), foot[i]],
        ]),
      ),
    ),
  );
}

OverlayEntry? _toast;

/// تغذية راجعة سفلية مؤقتة (toast).
void showToast(String msg, {String icon = 'checkC', String? actionLabel, VoidCallback? onAction}) {
  final ctx = Get.overlayContext;
  if (ctx == null) return;
  final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
  if (overlay == null) return;
  _toast?.remove();
  final c = ctx.sc;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      left: 16,
      right: 16,
      bottom: 96,
      child: Directionality(
        textDirection: Directionality.of(ctx),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                color: c.dark ? c.sf3 : c.tx,
                borderRadius: BorderRadius.circular(Rad.m),
                boxShadow: const [BoxShadow(color: Color(0x73000000), blurRadius: 28, spreadRadius: -8, offset: Offset(0, 12))]),
            child: Row(children: [
              SIcon(icon, size: 20, color: c.dark ? c.tx : c.bg),
              const SizedBox(width: 10),
              Expanded(child: Text(msg, style: TextStyle(fontFamily: Fonts.ui, fontSize: 14.5, fontWeight: FontWeight.w500, color: c.dark ? c.tx : c.bg))),
              if (actionLabel != null)
                GestureDetector(
                  onTap: () {
                    entry.remove();
                    onAction?.call();
                  },
                  child: Padding(padding: const EdgeInsets.all(8), child: Text(actionLabel, style: TextStyle(fontFamily: Fonts.ui, fontSize: 14, fontWeight: FontWeight.w700, color: c.amber))),
                ),
            ]),
          ),
        ),
      ),
    ),
  );
  _toast = entry;
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 2800), () {
    if (_toast == entry) {
      entry.remove();
      _toast = null;
    }
  });
}

/// زر السلة العائم (sticky-cart).
class StickyCart extends StatelessWidget {
  const StickyCart({super.key, required this.count, required this.totalMinor, required this.onTap});
  final int count;
  final num totalMinor;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          padding: const EdgeInsetsDirectional.only(start: 20, end: 10),
          decoration: BoxDecoration(
              color: c.pri,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: const Color(0xFF30142A).withValues(alpha: .6), blurRadius: 28, spreadRadius: -10, offset: const Offset(0, 14))]),
          child: Row(children: [
            Container(
              constraints: const BoxConstraints(minWidth: 34),
              height: 34,
              decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text('$count', style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w700, color: c.onHero)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('عرض السلة', style: TextStyle(fontFamily: Fonts.ui, fontSize: 16, fontWeight: FontWeight.w600, color: c.onPri))),
            Mny(totalMinor, color: c.onPri),
            const SizedBox(width: 12),
            SIcon('chevL', size: 20, color: c.onPri),
            const SizedBox(width: 8),
          ]),
        ),
      ),
    );
  }
}
