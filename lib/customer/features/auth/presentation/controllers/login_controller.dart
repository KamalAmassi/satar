import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/routes/app_routes.dart';

class CustomerLoginController extends GetxController {
  final phoneController = TextEditingController();
  final isPhoneValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_validatePhone);
  }

  void _validatePhone() {
    final text = phoneController.text.trim();
    isPhoneValid.value = text.length >= 9;
  }

  void sendOtp() {
    if (isPhoneValid.value) {
      Get.snackbar(
        'تم إرسال الرمز',
        'تم إرسال رمز التحقق إلى الرقم +970 ${phoneController.text.trim()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      Get.toNamed(CustomerRoutes.otp, arguments: phoneController.text.trim());
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
