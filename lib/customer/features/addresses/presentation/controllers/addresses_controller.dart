import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class AddressesController extends GetxController {
  final selectedAddress = 0.obs; // 0: البيت, 1: العمل
  final recipientNameController = TextEditingController();
  final recipientPhoneController = TextEditingController();
  final notesController = TextEditingController();

  void proceedToPayment() {
    Get.toNamed(CustomerRoutes.payment);
  }

  @override
  void onClose() {
    recipientNameController.dispose();
    recipientPhoneController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
