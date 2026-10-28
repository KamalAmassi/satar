import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/core/widgets/app_logo.dart';
import 'package:project/welcome/presentation/controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const AppLogo(size: 140, fallbackColor: AppColors.sand),
              const SizedBox(height: AppSizes.lg),
              Text(
                l10n.splashTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.sand.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(flex: 4),
              Obx(
                    () => SizedBox(
                  width: 180,
                  child: AppButton(
                    label: l10n.splashContinue,
                    variant: AppButtonVariant.light,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.onContinue,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}