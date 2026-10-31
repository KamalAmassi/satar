import 'package:flutter/material.dart';
import 'package:project/core/animations/app_motion.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

class AssistantInputCard extends StatelessWidget {
  const AssistantInputCard({
    super.key,
    required this.controller,
    required this.hint,
    required this.isDisabled,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String hint;

  /// يعطّل الحقل وزر الإرسال (أثناء التسجيل أو التحليل). بدون مؤشر تحميل هون.
  final bool isDisabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            enabled: !isDisabled,
            minLines: 4,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(fontSize: 15, height: 1.6),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.lg,
                64,
              ),
            ),
          ),
          PositionedDirectional(
            bottom: AppSizes.md,
            end: AppSizes.md,
            child: AnimatedOpacity(
              duration: AppMotion.fast,
              opacity: isDisabled ? 0.45 : 1,
              child: Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isDisabled ? null : onSubmit,
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.auto_awesome,
                      color: AppColors.sand,
                      size: 20,
                    ),
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