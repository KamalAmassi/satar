import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

class DeliveryFailureController extends GetxController {
  void contactLibrary() {
    Get.snackbar('اتصال', 'جاري الاتصال بالمكتبة...');
  }
}

class DeliveryFailureView extends GetView<DeliveryFailureController> {
  const DeliveryFailureView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DeliveryFailureController());
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
          'حالة التوصيل',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.close, color: AppColors.error, size: 40),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Text(
                'تعذر التسليم',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'السبب: العنوان غير صحيح أو لم نستطع التواصل مع صاحب السجل.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
                  onPressed: controller.contactLibrary,
                  child: const Text('تواصل مع المكتبة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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
