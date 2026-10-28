import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

class OnboardingPageItem extends StatelessWidget {
  const OnboardingPageItem({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.body,
    required this.counter,
  });

  final String imageAsset;
  final String title;
  final String body;
  final String counter;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.sand.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_outlined,
                  size: AppSizes.iconLg * 2,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            counter,
            style: textTheme.labelSmall?.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            body,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}