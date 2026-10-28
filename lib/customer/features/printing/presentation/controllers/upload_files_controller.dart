import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class UploadFilesController extends GetxController {
  final titleController = TextEditingController();
  final notesController = TextEditingController();
  final hasFile = false.obs;

  void pickFile() {
    hasFile.value = true;
    Get.snackbar('تم الرفع', 'تم اختيار الملف بنجاح');
  }

  void continueToSpecs() {
    Get.toNamed(CustomerRoutes.printSpecs);
  }

  @override
  void onClose() {
    titleController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
