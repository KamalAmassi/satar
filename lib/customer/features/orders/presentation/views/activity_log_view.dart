import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

class ActivityLogController extends GetxController {}

class ActivityLogView extends GetView<ActivityLogController> {
  const ActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ActivityLogController());
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
          'سجل نشاط الطلب',
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
            const Text('كل التحديثات والإجراءات المسجلة على الطلب، من الأحدث للقديم.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: AppSizes.lg),
            _buildLogItem('تحديث على طلبك', 'تم إنشاء ST-2048 وتم البدء بالتجهيز والطباعة.', 'اليوم 04:25 م', Icons.check_circle_outline),
            _buildLogItem('الدفع', 'تم اعتماد إشعار الدفع بنجاح.', 'اليوم 11:00 ص', Icons.payment),
            _buildLogItem('مراجعة السعر', 'بانتظار موافقة الزبون على السعر.', 'أمس', Icons.hourglass_empty),
            _buildLogItem('تم إنشاء الطلب', 'استلمت المكتبة الطلب ST-2048.', 'أمس 01:00 م', Icons.add_circle_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(String title, String desc, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
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
                  Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
