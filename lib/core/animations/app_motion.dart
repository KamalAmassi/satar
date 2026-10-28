import 'package:flutter/animation.dart';

/// مدد ومنحنيات الحركة الموحدة في كل التطبيق.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 350);
  static const slow = Duration(milliseconds: 600);
  static const page = Duration(milliseconds: 400);
  static const stagger = Duration(milliseconds: 90);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;

  /// تأخير عنصر ضمن سلسلة ظهور متتابعة.
  static Duration delayFor(int index, {Duration base = Duration.zero}) =>
      base + stagger * index;
}