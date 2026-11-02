import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/widgets/app_button.dart';

enum AppStateTone { neutral, error, warning, success }

/// شاشة حالة موحّدة (فاضي / خطأ / تحذير / نجاح) — تغطي أغلب الحالات بالتصميم.
class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.tone = AppStateTone.neutral,
    this.primaryLoading = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final AppStateTone tone;
  final bool primaryLoading;

  Color get _color {
    switch (tone) {
      case AppStateTone.neutral:
        return AppColors.primary;
      case AppStateTone.error:
        return AppColors.error;
      case AppStateTone.warning:
        return AppColors.warning;
      case AppStateTone.success:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: tone == AppStateTone.neutral
                    ? AppColors.sand.withValues(alpha: 0.6)
                    : _color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppSizes.iconLg, color: _color),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
            if (primaryLabel != null) ...[
              const SizedBox(height: AppSizes.xl),
              AppButton(
                label: primaryLabel!,
                onPressed: onPrimary,
                isLoading: primaryLoading,
              ),
            ],
            if (secondaryLabel != null) ...[
              const SizedBox(height: AppSizes.md),
              AppButton(
                label: secondaryLabel!,
                variant: AppButtonVariant.outlined,
                onPressed: onSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
