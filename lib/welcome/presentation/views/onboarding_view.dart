import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project/core/animations/entrance.dart';
import 'package:project/core/constants/app_assets.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/welcome/presentation/controllers/onboarding_controller.dart';
import 'package:project/welcome/presentation/widgets/onboarding_page_item.dart';
import 'package:project/welcome/presentation/widgets/page_indicator.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final slides = [
      (AppAssets.onboarding1, l10n.onboarding1Title, l10n.onboarding1Body),
      (AppAssets.onboarding2, l10n.onboarding2Title, l10n.onboarding2Body),
      (AppAssets.onboarding3, l10n.onboarding3Title, l10n.onboarding3Body),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFBF6EE),
                  Color(0xFFF4EAD8),
                ],
              ),
            ),
            child: Column(
              children: [
                Entrance(
                  offset: const Offset(0, -16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.xl,
                      vertical: AppSizes.md,
                    ),
                    child: Obx(
                      () => SizedBox(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (controller.canGoBack)
                              IconButton.outlined(
                                onPressed: controller.back,
                                style: IconButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                  ),
                                  backgroundColor: AppColors.surface,
                                ),
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: AppSizes.iconSm,
                                  color: AppColors.primary,
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            TextButton(
                              onPressed: controller.finish,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Text(l10n.onboardingSkip),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Expanded(
                  child: Entrance(
                    delay: const Duration(milliseconds: 100),
                    offset: const Offset(0, 20),
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      itemCount: slides.length,
                      itemBuilder: (_, i) => OnboardingPageItem(
                        pageController: controller.pageController,
                        index: i,
                        imageAsset: slides[i].$1,
                        title: slides[i].$2,
                        body: slides[i].$3,
                        counter: l10n.onboardingPageCounter(
                          i + 1,
                          OnboardingController.pageCount,
                        ),
                      ),
                    ),
                  ),
                ),
                Entrance(
                  delay: const Duration(milliseconds: 200),
                  offset: const Offset(0, 20),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.xl,
                      AppSizes.md,
                      AppSizes.xl,
                      AppSizes.xl,
                    ),
                    child: Obx(
                      () => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PageIndicator(
                            count: OnboardingController.pageCount,
                            current: controller.currentPage.value,
                          ),
                          const SizedBox(height: AppSizes.lg),
                          AppButton(
                            label: controller.isLast
                                ? l10n.onboardingStart
                                : l10n.onboardingNext,
                            onPressed: controller.next,
                          ),
                        ],
                      ),
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
