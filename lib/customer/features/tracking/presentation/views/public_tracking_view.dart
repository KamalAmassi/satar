import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/customer/features/tracking/presentation/controllers/public_tracking_controller.dart';

class PublicTrackingView extends GetView<PublicTrackingController> {
  const PublicTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PublicTrackingController());
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'سَطر',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Order & Status Header
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                    child: const Text('قيد التوصيل', style: TextStyle(color: Color(0xFFB45309), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Text('ST-2048', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),

            // Map Area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.surfaceVariant),
                child: const Center(
                  child: Icon(Icons.map, size: 64, color: AppColors.textHint),
                ),
              ),
            ),

            // Details Bottom Sheet
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(AppSizes.pagePadding),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.directions_bike, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('وقت الوصول المتوقع: 12 دقيقة', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                    const Divider(height: 24),
                    Text('السائق', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    const Text('محمد', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: AppSizes.md),
                    Text('الوجهة', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    const Text('منطقة التوصيل المحددة', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const Spacer(),
                    const Center(
                      child: Text('يشكر لتعاملكم مع سطر', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
