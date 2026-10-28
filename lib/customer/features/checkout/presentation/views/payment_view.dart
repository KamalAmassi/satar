import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/customer/features/checkout/presentation/controllers/payment_controller.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PaymentController());
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
          'التحويل والدفع',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                child: const Text('بانتظار التحويل ورفع إشعار الدفع', style: TextStyle(color: Color(0xFFB45309), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: AppSizes.md),
              Text('حول المبلغ وارفع الإشعار', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: AppSizes.lg),

              // Bank Info Card
              Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('بيانات تحويل فورية', style: textTheme.bodySmall?.copyWith(color: AppColors.sand)),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.sand),
                            foregroundColor: AppColors.sand,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          onPressed: () => Get.snackbar('تم النسخ', 'تم نسخ رقم الحساب بنجاح'),
                          icon: const Icon(Icons.copy, size: 14),
                          label: const Text('نسخ', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'حساب المكتبة / المحفظة',
                      style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text('•••• •••• ••••', style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2)),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              Text('استخدم بيانات الحساب اللي توفرها المنصة، احتفظ بصورة واضحة لإشعار التحويل لرفع الإشعار وانتظار مراجعة المكتبة.', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSizes.lg),

              // Upload Receipt Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.primary),
                    const SizedBox(height: AppSizes.md),
                    Text('ارفع إشعار التحويل', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('صورة PDF، أو JPG، حدد 10 MB', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
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
                const Text('المبلغ المطلوب', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const Text('38.00 ₪', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.primary)),
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
                onPressed: controller.submitPayment,
                child: const Text('تتبع الطلب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
