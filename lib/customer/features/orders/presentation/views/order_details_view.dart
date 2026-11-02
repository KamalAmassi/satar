import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/orders/presentation/controllers/order_details_controller.dart';

class OrderDetailsView extends GetView<OrderDetailsController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OrderDetailsController());
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
          'تفاصيل الطلب',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final details = controller.orderDetails.value;
          final orderId = details?.id ?? controller.orderId.value;
          final statusLabel = details?.statusLabel ?? 'قيد التجهيز والطباعة';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header Card with Live Tracking Link
                InkWell(
                  onTap: () => Get.toNamed(CustomerRoutes.liveTracking),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(statusLabel, style: const TextStyle(color: AppColors.sand, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(orderId, style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: AppSizes.md),
                        Row(
                          children: const [
                            Icon(Icons.local_shipping_outlined, color: Colors.white),
                            SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Text(
                                'تتبع التوصيل • اضغط للتتبع المباشر للخريطة والسائق',
                                style: TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                Text('آخر التحديثات', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: AppSizes.sm),

                _buildTimelineStep('بانتظار قبول المكتبة', '٢٩ مايو', true),
                _buildTimelineStep('إشعار الدفع قيد المراجعة', '٢٩ مايو', true),
                _buildTimelineStep('قيد التجهيز والطباعة', 'اليوم', true),
                const SizedBox(height: AppSizes.lg),

                Text('عناصر الطلب', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: AppSizes.sm),

                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: AppColors.border)),
                  child: Column(
                    children: [
                      _buildItemRow('دفتر سلك مسطر × 2', '28.00 ₪'),
                      const Divider(height: 16),
                      _buildItemRow('بحث-العلوم.pdf', '66.00 ₪'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                Text('الدفع والتوصيل', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: AppColors.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('حالة الدفع: تم اعتماد إشعار الدفع', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.success)),
                          TextButton(
                            onPressed: () => Get.toNamed(CustomerRoutes.receipt),
                            child: const Text('عرض الإيصال', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('عنوان التوصيل: البيت - تفاصيل العنوان محفوظة', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
                onPressed: () => Get.toNamed(CustomerRoutes.offer),
                child: const Text('مراجعة عرض السعر', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
                onPressed: () => Get.toNamed(CustomerRoutes.rating),
                child: const Text('تقييم طلب مكتمل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primary : AppColors.border,
              shape: BoxShape.circle,
            ),
            child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
          const SizedBox(width: AppSizes.md),
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isCompleted ? AppColors.primary : AppColors.textSecondary)),
          const Spacer(),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildItemRow(String title, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
        Text(price, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
      ],
    );
  }
}
