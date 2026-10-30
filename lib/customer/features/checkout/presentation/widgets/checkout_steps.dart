import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

/// شريط الخطوات أعلى الدفع: التوصيل ← طريقة الدفع ← المراجعة.
class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({super.key, required this.current, this.total = 3});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: AppSizes.xs),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: i <= current ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      );
}
