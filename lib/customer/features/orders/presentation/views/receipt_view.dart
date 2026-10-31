import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

class ReceiptController extends GetxController {
  void printReceipt() {
    Get.snackbar('طباعة', 'جاري طباعة الإيصال...');
  }
  void shareReceipt() {
    Get.snackbar('مشاركة', 'تم نسخ رابط الإيصال');
  }
}

class ReceiptView extends GetView<ReceiptController> {
  const ReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ReceiptController());
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
          'إيصال دفع',
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
          child: Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Text('سَطر', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const Text('ST-2048', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: AppSizes.md),
                      const Divider(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('التاريخ: 29 مايو 2025', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('طريقة الدفع: تحويل بنكي / محفظة', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                _buildRow('دفتر سلك مسطر', '28.00 ₪'),
                const SizedBox(height: 8),
                _buildRow('طباعة بحث العلوم.pdf', '66.00 ₪'),
                const Divider(height: 24),
                _buildRow('العناصر', '94.00 ₪'),
                const SizedBox(height: 8),
                _buildRow('التوصيل', '10.00 ₪'),
                const SizedBox(height: 8),
                _buildRow('الخصم', '0.00 ₪'),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('المبلغ المدفوع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                    Text('104.00 ₪', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: AppSizes.xl),
                Center(
                  child: Text('شكراً لاختيارك سطر', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
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
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
                onPressed: controller.printReceipt,
                icon: const Icon(Icons.print, color: AppColors.primary),
                label: const Text('طباعة', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                ),
                onPressed: controller.shareReceipt,
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text('مشاركة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
      ],
    );
  }
}
