import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class AiAssistantController extends GetxController {
  final promptController = TextEditingController();

  void generateProposal() {
    if (promptController.text.trim().isNotEmpty) {
      Get.toNamed(CustomerRoutes.aiProposal);
    }
  }

  @override
  void onClose() {
    promptController.dispose();
    super.onClose();
  }
}
