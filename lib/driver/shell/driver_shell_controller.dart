import 'package:get/get.dart';

/// التابات: 0 الرئيسية، 1 المتاح، 2 المهمة، 3 حسابي.
class DriverShellController extends GetxController {
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      currentIndex.value = (args['tab'] as int).clamp(0, 3).toInt();
    }
  }

  void goToTab(int i) => currentIndex.value = i;
}
