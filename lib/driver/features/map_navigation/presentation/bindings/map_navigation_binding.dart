import 'package:get/get.dart';
import '../controllers/map_navigation_controller.dart';

class MapNavigationBinding extends Bindings {
  @override
  void dependencies() {
    // حقن الـ Controller المسؤول عن إدارة الخريطة وبث الموقع الحي
    Get.lazyPut<MapNavigationController>(
      () => MapNavigationController(),
    );
  }
}
