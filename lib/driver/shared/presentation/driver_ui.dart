import 'package:flutter/material.dart';

/// ألوان وقياسات واجهة السائق (مأخوذة من تصميم الفيجما) — مكان واحد بدل الأرقام المتناثرة.
abstract final class DriverUi {
  static const Color bg = Color(0xFFFFFCF7); // خلفية الشاشات
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE9E0E5);
  static const Color chip = Color(0xFFF5EFEF);
  static const Color muted = Color(0xFF777078);
  static const Color gold = Color(0xFFF3E5B9);
  static const Color navMuted = Color(0xFFBCAEB8);
  static const Color infoBg = Color(0xFFDBE6E9);
  static const Color dangerBg = Color(0xFFFAE8E6);
  static const Color warnBg = Color(0xFFFBF1D4);

  static const double pagePadding = 20;
  static const double cardRadius = 19;
  static const double buttonRadius = 14;
}
