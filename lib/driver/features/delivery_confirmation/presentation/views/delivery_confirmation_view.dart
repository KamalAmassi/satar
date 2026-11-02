import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_message.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/core/widgets/app_card.dart';
import 'package:project/core/widgets/app_text_field.dart';
import 'package:project/driver/features/delivery_confirmation/presentation/controllers/delivery_confirmation_controller.dart';
import 'package:project/driver/shared/domain/order_extensions.dart';
import 'package:project/driver/shared/presentation/widgets/proof_photo_tile.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// "تأكيد تسليم الطلب" — نسختين: مع تحصيل نقدي / بدون.
class DriverDeliveryConfirmationView extends GetView<DriverDeliveryConfirmationController> {
  const DriverDeliveryConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final order = controller.order;

    return Scaffold(
      backgroundColor: DriverUi.bg,
      appBar: AppBar(
        backgroundColor: DriverUi.bg,
        title: Text(l10n.drDeliveryConfirmTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          Text(
            order?.code ?? '',
            style: t.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          if (controller.needsCash)
            AppCard(
              color: AppColors.sand.withValues(alpha: 0.5),
              borderColor: AppColors.secondary.withValues(alpha: 0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.drDeliveryCollectCash,
                    style: t.labelLarge?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order!.cashToCollect.display,
                    style: t.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Obx(
                        () => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: controller.cashReceived.value,
                      onChanged: (v) => controller.cashReceived.value = v ?? false,
                      title: Text(l10n.drDeliveryCashReceived),
                    ),
                  ),
                ],
              ),
            )
          else
            AppCard(
              color: AppColors.info.withValues(alpha: 0.08),
              borderColor: AppColors.info.withValues(alpha: 0.3),
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined, color: AppColors.info),
                  const SizedBox(width: AppSizes.md),
                  Expanded(child: Text(l10n.drDeliveryNoCashNote)),
                ],
              ),
            ),
          const SizedBox(height: AppSizes.lg),
          Obx(
                () => AppTextField(
              label: l10n.drDeliveryCodeLabel,
              hint: l10n.drDeliveryCodeHint,
              controller: controller.codeController,
              keyboardType: TextInputType.number,
              ltr: true,
              errorText: controller.codeError.value,
              enabled: !controller.isSubmitting.value,
              onChanged: (_) => controller.codeError.value = null,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Obx(
                () => ProofPhotoTile(
              label: l10n.drPhotoOptional,
              addLabel: l10n.drAddPhoto,
              addedLabel: l10n.drPhotoAdded,
              isUploading: controller.isUploading.value,
              hasPhoto: controller.photoId.value != null,
              onTap: controller.pickPhoto,
            ),
          ),
          Obx(() {
            final f = controller.generalFailure.value;
            if (f == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: AppSizes.md),
              child: Text(
                failureMessage(l10n, f),
                style: t.bodySmall?.copyWith(color: AppColors.error),
              ),
            );
          }),
          const SizedBox(height: AppSizes.xl),
          Obx(
                () => AppButton(
              label: l10n.drDeliveryConfirmButton,
              isLoading: controller.isSubmitting.value,
              onPressed: () => controller.submit(
                codeRequired: l10n.drLoginRequiredField,
                cashRequired: l10n.drDeliveryNeedCash,
                codeInvalid: l10n.drDeliveryCodeInvalid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
