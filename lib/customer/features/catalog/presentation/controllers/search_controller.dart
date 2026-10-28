import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';

class CustomerSearchController extends GetxController {
  final searchController = TextEditingController();
  final recentSearches = <String>['دفتر رسم', 'ألوان خشبية', 'قصص أطفال'].obs;

  void removeRecent(String item) {
    recentSearches.remove(item);
  }

  void clearRecent() {
    recentSearches.clear();
  }

  void search(String query) {
    if (query.trim().isNotEmpty) {
      Get.toNamed(CustomerRoutes.searchResults, arguments: query);
    }
  }

  void goToCategory(String categoryName) {
    Get.toNamed(CustomerRoutes.products, arguments: categoryName);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
