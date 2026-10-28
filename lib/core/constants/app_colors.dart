import 'package:flutter/material.dart';

/// ألوان سطر — مؤقتة حتى اعتماد الهوية النهائية.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF30142A);
  static const Color primaryLight = Color(0xFF5B2A52);
  static const Color secondary = Color(0xFFD4A12A);
  static const Color accent = Color(0xFFC0392B);

  // Light
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Dark
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color borderDark = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFE02424);
  static const Color info = Color(0xFF0EA5E9);

  static const Color cream = Color(0xFFFBF6EE);
  static const Color sand = Color(0xFFF1DDB5);
  /// ألوان حالات الطلب (من الـ handoff).
  static const Map<String, Color> _statusColors = {
    'awaiting_pricing': Color(0xFFF59E0B),
    'priced': Color(0xFF0EA5E9),
    'pending': Color(0xFFF59E0B),
    'awaiting_payment': Color(0xFF8B5CF6),
    'payment_review': Color(0xFF8B5CF6),
    'preparing': Color(0xFF8B5CF6),
    'ready_for_delivery': Color(0xFF8B5CF6),
    'accepted': Color(0xFF3B82F6),
    'picked_up': Color(0xFF8B5CF6),
    'on_the_way': Color(0xFF0EA5E9),
    'arrived': Color(0xFF14B8A6),
    'delivery_failed': Color(0xFFE02424),
    'delivered': Color(0xFF10B981),
    'cancelled': Color(0xFFEF4444),
  };

  static Color statusColor(String key) =>
      _statusColors[key] ?? const Color(0xFF64748B);
}