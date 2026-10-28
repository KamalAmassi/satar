import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/catalog/presentation/controllers/search_controller.dart';

class SearchView extends GetView<CustomerSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CustomerSearchController());
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
          'البحث',
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
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: controller.searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: controller.search,
                  decoration: InputDecoration(
                    hintText: 'شو بدور عليه اليوم؟',
                    hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => controller.searchController.clear(),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Recent Searches Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'آخر عمليات البحث',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: controller.clearRecent,
                    child: Text(
                      'مسح الكل',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),

              // Recent Searches List
              Obx(
                () => Column(
                  children: controller.recentSearches
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history, color: AppColors.textSecondary),
                          title: Text(
                            item,
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                            onPressed: () => controller.removeRecent(item),
                          ),
                          onTap: () => controller.search(item),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Discover By Category
              Text(
                'اكتشف حسب القسم',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSizes.md,
                crossAxisSpacing: AppSizes.md,
                childAspectRatio: 2.2,
                children: [
                  _buildCategoryChip('كتب', Icons.menu_book, () => controller.goToCategory('كتب')),
                  _buildCategoryChip('قرطاسية', Icons.auto_awesome, () => controller.goToCategory('قرطاسية')),
                  _buildCategoryChip('خدمات الطباعة', Icons.print, () => controller.goToCategory('خدمات الطباعة')),
                  _buildCategoryChip('ألعاب', Icons.sports_esports, () => controller.goToCategory('ألعاب')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
