import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/welcome/domain/usecases/complete_onboarding_usecase.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._completeOnboarding);

  final CompleteOnboardingUseCase _completeOnboarding;

  static const int pageCount = 3;
  static const _animation = Duration(milliseconds: 300);

  final pageController = PageController();
  final currentPage = 0.obs;

  bool get isLast => currentPage.value == pageCount - 1;
  bool get canGoBack => currentPage.value > 0;

  void onPageChanged(int index) => currentPage.value = index;

  Future<void> next() async {
    if (isLast) return finish();
    await pageController.nextPage(duration: _animation, curve: Curves.easeOut);
  }

  Future<void> back() async {
    if (!canGoBack) return;
    await pageController.previousPage(
      duration: _animation,
      curve: Curves.easeOut,
    );
  }

  Future<void> finish() async {
    await _completeOnboarding(const NoParams());
    Get.offAllNamed(SharedRoutes.roleChoice);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}