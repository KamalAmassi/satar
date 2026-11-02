import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/welcome/presentation/controllers/onboarding_controller.dart';
import 'package:project/welcome/presentation/widgets/onboarding_page_item.dart';
import 'package:project/welcome/presentation/widgets/page_indicator.dart';
import 'package:project/welcome/presentation/widgets/paper_background.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: PaperBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xl,
                    vertical: AppSizes.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => controller.canGoBack
                          ? IconButton(
                              onPressed: controller.back,
                              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                            )
                          : const SizedBox(width: 48)),
                      TextButton(
                        onPressed: controller.finish,
                        child: Text(l10n.onboardingSkip, style: const TextStyle(color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: OnboardingController.pageCount,
                    itemBuilder: (_, i) {
                      final title = [l10n.onboarding1Title, l10n.onboarding2Title, l10n.onboarding3Title];
                      final body = [l10n.onboarding1Body, l10n.onboarding2Body, l10n.onboarding3Body];
                      return OnboardingPageItem(
                        index: i,
                        title: title[i],
                        body: body[i],
                        counter: l10n.onboardingPageCounter(i + 1, OnboardingController.pageCount),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: Obx(
                    () => Column(
                      children: [
                        PageIndicator(
                          count: OnboardingController.pageCount,
                          current: controller.currentPage.value,
                        ),
                        const SizedBox(height: AppSizes.xl),
                        AppButton(
                          label: controller.isLast ? l10n.onboardingStart : l10n.onboardingNext,
                          onPressed: controller.next,
                        ),
                      ],
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
