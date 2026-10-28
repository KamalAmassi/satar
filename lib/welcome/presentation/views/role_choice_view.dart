import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_assets.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/core/widgets/app_logo.dart';
import 'package:project/welcome/presentation/controllers/role_choice_controller.dart';

class RoleChoiceView extends GetView<RoleChoiceController> {
  const RoleChoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            children: [
              const AppLogo(size: 48),
              Expanded(
                child: Center(
                  child: Image.asset(
                    AppAssets.roleHero,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 160,
                      height: 200,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(80),
                          bottom: Radius.circular(AppSizes.radiusLg),
                        ),
                      ),
                      child: const Text(
                        'س',
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sand,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.roleWelcomeTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.roleWelcomeSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              AppButton(
                label: l10n.roleCustomer,
                icon: Icons.shopping_bag_outlined,
                onPressed: controller.continueAsCustomer,
              ),
              const SizedBox(height: AppSizes.md),
              AppButton(
                label: l10n.roleDriver,
                icon: Icons.delivery_dining_outlined,
                variant: AppButtonVariant.outlined,
                onPressed: controller.continueAsDriver,
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                l10n.roleTermsNote,
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}