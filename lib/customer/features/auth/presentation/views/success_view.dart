import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/customer/features/auth/presentation/controllers/success_controller.dart';

class SuccessView extends GetView<CustomerSuccessController> {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CustomerSuccessController());
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.sand,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Text(
                'نورت سطراً!',
                style: textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'جاهز نبدأ؟',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.sand,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'التالي',
                  variant: AppButtonVariant.light,
                  onPressed: controller.continueToHome,
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
