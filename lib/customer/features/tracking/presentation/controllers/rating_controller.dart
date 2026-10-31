import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class RatingController extends GetxController {
  final rating = 0.obs;
  final commentController = TextEditingController();

  void submitRating() {
    Get.snackbar('شكراً لك', 'تم إرسال تقييمك بنجاح');
    Get.offAllNamed(CustomerRoutes.home);
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
