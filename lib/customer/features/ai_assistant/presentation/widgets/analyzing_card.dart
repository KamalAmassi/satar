import 'package:flutter/material.dart';
import 'package:project/core/animations/app_motion.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/widgets/app_loading.dart';

class AnalyzingCard extends StatelessWidget {
  const AnalyzingCard({super.key, required this.steps, required this.step});

  final List<String> steps;
  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const AppLoading(size: 28),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.normal,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Align(
                key: ValueKey(step),
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  steps[step.clamp(0, steps.length - 1)],
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}