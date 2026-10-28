import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/catalog/presentation/controllers/product_details_controller.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProductDetailsController());
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
          'تفاصيل المنتج',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Preview
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: const Center(
                  child: Icon(Icons.book, size: 80, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Title & Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('متوفر', style: TextStyle(color: Color(0xFF0284C7), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          'دفتر سلك مسطر بغلاف مقوى',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'دفتر عملي للمدرسة والمكتب، ورق مريح للكتابة وحجم A5',
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '12.00 ₪',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Color Options
              Text(
                'لون الغلاف',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  _buildColorChip('بيج', '+0.00 ₪', 0),
                  const SizedBox(width: AppSizes.sm),
                  _buildColorChip('أحمر', '+0.50 ₪', 1),
                  const SizedBox(width: AppSizes.sm),
                  _buildColorChip('كحلي', '+0.50 ₪', 2),
                ],
              ),
              const Divider(height: 32),

              // Extras
              Text(
                'إضافات',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                children: [
                  _buildExtraChip('ملصق اسم (+2.20 ₪)', 'ملصق اسم'),
                  _buildExtraChip('تغليف هدية (+3.00 ₪)', 'تغليف هدية'),
                ],
              ),
              const Divider(height: 32),

              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الكمية',
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                      Text(
                        'الحد الأدنى: 1',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: controller.decrement,
                        ),
                        Obx(
                          () => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                            child: Text(
                              '${controller.quantity.value}',
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: controller.increment,
                        ),
                      ],
                    ),
                  ),
                ],
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
                const Text('المجموع', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Obx(
                  () => Text(
                    '${controller.totalPrice.toStringAsFixed(2)} ₪',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.primary),
                  ),
                ),
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
                onPressed: controller.addToCart,
                child: const Text('أضف للسلة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChip(String label, String price, int index) {
    return Obx(
      () {
        final isSelected = controller.selectedColor.value == index;
        return InkWell(
          onTap: () => controller.selectedColor.value = index,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFDF2F8) : Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
            ),
            child: Column(
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : AppColors.textSecondary)),
                Text(price, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExtraChip(String label, String extraKey) {
    return Obx(
      () {
        final isSelected = controller.selectedExtras.contains(extraKey);
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => controller.toggleExtra(extraKey),
          selectedColor: const Color(0xFFFDF2F8),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
