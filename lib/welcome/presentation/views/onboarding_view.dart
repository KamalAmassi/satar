import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding,
                vertical: AppSizes.sm,
              ),
              child: Obx(
                    () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: controller.finish,
                      child: Text(l10n.onboardingSkip),
                    ),
                    if (controller.canGoBack)
                      IconButton.outlined(
                        onPressed: controller.back,
                        icon: const Icon(Icons.arrow_back_rounded),
                      )
                    else
                      const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: slides.length,
                itemBuilder: (_, i) => OnboardingPageItem(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                0,
                AppSizes.pagePadding,
                AppSizes.xl,
              ),
              child: Obx(
                    () => Column(
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
          ],
        ),
      ),
    );
  }
}