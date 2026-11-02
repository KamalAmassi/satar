import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/driver/features/delivery_confirmation/presentation/delivery_success_args.dart';
import 'package:project/driver/shared/domain/order_extensions.dart';

/// "تم التسليم بنجاح" — شاشة داكنة كاملة.
class DriverDeliverySuccessView extends StatelessWidget {
  const DriverDeliverySuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    final args = Get.arguments as DeliverySuccessArgs;

    Widget stat(String label, String value) => Expanded(
      child: Column(
        children: [
          Text(label,
              style: t.labelMedium?.copyWith(color: AppColors.sand.withValues(alpha: 0.8))),
          const SizedBox(height: 4),
          Text(value,
              style: t.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.sand,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 56, color: AppColors.primary),
                ),
                const SizedBox(height: AppSizes.xl),
                Text(
                  l10n.drDeliverySuccessTitle,
                  style: t.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                Row(
                  children: [
                    if (args.collected != null)
                      stat(l10n.drDeliverySuccessCollected, args.collected!.display),
                    stat(l10n.drDeliverySuccessOrder, args.orderNumber),
                  ],
                ),
                const Spacer(),
                AppButton(
                  label: l10n.drDeliverySuccessHistory,
                  variant: AppButtonVariant.light,
                  onPressed: () => Get.offNamedUntil(
                    DriverRoutes.tasksHistory,
                    (r) => r.settings.name == DriverRoutes.home,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                TextButton(
                  onPressed: () =>
                      Get.offAllNamed(DriverRoutes.home, arguments: {'tab': 0}),
                  style: TextButton.styleFrom(foregroundColor: AppColors.sand),
                  child: Text(l10n.drDeliverySuccessHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
