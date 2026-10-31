import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class CancelOrderController extends GetxController {
  final selectedReason = 0.obs;
  final notesController = TextEditingController();

  void confirmCancel() {
    Get.snackbar('تم الإلغاء', 'تم إلغاء الطلب بنجاح');
    Get.offAllNamed(CustomerRoutes.home);
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
