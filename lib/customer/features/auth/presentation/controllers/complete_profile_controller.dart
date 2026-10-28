import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class CustomerCompleteProfileController extends GetxController {
  final nameController = TextEditingController();
  final isNameValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_validateName);
  }

  void _validateName() {
    final text = nameController.text.trim();
    isNameValid.value = text.length >= 2;
  }

  void continueToSuccess() {
    if (isNameValid.value) {
      Get.toNamed(CustomerRoutes.success);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
