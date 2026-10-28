import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/addresses/presentation/controllers/addresses_controller.dart';

class AddressesView extends GetView<AddressesController> {
  const AddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddressesController());
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
          'عنوان التوصيل',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('وين توصيلك؟', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                  TextButton.icon(
                    onPressed: () => Get.toNamed(CustomerRoutes.addressForm),
                    icon: const Icon(Icons.add, size: 16, color: AppColors.secondary),
                    label: const Text('+ أضف عنوان', style: TextStyle(color: AppColors.secondary)),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),

              // Address Cards
              _buildAddressCard('البيت', 'داخل منطقة التوصيل', 0, Icons.home_outlined),
              const SizedBox(height: AppSizes.md),
              _buildAddressCard('العمل', 'خارج منطقة التوصيل', 1, Icons.work_outline),
              const SizedBox(height: AppSizes.lg),

              Text('اسم المستلم (اختياري)', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.xs),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: AppColors.border)),
                child: TextField(
                  controller: controller.recipientNameController,
                  decoration: const InputDecoration(hintText: 'الاسم', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md)),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              Text('رقم الهاتف (اختياري)', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.xs),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: AppColors.border)),
                child: TextField(
                  controller: controller.recipientPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: '+970 5X XXX XXXX', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md)),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              Text('ملاحظات التوصيل', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.xs),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSizes.radiusMd), border: Border.all(color: AppColors.border)),
                child: TextField(
                  controller: controller.notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: 'علبة مميزة أو تفاصيل الوصول', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm)),
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
                const Text('المجموع', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
                onPressed: controller.proceedToPayment,
                child: const Text('متابعة للدفع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(String title, String subtitle, int index, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedAddress.value == index;
      return InkWell(
        onTap: () => controller.selectedAddress.value = index,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Radio<int>(
                value: index,
                groupValue: controller.selectedAddress.value,
                onChanged: (val) => controller.selectedAddress.value = val!,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      );
    });
  }
}
