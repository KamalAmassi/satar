import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 32 : 12,
          height: 3,
          decoration: BoxDecoration(
            color: active
                ? AppColors.ink
                : AppColors.ink.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}