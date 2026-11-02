import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project/core/animations/app_motion.dart';
import 'package:project/core/animations/entrance.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/core/widgets/app_logo_mark.dart';
import 'package:project/core/widgets/app_wordmark.dart';
import 'package:project/welcome/presentation/controllers/splash_controller.dart';
import 'package:project/welcome/presentation/widgets/ink_line.dart';
import 'package:project/welcome/presentation/widgets/paper_background.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: PaperBackground(
          isDark: true,
          child: Column(
            children: [
              const Spacer(flex: 3),
              const InkLine(height: 2, color: AppColors.sand),
              const SizedBox(height: AppSizes.xxl),
              const Entrance(
                duration: Duration(milliseconds: 800),
                scaleBegin: 0.8,
                curve: AppMotion.spring,
                child: AppLogoMark(size: 96, framed: true),
              ),
              const SizedBox(height: AppSizes.lg),
              const Entrance(
                delay: Duration(milliseconds: 350),
                offset: Offset(0, 16),
                child: AppWordmark(color: AppColors.sand, size: 40),
              ),
              Entrance(
                delay: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSizes.sm),
                  child: Text(
                    l10n.splashTagline,
                    style: TextStyle(color: AppColors.sand.withValues(alpha: 0.7)),
                  ),
                ),
              ),
              const Spacer(flex: 4),
              Entrance(
                delay: const Duration(milliseconds: 900),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: Obx(
                    () => AppButton(
                      label: l10n.splashContinue,
                      variant: AppButtonVariant.light,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.onContinue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }
}
