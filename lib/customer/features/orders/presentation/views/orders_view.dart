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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                onPressed: () => Get.toNamed(CustomerRoutes.cart),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segment Switcher
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

            // Orders List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
                children: [
                  _buildOrderCard(
                    'ST-2048',
                    'قيد التجهيز والطباعة',
                    const Color(0xFFFEF3C7),
                    const Color(0xFFB45309),
                    '6 عناصر',
                    '104.00 ₪',
                    'دفع سلف',
                    () => controller.goToOrderDetails(),
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildOrderCard(
                    'ST-2051',
                    'بانتظار موافقة الزبون على السعر',
                    const Color(0xFFE0F2FE),
                    const Color(0xFF0284C7),
                    '3 عناصر',
                    'بانتظار العرض',
                    'راجِع العرض',
                    () => Get.toNamed(CustomerRoutes.offer),
                  ),
                ],
              ),
            ),
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
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
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

  Widget _buildOrderCard(String orderId, String status, Color statusBg, Color statusColor, String itemsCount, String price, String actionLabel, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('رقم الطلب\n$orderId', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                  child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(itemsCount, style: const TextStyle(color: AppColors.textSecondary)),
                Text(price, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(actionLabel, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
