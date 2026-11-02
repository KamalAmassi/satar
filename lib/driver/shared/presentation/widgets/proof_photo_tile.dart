import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/widgets/app_card.dart';

/// سطر "صورة إثبات": يلتقط صورة ويرفعها (الرفع من الـ controller).
class ProofPhotoTile extends StatelessWidget {
  const ProofPhotoTile({
    super.key,
    required this.label,
    required this.addLabel,
    required this.addedLabel,
    required this.onTap,
    this.isUploading = false,
    this.hasPhoto = false,
  });

  final String label;
  final String addLabel;
  final String addedLabel;
  final VoidCallback onTap;
  final bool isUploading;
  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      onTap: isUploading ? null : onTap,
      child: Row(
        children: [
          Icon(
            hasPhoto ? Icons.check_circle_rounded : Icons.photo_camera_outlined,
            color: hasPhoto ? AppColors.success : AppColors.secondary,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: t.labelMedium?.copyWith(color: AppColors.textSecondary)),
                Text(
                  hasPhoto ? addedLabel : addLabel,
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (isUploading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
