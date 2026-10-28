import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project/core/animations/app_motion.dart';
import 'package:project/core/animations/entrance.dart';
import 'package:project/core/constants/app_assets.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/core/widgets/app_wordmark.dart';
import 'package:project/welcome/presentation/controllers/role_choice_controller.dart';

import '../../../core/animations/floating_effect.dart';

class RoleChoiceView extends GetView<RoleChoiceController> {
  const RoleChoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              children: [
                const Entrance(
                  offset: Offset(0, -12),
                  child: AppWordmark(size: 26),
                ),
                Expanded(
                  child: Center(
                    child: Entrance(
                      delay: const Duration(milliseconds: 120),
                      duration: const Duration(milliseconds: 800),
                      offset: const Offset(0, 24),
                      scaleBegin: 0.9,
                      curve: AppMotion.spring,
                      child: FloatingEffect(
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
                  ),
                ),
                Entrance(
                  delay: const Duration(milliseconds: 300),
                  offset: const Offset(0, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.roleWelcomeTitle,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Entrance(
                  delay: const Duration(milliseconds: 390),
                  offset: const Offset(0, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.roleWelcomeSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                Entrance(
                  delay: const Duration(milliseconds: 480),
                  offset: const Offset(0, 20),
                  child: AppButton(
                    label: l10n.roleCustomer,
                    icon: Icons.shopping_bag_outlined,
                    onPressed: controller.continueAsCustomer,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Entrance(
                  delay: const Duration(milliseconds: 570),
                  offset: const Offset(0, 20),
                  child: AppButton(
                    label: l10n.roleDriver,
                    icon: Icons.delivery_dining_outlined,
                    variant: AppButtonVariant.outlined,
                    onPressed: controller.continueAsDriver,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Entrance(
                  delay: const Duration(milliseconds: 700),
                  child: Text(
                    l10n.roleTermsNote,
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}