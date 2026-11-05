import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/motion.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/motion/motion_settings.dart';
import 'package:project/core/widgets/product_hero.dart';

/// رياضيات العارض (نقية وقابلة للاختبار).
abstract final class ViewerMath {
  static const minScale = 1.0;
  static const maxScale = 4.0;
  static const doubleTapScale = 2.5;
  static const zoomedEpsilon = 1.01;

  /// نسبة ارتفاع الشاشة التي يكفي سحبها للإغلاق، أو سرعة القذف (بكسل منطقي/ث).
  static const dismissFraction = .18;
  static const dismissVelocity = 900.0;

  /// المسافة (نسبةً للارتفاع) التي تبلغ عندها الخلفية أقصى تلاشٍ.
  static const fadeFraction = .35;
  static const minDragScale = .92;

  /// أقصى عرض/ارتفاع لفك الصورة في العارض.
  static const maxDecodePx = 2048;

  static double clampScale(double s) => s.isNaN ? minScale : s.clamp(minScale, maxScale);

  static bool isZoomed(double scale) => scale > zoomedEpsilon;

  /// مصفوفة تكبير حول نقطة: النقطة [focal] تبقى في مكانها على الشاشة.
  static Matrix4 zoomAt(Offset focal, double scale) {
    final s = clampScale(scale);
    return Matrix4.diagonal3Values(s, s, 1)..setTranslationRaw(-focal.dx * (s - 1), -focal.dy * (s - 1), 0);
  }

  static bool shouldDismiss({required double offset, required double velocity, required double extent}) =>
      extent > 0 && (offset.abs() >= extent * dismissFraction || velocity.abs() >= dismissVelocity);

  /// تقدّم السحب 0..1 (للتلاشي والتصغير).
  static double dragProgress(double offset, double extent) =>
      extent <= 0 ? 0 : (offset.abs() / (extent * fadeFraction)).clamp(0.0, 1.0);

  static double dragScale(double progress) => 1 - (1 - minDragScale) * progress;
}

/// عارض صور بملء الشاشة: تكبير بالقرص/النقر المزدوج، سحب عمودي للإغلاق، تقليب بين الصور.
class ProductImageViewer extends StatefulWidget {
  const ProductImageViewer({
    super.key,
    required this.urls,
    required this.name,
    this.initialIndex = 0,
    this.heroTag,
    this.placeholderCacheWidth,
  });

  final List<String> urls;
  final String name;
  final int initialIndex;

  /// وسم Hero للصورة الأولى (يكمل الطيران من صفحة التفاصيل).
  final Object? heroTag;

  /// عرض فك الصورة المعروضة سابقًا (موجودة في الكاش) لتظهر فورًا ريثما تُحمَّل الدقة الأعلى.
  final int? placeholderCacheWidth;

  static Future<void> open(
    BuildContext context, {
    required List<String> urls,
    required String name,
    int initialIndex = 0,
    Object? heroTag,
    int? placeholderCacheWidth,
  }) {
    final reduce = MotionSettings.of(context).reduceMotion;
    return Navigator.of(context).push(PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: reduce ? Duration.zero : Motion.viewerRoute,
      reverseTransitionDuration: reduce ? Duration.zero : Motion.viewerRoute,
      pageBuilder: (_, __, ___) => ProductImageViewer(
        urls: urls,
        name: name,
        initialIndex: initialIndex,
        heroTag: heroTag,
        placeholderCacheWidth: placeholderCacheWidth,
      ),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    ));
  }

  @override
  State<ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer> with SingleTickerProviderStateMixin {
  late final PageController _pages = PageController(initialPage: _initial);
  late final ValueNotifier<int> _index = ValueNotifier(_initial);
  final _zoomed = ValueNotifier(false);
  final _drag = ValueNotifier(0.0);
  late final AnimationController _settle = AnimationController(vsync: this, duration: Motion.short)..addListener(_onSettle);
  double _settleFrom = 0;

  int get _initial => widget.urls.isEmpty ? 0 : widget.initialIndex.clamp(0, widget.urls.length - 1);

  void _onSettle() => _drag.value = _settleFrom * (1 - Curves.easeOutCubic.transform(_settle.value));

  void _close() => Navigator.of(context).maybePop();

  void _onDragUpdate(DragUpdateDetails d) {
    _settle.stop();
    _drag.value += d.delta.dy;
  }

  void _onDragEnd(DragEndDetails d) {
    final h = MediaQuery.sizeOf(context).height;
    if (ViewerMath.shouldDismiss(offset: _drag.value, velocity: d.velocity.pixelsPerSecond.dy, extent: h)) {
      _close();
      return;
    }
    if (MotionSettings.of(context).reduceMotion) {
      _drag.value = 0;
      return;
    }
    _settleFrom = _drag.value;
    _settle.forward(from: 0);
  }

  @override
  void dispose() {
    _settle.dispose();
    _pages.dispose();
    _index.dispose();
    _zoomed.dispose();
    _drag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    final h = MediaQuery.sizeOf(context).height;
    final count = widget.urls.length;

    final pages = ValueListenableBuilder<bool>(
      valueListenable: _zoomed,
      builder: (_, zoomed, __) => GestureDetector(
        // السحب العمودي للإغلاق فقط عند عدم التكبير (لا يتعارض مع التحريك داخل الصورة).
        onVerticalDragUpdate: zoomed ? null : _onDragUpdate,
        onVerticalDragEnd: zoomed ? null : _onDragEnd,
        child: PageView.builder(
          controller: _pages,
          physics: zoomed ? const NeverScrollableScrollPhysics() : null,
          itemCount: count,
          onPageChanged: (i) {
            _index.value = i;
            _zoomed.value = false;
          },
          itemBuilder: (_, i) => _ZoomPage(
            url: widget.urls[i],
            semanticLabel: l.productImageSemantics(widget.name),
            heroTag: i == _initial ? widget.heroTag : null,
            placeholderCacheWidth: widget.placeholderCacheWidth,
            onZoomChanged: (z) => _zoomed.value = z,
          ),
        ),
      ),
    );

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _close},
      child: Focus(
        autofocus: true,
        child: Material(
          type: MaterialType.transparency,
          child: ValueListenableBuilder<double>(
            valueListenable: _drag,
            child: pages,
            builder: (_, dy, child) {
              final p = ViewerMath.dragProgress(dy, h);
              return Stack(children: [
                Positioned.fill(child: ColoredBox(color: c.bg.withValues(alpha: 1 - p))),
                Positioned.fill(
                  child: RepaintBoundary(
                    child: Transform.translate(
                      offset: Offset(0, dy),
                      child: Transform.scale(scale: ViewerMath.dragScale(p), child: child),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: p > 0,
                    child: Opacity(
                      opacity: 1 - p,
                      child: SafeArea(
                        child: Stack(children: [
                          PositionedDirectional(
                            top: 8,
                            end: 8,
                            child: Semantics(
                              button: true,
                              label: l.imageViewerClose,
                              child: ExcludeSemantics(child: SIconBtn('x', box: 48, tonal: true, onTap: _close)),
                            ),
                          ),
                          if (count > 1)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 16,
                              child: ValueListenableBuilder<int>(
                                valueListenable: _index,
                                builder: (_, i, __) => Semantics(
                                  liveRegion: true,
                                  label: l.imageViewerPage(i + 1, count),
                                  child: ExcludeSemantics(child: _InkStrokes(count: count, index: i, color: c.tx)),
                                ),
                              ),
                            ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }
}

class _ZoomPage extends StatefulWidget {
  const _ZoomPage({
    required this.url,
    required this.semanticLabel,
    required this.onZoomChanged,
    this.heroTag,
    this.placeholderCacheWidth,
  });

  final String url;
  final String semanticLabel;
  final ValueChanged<bool> onZoomChanged;
  final Object? heroTag;
  final int? placeholderCacheWidth;

  @override
  State<_ZoomPage> createState() => _ZoomPageState();
}

class _ZoomPageState extends State<_ZoomPage> with SingleTickerProviderStateMixin {
  final _tc = TransformationController();
  late final AnimationController _anim = AnimationController(vsync: this, duration: Motion.viewerZoom)..addListener(_onAnim);
  Animation<Matrix4>? _tween;
  Offset _tap = Offset.zero;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _tc.addListener(_onTransform);
  }

  void _onAnim() {
    final t = _tween;
    if (t != null) _tc.value = t.value;
  }

  void _onTransform() {
    final z = ViewerMath.isZoomed(_tc.value.getMaxScaleOnAxis());
    if (z == _zoomed) return;
    setState(() => _zoomed = z); // يحدّث panEnabled لهذه الصفحة فقط
    widget.onZoomChanged(z);
  }

  void _toggleZoom() {
    final target = _zoomed ? Matrix4.identity() : ViewerMath.zoomAt(_tap, ViewerMath.doubleTapScale);
    if (MotionSettings.of(context).reduceMotion) {
      _tc.value = target;
      return;
    }
    _tween = Matrix4Tween(begin: _tc.value, end: target)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward(from: 0);
  }

  @override
  void dispose() {
    _tc.removeListener(_onTransform);
    _anim.dispose();
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final image = Stack(fit: StackFit.expand, children: [
      if (widget.placeholderCacheWidth != null)
        Image.network(
          widget.url,
          cacheWidth: widget.placeholderCacheWidth,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      Image(
        image: ResizeImage(
          NetworkImage(widget.url),
          width: ViewerMath.maxDecodePx,
          height: ViewerMath.maxDecodePx,
          policy: ResizeImagePolicy.fit,
        ),
        fit: BoxFit.contain,
        semanticLabel: widget.semanticLabel,
        frameBuilder: (_, child, frame, sync) => sync
            ? child
            : AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: Motion.imageFade, curve: Curves.easeOut, child: child),
        errorBuilder: (_, __, ___) => Center(child: SIcon('image', size: 32, color: c.tx3)),
      ),
    ]);

    return GestureDetector(
      onDoubleTapDown: (d) => _tap = d.localPosition,
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _tc,
        minScale: ViewerMath.minScale,
        maxScale: ViewerMath.maxScale,
        panEnabled: _zoomed,
        onInteractionStart: (_) => _anim.stop(),
        child: SizedBox.expand(child: ProductHero(tag: widget.heroTag, radius: 0, child: image)),
      ),
    );
  }
}

/// مؤشر الصفحات: خطوط حبر قصيرة، الحالية أطول وأغمق.
class _InkStrokes extends StatelessWidget {
  const _InkStrokes({required this.count, required this.index, required this.color});

  final int count;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final reduce = MotionSettings.of(context).reduceMotion;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (var i = 0; i < count; i++)
        AnimatedContainer(
          duration: reduce ? Duration.zero : Motion.short,
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == index ? 22 : 12,
          height: 3,
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: color.withValues(alpha: i == index ? .9 : .3),
          ),
        ),
    ]);
  }
}
