import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// شريط علوي للشاشات المفتوحة من فوق التابات (سهم رجوع + عنوان).
PreferredSizeWidget driverAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    backgroundColor: DriverUi.bg,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    title: Text(
      title,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    actions: actions,
  );
}
