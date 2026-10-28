import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CartController());
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
          'سلتك',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المنتجات', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: AppSizes.sm),

              // Product Cart Item
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Center(child: Icon(Icons.book, color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('دفتر سلك مسطر', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          Text('اللون: بيج • حجم A5', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text('14.00 ₪', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Printing Cart Item
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Center(child: Icon(Icons.description, color: Color(0xFF7C3AED))),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('بحث-العلوم.pdf', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          Text('تلون، بيجاري، مستكل A4', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text('14.00 ₪', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Delivery Options
              Text('طريقة التوصيل', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(child: _buildDeliveryChip('حسب العنوان', 0)),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: _buildDeliveryChip('استلام من المركز', 1)),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // Summary Box
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('المنتجات', '28.00 ₪'),
                    const Divider(height: 16),
                    _buildSummaryRow('رسوم التوصيل', 'حسب العنوان'),
                    const Divider(height: 16),
                    _buildSummaryRow('المجموع الحالي', '28.00 ₪', isBold: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('المجموع الكلي', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const Text('28.00 ₪', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.primary)),
              ],
            ),
            const SizedBox(width: AppSizes.xl),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
                onPressed: controller.proceedToDelivery,
                child: const Text('تابع للتوصيل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryChip(String label, int index) {
    return Obx(() {
      final isSelected = controller.deliveryType.value == index;
      return InkWell(
        onTap: () => controller.deliveryType.value = index,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFDF2F8) : Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? AppColors.primary : AppColors.textSecondary, fontWeight: isBold ? FontWeight.w700 : FontWeight.normal)),
        Text(value, style: TextStyle(color: AppColors.primary, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600)),
      ],
    );
  }
}
