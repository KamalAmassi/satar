import 'package:flutter/material.dart';
import 'package:project/core/animations/floating_effect.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/welcome/presentation/widgets/paper_sheet.dart';
import 'package:project/welcome/presentation/widgets/welcome_vector_art.dart';

class OnboardingPageItem extends StatelessWidget {
  const OnboardingPageItem({
    super.key,
    required this.index,
    required this.title,
    required this.body,
    required this.counter,
  });

  final int index;
  final String title;
  final String body;
  final String counter;

  Widget _buildArt() {
    switch (index) {
      case 0: return const BookStackArt();
      case 1: return const PrintSheetArt();
      case 2: return const AssistantBubbleArt();
      default: return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.lg),
          FloatingEffect(
            child: PaperSheet(
              rotationAngle: index == 0 ? 0.01 : -0.01,
              child: SizedBox(
                width: double.infinity,
                height: 240,
                child: Center(child: _buildArt()),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl * 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.stamp.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              counter,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.stamp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            body,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
