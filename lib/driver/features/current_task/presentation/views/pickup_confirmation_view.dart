import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_message.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/driver/features/current_task/presentation/controllers/current_task_controller.dart';
import 'package:project/driver/features/current_task/presentation/controllers/pickup_confirmation_controller.dart';
import 'package:project/driver/shared/presentation/widgets/proof_photo_tile.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// "استلمت الطلب من المكتبة؟"
class DriverPickupConfirmationView extends GetView<DriverPickupConfirmationController> {
  const DriverPickupConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: DriverUi.bg,
      appBar: AppBar(backgroundColor: DriverUi.bg),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  color: AppColors.sand, size: AppSizes.iconLg),
            ),
            const SizedBox(height: AppSizes.xl),
            Text(
              l10n.drPickupConfirmTitle,
              textAlign: TextAlign.center,
              style: t.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              l10n.drPickupConfirmBody,
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.xl),
            Obx(
                  () => ProofPhotoTile(
                label: controller.photoRequired ? l10n.drPhotoRequired : l10n.drPhotoOptional,
                addLabel: l10n.drAddPhoto,
                addedLabel: l10n.drPhotoAdded,
                isUploading: controller.isUploading.value,
                hasPhoto: controller.photoId.value != null,
                onTap: controller.pickPhoto,
              ),
            ),
            Obx(() {
              final f = controller.error.value;
              if (f == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: AppSizes.md),
                child: Text(
                  failureMessage(l10n, f),
                  textAlign: TextAlign.center,
                  style: t.bodySmall?.copyWith(color: AppColors.error),
                ),
              );
            }),
            const Spacer(flex: 2),
            Obx(
                  () => AppButton(
                label: controller.isSubmitting.value
                    ? l10n.drPickupConfirming
                    : (Get.find<DriverCurrentTaskController>().task.value?.nextAction?.label ??
                    l10n.drPickupConfirmButton),
                isLoading: controller.isSubmitting.value,
                onPressed: controller.confirm,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            TextButton(onPressed: Get.back, child: Text(l10n.drPickupNotYet)),
          ],
        ),
      ),
    );
  }
}
