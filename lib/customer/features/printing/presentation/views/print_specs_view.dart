import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/printing/presentation/controllers/print_specs_controller.dart';

class PrintSpecsView extends GetView<PrintSpecsController> {
  const PrintSpecsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PrintSpecsController());
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
          'مواصفات الملفات',
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
              // File Card
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: AppColors.primary, size: 32),
                    const SizedBox(width: AppSizes.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('بحث-العلوم.pdf', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        Text('45 صفحة', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Page Size
              Text('حجم الورق', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  _buildSpecChip('A4', 0, controller.selectedSize),
                  const SizedBox(width: AppSizes.sm),
                  _buildSpecChip('A3', 1, controller.selectedSize),
                ],
              ),
              const Divider(height: 32),

              // Color
              Text('اللون', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  _buildSpecChip('ملون', 0, controller.selectedColor),
                  const SizedBox(width: AppSizes.sm),
                  _buildSpecChip('أبيض و أسود', 1, controller.selectedColor),
                ],
              ),
              const Divider(height: 32),

              // Print Type
              Text('الطباعة', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  _buildSpecChip('وجهان', 0, controller.selectedType),
                  const SizedBox(width: AppSizes.sm),
                  _buildSpecChip('وجه واحد', 1, controller.selectedType),
                ],
              ),
              const Divider(height: 32),

              // Binding
              Text('التجليد', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                children: [
                  _buildSpecChip('تجليد سلكي', 0, controller.selectedBinding),
                  _buildSpecChip('تجليد كرتون', 1, controller.selectedBinding),
                  _buildSpecChip('كبس', 2, controller.selectedBinding),
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
                      Text('عدد النسخ', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                      Text('الصفحة × 2 نسخة', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.remove), onPressed: controller.decrement),
                        Obx(() => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                              child: Text('${controller.quantity.value}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            )),
                        IconButton(icon: const Icon(Icons.add), onPressed: controller.increment),
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
                const Text('السعر', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const Text('20.00 ₪', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.primary)),
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
                onPressed: controller.reviewPrice,
                child: const Text('مراجعة السعر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip(String label, int index, RxInt controllerVar) {
    return Obx(() {
      final isSelected = controllerVar.value == index;
      return InkWell(
        onTap: () => controllerVar.value = index,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFDF2F8) : Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
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
}
