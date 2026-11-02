import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';

/// شريط خطوات المهمة: مقبول ← استلام ← بالطريق ← وصلت ← تسليم.
class TaskProgressSteps extends StatelessWidget {
  const TaskProgressSteps({super.key, required this.statusKey, required this.labels});

  /// الترتيب الثابت للحالات.
  static const order = ['accepted', 'picked_up', 'on_the_way', 'arrived', 'delivered'];

  final String statusKey;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final index = order.indexOf(statusKey).clamp(0, order.length - 1);
    final t = Theme.of(context).textTheme;

    return Row(
      children: List.generate(order.length, (i) {
        final done = i <= index;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i == 0
                          ? Colors.transparent
                          : (done ? AppColors.primary : AppColors.border),
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: done ? AppColors.primary : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i == order.length - 1
                          ? Colors.transparent
                          : (i < index ? AppColors.primary : AppColors.border),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                labels[i],
                style: t.labelSmall?.copyWith(
                  color: done ? AppColors.primary : AppColors.textHint,
                  fontWeight: i == index ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
