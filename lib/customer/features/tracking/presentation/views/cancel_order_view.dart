import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/customer/features/tracking/presentation/controllers/cancel_order_controller.dart';

class CancelOrderView extends GetView<CancelOrderController> {
  const CancelOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CancelOrderController());
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
          'إلغاء الطلب',
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSizes.lg),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 32),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'متأكد إنك بدك تلغي؟',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'الإلغاء لا يعيد المبالغ تلقائياً. إذا دفعت مسبقاً، تواصل مع المكتبة.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.xl),

              // Reasons Radio List
              _buildReasonTile('غيرت رأيي', 0),
              _buildReasonTile('العنوان غير صحيح', 1),
              _buildReasonTile('الانتظار طويل', 2),
              _buildReasonTile('عرض السعر غير مناسب', 3),
              _buildReasonTile('سبب آخر', 4),
              const SizedBox(height: AppSizes.md),

              TextField(
                controller: controller.notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'احكينا التفاصيل (اختياري)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd), borderSide: const BorderSide(color: AppColors.border)),
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
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE05252),
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
            ),
            onPressed: controller.confirmCancel,
            child: const Text('تأكيد إلغاء الطلب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildReasonTile(String label, int index) {
    return Obx(() {
      final isSelected = controller.selectedReason.value == index;
      return InkWell(
        onTap: () => controller.selectedReason.value = index,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.sm),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
              Radio<int>(
                value: index,
                groupValue: controller.selectedReason.value,
                onChanged: (val) => controller.selectedReason.value = val!,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      );
    });
  }
}
