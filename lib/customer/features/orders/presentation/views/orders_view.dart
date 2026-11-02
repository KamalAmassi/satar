import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/widgets/app_logo.dart';
import 'package:project/customer/features/orders/presentation/controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OrdersController());
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding, vertical: AppSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLogo(size: 32),
                  Text(
                    'طلباتي',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
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
            ),

            // Top Tabs (الطلبات الحالية / المكتملة / الملغية)
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTab('الملغية', 2)),
                  Expanded(child: _buildTab('المكتملة', 1)),
                  Expanded(child: _buildTab('الطلبات الحالية', 0)),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (controller.orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد طلبات في هذا القسم',
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  children: [
                    for (final order in controller.orders) ...[
                      _buildOrderCard(
                        id: order.id,
                        status: order.statusLabel,
                        statusBg: order.status == 'preparing'
                            ? const Color(0xFFFEF3C7)
                            : order.status == 'awaiting_approval'
                                ? const Color(0xFFE0F2FE)
                                : order.status == 'delivered'
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFEE2E2),
                        statusFg: order.status == 'preparing'
                            ? const Color(0xFFB45309)
                            : order.status == 'awaiting_approval'
                                ? const Color(0xFF0284C7)
                                : order.status == 'delivered'
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFE02424),
                        date: order.date,
                        itemsCount: order.itemsCount,
                        price: order.price,
                        buttonLabel: order.actionLabel,
                        onButtonTap: () {
                          if (order.status == 'preparing') {
                            Get.toNamed(CustomerRoutes.liveTracking);
                          } else if (order.status == 'awaiting_approval') {
                            Get.toNamed(CustomerRoutes.offer);
                          } else if (order.status == 'delivered') {
                            Get.toNamed(CustomerRoutes.rating);
                          } else {
                            Get.toNamed(CustomerRoutes.orderDetails, arguments: order.id);
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],

                    // Loading State: جاري تحميل طلبات إضافية
                    if (controller.isLoadingMore.value) ...[
                      const SizedBox(height: AppSizes.md),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'جاري تحميل طلبات إضافية',
                              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Error Banner: تعذّر تحميل المزيد من الطلبات
                    if (controller.hasMoreError.value) ...[
                      const SizedBox(height: AppSizes.md),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تعذّر تحميل المزيد من الطلبات.',
                              style: textTheme.bodySmall?.copyWith(color: const Color(0xFF991B1B)),
                            ),
                            GestureDetector(
                              onTap: controller.retryLoadMore,
                              child: Text(
                                'إعادة المحاولة',
                                style: textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF991B1B),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentNavTab.value,
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

  Widget _buildTab(String title, int index) {
    return Obx(() {
      final isSelected = controller.currentTab.value == index;
      return InkWell(
        onTap: () => controller.selectTab(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildOrderCard({
    required String id,
    required String status,
    required Color statusBg,
    required Color statusFg,
    required String date,
    required String itemsCount,
    required String price,
    required String buttonLabel,
    required VoidCallback onButtonTap,
  }) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: TextStyle(color: statusFg, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('رقم الطلب', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(id, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: AppSizes.md),
              const Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(itemsCount, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.sm),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
                onPressed: onButtonTap,
                child: Text(buttonLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: price.contains('بانتظار') ? AppColors.textSecondary : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
