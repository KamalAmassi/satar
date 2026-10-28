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
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : AppColors.secondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}