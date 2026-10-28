import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/routes/app_routes.dart';

class CustomerOtpController extends GetxController {
  final List<TextEditingController> controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  final isOtpComplete = false.obs;
  final phoneNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      phoneNumber.value = Get.arguments.toString();
    }
  }

  void onDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    checkCompletion();
  }

  void checkCompletion() {
    final code = controllers.map((c) => c.text).join();
    isOtpComplete.value = code.length == 4;
  }

  void resendOtp() {
    Get.snackbar(
      'إعادة إرسال الرمز',
      'تم إرسال رمز تحقق جديد إلى رقمك',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void verifyOtp() {
    if (isOtpComplete.value) {
      Get.toNamed(CustomerRoutes.completeProfile);
    }
  }

  @override
  void onClose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
