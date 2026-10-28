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
import 'package:project/welcome/presentation/widgets/splash_background.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(child: SplashBackground()),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                  child: Column(
                    children: [
                      const Spacer(flex: 5),
                      const Entrance(
                        duration: Duration(milliseconds: 800),
                        scaleBegin: 0.6,
                        curve: AppMotion.spring,
                        child: AppLogoMark(size: 108, framed: true),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      const Entrance(
                        delay: Duration(milliseconds: 350),
                        offset: Offset(0, 16),
                        child: AppWordmark(color: AppColors.sand, size: 40),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Entrance(
                        delay: const Duration(milliseconds: 600),
                        child: Text(
                          l10n.splashTagline,
                          textAlign: TextAlign.center,
                          style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                            AppColors.sand.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      const Spacer(flex: 6),
                      Entrance(
                        delay: const Duration(milliseconds: 900),
                        offset: const Offset(0, 24),
                        child: Obx(
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
                      ),
                      const SizedBox(height: AppSizes.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}