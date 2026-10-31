import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/orders/presentation/controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OrdersController());
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'طلباتي',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () => Get.toNamed(CustomerRoutes.notifications),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(AppSizes.pagePadding),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildSegmentButton('الطلبات الحالية', 0)),
                  Expanded(child: _buildSegmentButton('السابقة', 1)),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final isCurrent = controller.currentSegment.value == 0;
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
                  children: isCurrent
                      ? [
                          _buildOrderCard(
                            'ST-2080',
                            'بانتظار التحويل البنكي',
                            const Color(0xFFFEF3C7),
                            const Color(0xFFB45309),
                            '3 عناصر • منذ قليل',
                            '38.00 ₪',
                            'ادفع الآن',
                            () => Get.toNamed(CustomerRoutes.payment),
                          ),
                          const SizedBox(height: AppSizes.md),
                          _buildOrderCard(
                            'ST-2048',
                            'قيد التجهيز والطباعة',
                            const Color(0xFFFEF3C7),
                            const Color(0xFFB45309),
                            '6 عناصر • 29 مايو 04:25 م',
                            '104.00 ₪',
                            'تابع طلبك',
                            () => Get.toNamed(CustomerRoutes.liveTracking),
                          ),
                          const SizedBox(height: AppSizes.md),
                          _buildOrderCard(
                            'ST-2051',
                            'بانتظار موافقة الزبون على السعر',
                            const Color(0xFFE0F2FE),
                            const Color(0xFF0284C7),
                            '4 عناصر • اليوم',
                            'بانتظار العرض',
                            'راجع الطلب',
                            () => Get.toNamed(CustomerRoutes.offer),
                          ),
                          const SizedBox(height: AppSizes.md),
                          _buildOrderCard(
                            'ST-2035',
                            'بانتظار تعيين سائق',
                            const Color(0xFFF3E8FF),
                            const Color(0xFF7C3AED),
                            '2 عناصر • أمس',
                            '45.00 ₪',
                            'تفاصيل الطلب',
                            () => Get.toNamed(CustomerRoutes.assigningDriver),
                          ),
                        ]
                      : [
                          _buildOrderCard(
                            'ST-1980',
                            'تم التوصيل',
                            const Color(0xFFECFDF5),
                            const Color(0xFF059669),
                            '3 عناصر • 15 مايو',
                            '75.00 ₪',
                            'تقييم الطلب',
                            () => Get.toNamed(CustomerRoutes.rating),
                          ),
                          const SizedBox(height: AppSizes.md),
                          _buildOrderCard(
                            'ST-1950',
                            'تعذر التسليم',
                            const Color(0xFFFEE2E2),
                            const Color(0xFFE02424),
                            '1 عناصر • 10 مايو',
                            '20.00 ₪',
                            'حالة التوصيل',
                            () => Get.toNamed(CustomerRoutes.deliveryFailure),
                          ),
                        ],
                );
              }),
            ),
            const SizedBox(height: AppSizes.sm),

            // Quick Access Panel to all Figma screens
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('شاشات التتبع والإشعارات (اختبار سريع)', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13)),
                    const SizedBox(height: AppSizes.sm),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildActionChip('سجل النشاط', () => Get.toNamed(CustomerRoutes.activityLog)),
                        _buildActionChip('إيصال الدفع', () => Get.toNamed(CustomerRoutes.receipt)),
                        _buildActionChip('إلغاء الطلب', () => Get.toNamed(CustomerRoutes.cancelOrder)),
                        _buildActionChip('تعذر التسليم', () => Get.toNamed(CustomerRoutes.deliveryFailure)),
                        _buildActionChip('سائق غير محدد', () => Get.toNamed(CustomerRoutes.driverUnavailable)),
                        _buildActionChip('خطأ التقييم', () => Get.toNamed(CustomerRoutes.ratingError)),
                        _buildActionChip('رابط التتبع', () => Get.toNamed(CustomerRoutes.shareLinkReady)),
                        _buildActionChip('التتبع العام', () => Get.toNamed(CustomerRoutes.publicTracking)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentTab.value,
          onTap: controller.changeNavTab,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'طلباتي'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'التصنيفات'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(String label, int index) {
    return Obx(() {
      final isSelected = controller.currentSegment.value == index;
      return InkWell(
        onTap: () => controller.currentSegment.value = index,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOrderCard(String orderId, String status, Color statusBg, Color statusColor, String itemsInfo, String price, String actionLabel, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('رقم الطلب', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(orderId, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(itemsInfo, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary)),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.sm),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
                onPressed: onTap,
                child: Text(actionLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
      backgroundColor: AppColors.surfaceVariant,
      onPressed: onTap,
    );
  }
}
