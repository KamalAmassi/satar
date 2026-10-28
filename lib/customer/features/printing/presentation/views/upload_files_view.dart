import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/printing/presentation/controllers/upload_files_controller.dart';

class UploadFilesView extends GetView<UploadFilesController> {
  const UploadFilesView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(UploadFilesController());
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
          'لرفع ملفاتك',
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
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'شو بدك تطبع؟',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'المطلب المكتوبة',
                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSizes.xs),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: controller.titleController,
                  decoration: const InputDecoration(
                    hintText: 'مثلاً: ملزمة حقوق الإدارية الأولى 2024',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                'العدد التقديري',
                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSizes.xs),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: '120 ورقة • وجه وظهر • تغليف عادي',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Upload Box
              GestureDetector(
                onTap: controller.pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.xxl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.description_outlined, size: 48, color: AppColors.primary),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'اضغط لاختيار ملف',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'أو اسحب الملف ودعه هنا',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                  ),
                  onPressed: controller.continueToSpecs,
                  child: const Text('حدد مواصفات الطباعة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}
