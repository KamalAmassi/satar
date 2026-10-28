import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class SearchResultsController extends GetxController {
  final searchQuery = 'دفتر'.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      searchQuery.value = Get.arguments.toString();
      searchController.text = searchQuery.value;
    }
  }

  void goToProductDetails() {
    Get.toNamed(CustomerRoutes.productDetails);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
