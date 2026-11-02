import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/utils/view_status.dart';
import 'package:project/driver/features/current_task/presentation/controllers/current_task_controller.dart';
// import '../widgets/task_accepted_widget.dart';
// import '../widgets/task_details_widget.dart';

class DriverCurrentTaskView extends GetView<DriverCurrentTaskController> {
  const DriverCurrentTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFFCF7), // Background-App المعتمد بالفيجما
      body: SafeArea(
        child: Obx(() {
          // 1. حالة التحميل
          if (controller.status.value == ViewStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary)),
            );
          }

          // 2. فصل حالة الخطأ عن حالة عدم وجود مهمة، مع توفير إعادة المحاولة.
          final order = controller.task.value;
          if (controller.status.value == ViewStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 42, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'تعذر تحميل المهمة الحالية.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.load,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (order == null) {
            return const Center(
              child: Text(
                'لا توجد مهمة نشطة حالياً.',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            );
          }

          // 3. حالة جاري التحديث (شاشة الفيجما D23)
          // if (controller.isUpdatingStatus.value) {
          //   return const DriverPickupConfirmationView();
          // }

          // 4. بناء شاشات الفيجما التفاعلية بناءً على حالة الطلب (Status) القادمة من السيرفر
          // يمكنك تخصيص الواجهة حسب التدفق (D19 المقبولة، أو D20/D21 تفاصيل المهمة)
          // if (order.status.key == StatusKeys.accepted) {
          //   return TaskAcceptedWidget(order: order, controller: controller);
          // }

          // افتراضياً إذا تقدم في الخطوات يعرض تفاصيل المهمة المكتملة (D20, D21)
          // return TaskDetailsWidget(order: order, controller: controller);
          return Text('');
        }),
      ),
    );
  }
}
