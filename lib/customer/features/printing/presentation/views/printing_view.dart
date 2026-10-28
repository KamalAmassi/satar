import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/printing/presentation/controllers/printing_controller.dart';

class PrintingView extends GetView<PrintingController> {
  const PrintingView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PrintingController());
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
          'خدمات الطباعة',
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
            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.xl),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                children: [
                  const Icon(Icons.print, color: AppColors.sand, size: 48),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'من الألف للياء ملفاتك علينا!',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ارفع ملفك، حدد المواصفات، وباقي الطباعة علينا',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(color: AppColors.sand),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'خدمات الطباعة',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Printing Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSizes.md,
                crossAxisSpacing: AppSizes.md,
                childAspectRatio: 0.85,
                children: [
                  _buildServiceCard('تصوير ملازم حقوق', Icons.content_copy),
                  _buildServiceCard('طباعة ملونة A4', Icons.color_lens),
                  _buildServiceCard('أبيض وأسود A4', Icons.description),
                ],
              ),
            ),
            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                  ),
                  onPressed: controller.startPrinting,
                  child: const Text('ابدأ بطلب طباعة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
