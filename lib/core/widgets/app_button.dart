import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

enum AppButtonVariant { primary, outlined, light }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  /// يمنع النقرات المتكررة أثناء تنفيذ العملية.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = isLoading ? null : onPressed;

    switch (variant) {
      case AppButtonVariant.primary:
        return FilledButton(
          onPressed: action,
          child: _content(Colors.white),
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: action,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
          child: _content(AppColors.primary),
        );
      case AppButtonVariant.light:
        return FilledButton(
          onPressed: action,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.sand,
            foregroundColor: AppColors.primary,
          ),
          child: _content(AppColors.primary),
        );
    }
  }

  Widget _content(Color color) {
    if (isLoading) {
      return SizedBox(
        width: AppSizes.iconSm,
        height: AppSizes.iconSm,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSizes.iconSm),
          const SizedBox(width: AppSizes.sm),
        ],
        Flexible(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              label,
              key: ValueKey(label),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),      ],
    );
  }
}