import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// شاشة حالة القبول (جاري / نجاح / أخطاء) — دائرة أيقونة + عنوان + وصف + أزرار.
class AcceptanceStatusWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? actionButton;
  final Widget? secondaryButton;
  final bool isSuccess;
  final bool isLoading;

  const AcceptanceStatusWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionButton,
    this.secondaryButton,
    this.isSuccess = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: isSuccess ? AppColors.primary : DriverUi.dangerBg,
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  )
                : Icon(
                    icon,
                    size: 38,
                    color: isSuccess ? DriverUi.gold : AppColors.error,
                  ),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: DriverUi.muted, fontSize: 14, height: 1.5),
          ),
          if (actionButton != null) ...[const SizedBox(height: 24), actionButton!],
          if (secondaryButton != null) ...[const SizedBox(height: 10), secondaryButton!],
        ],
      ),
    );
  }
}
