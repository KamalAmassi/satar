import 'package:flutter/widgets.dart';

/// يملك مفتاح صورة المنتج (مصدر الطيران) لبطاقة بلا حالة؛ ضع [KeyedSubtree] بهذا المفتاح حول الصورة
/// واستدعِ FlyToCart.run(context, sourceKey: key, ...) من زر الإضافة.
class FlyToCartSource extends StatefulWidget {
  const FlyToCartSource({super.key, required this.builder});
  final Widget Function(BuildContext context, GlobalKey sourceKey) builder;

  @override
  State<FlyToCartSource> createState() => _FlyToCartSourceState();
}

class _FlyToCartSourceState extends State<FlyToCartSource> {
  final _key = GlobalKey(debugLabel: 'fly-source');

  @override
  Widget build(BuildContext context) => widget.builder(context, _key);
}
