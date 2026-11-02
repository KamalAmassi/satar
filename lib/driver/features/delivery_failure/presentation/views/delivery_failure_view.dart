import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_message.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/core/widgets/app_text_field.dart';
import 'package:project/driver/features/delivery_failure/domain/entities/failure_reason.dart';
import 'package:project/driver/features/delivery_failure/presentation/controllers/delivery_failure_controller.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

class DriverDeliveryFailureView extends GetView<DriverDeliveryFailureController> {
  const DriverDeliveryFailureView({super.key});

  static String _label(AppLocalizations l, FailureReason r) {
    if (r.label != null) return r.label!;
    switch (r.key) {
      case 'customer_unreachable':
        return l.drFailureReasonUnreachable;
      case 'wrong_address':
        return l.drFailureReasonWrongAddress;
      case 'customer_refused':
        return l.drFailureReasonRefused;
      case 'customer_not_available':
        return l.drFailureReasonNotHome;
      default:
        return l.drFailureReasonOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: DriverUi.bg,
      appBar: AppBar(backgroundColor: DriverUi.bg, title: Text(l10n.drReportFailure)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          Text(
            l10n.drFailureTitle,
            style: t.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Obx(
                () => Column(
              children: [
                for (final r in controller.reasons)
                  RadioListTile<FailureReason>(
                    contentPadding: EdgeInsets.zero,
                    value: r,
                    groupValue: controller.selected.value,
                    onChanged: (v) {
                      if (v != null) controller.select(v);
                    },
                    title: Text(_label(l10n, r)),
                  ),
              ],
            ),
          ),
          Obx(
                () => controller.pickError.value
                ? Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Text(
                l10n.drFailurePickReason,
                style: t.bodySmall?.copyWith(color: AppColors.error),
              ),
            )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DriverUi.warnBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.drFailureNotice,
                    style: const TextStyle(fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          AppTextField(
            label: l10n.drFailureNotesHint,
            controller: controller.notesController,
            maxLines: 3,
          ),
          Obx(() {
            final f = controller.error.value;
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
              label: l10n.drFailureSubmit,
              isLoading: controller.isSubmitting.value,
              onPressed: controller.submit,
            ),
          ),
        ],
      ),
    );
  }
}
