import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

class NotificationsController extends GetxController {}

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationsController());
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'الإشعارات',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          children: [
            _buildNotificationItem('تحديث على طلبك', 'تم اعتماد ST-2048 قيد التجهيز والطباعة.', 'اليوم 1:30 ص'),
            const SizedBox(height: AppSizes.md),
            _buildNotificationItem('تم اعتماد إشعار الدفع', 'استلمت المكتبة الإشعار وجاري المراجعه الآن.', 'اليوم 11:00 ص'),
            const SizedBox(height: AppSizes.md),
            _buildNotificationItem('عرض السعر جاهز', 'مكتبة سطر جهزت عرض سعر طلبك الجديد.', 'أمس'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String body, String time) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.notifications_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
