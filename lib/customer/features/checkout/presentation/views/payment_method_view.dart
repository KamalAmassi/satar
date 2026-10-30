import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/widgets/purchase_widgets.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_details.dart';
import 'package:project/customer/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:project/customer/features/checkout/presentation/widgets/checkout_steps.dart';

/// طريقة الدفع (C3 / Checkout / Payment Method). الطرق من الإعداد.
class PaymentMethodView extends GetView<CheckoutController> {
  const PaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: PurchaseHeader(
        title: l10n.paymentMethodTitle,
        cartCount: () => controller.cart.itemCount,
        onCartTap: () => Get.toNamed(CustomerRoutes.cart),
      ),
      bottomNavigationBar: Obx(() => PurchaseBottomBar(
            actionLabel: l10n.reviewOrder,
            onAction: controller.details.value.paymentMethod == null
                ? null
                : () => Get.toNamed(CustomerRoutes.priceReview),
          )),
      body: Obx(() {
        final methods = controller.availablePaymentMethods;
        final selected = controller.details.value.paymentMethod;
        return ListView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          children: [
            const CheckoutSteps(current: 1),
            const SizedBox(height: AppSizes.lg),
            Text(l10n.howToPay, style: text.titleLarge),
            const SizedBox(height: AppSizes.md),
            if (methods.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              RadioGroup<String>(
                groupValue: selected,
                onChanged: (v) {
                  if (v != null) controller.setPaymentMethod(v);
                },
                child: Column(
                  children: [
                    for (final m in methods) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        onTap: () => controller.setPaymentMethod(m),
                        child: SectionCard(
                          highlighted: m == selected,
                          padding: const EdgeInsets.all(AppSizes.md),
                          child: Row(
                            children: [
                              Radio<String>(value: m),
                              Icon(
                                m == PaymentMethod.cash
                                    ? Icons.payments_outlined
                                    : Icons.account_balance_outlined,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSizes.md),
                              Expanded(
                                child: Text(
                                  m == PaymentMethod.cash
                                      ? l10n.payCashOnDelivery
                                      : l10n.payBankTransfer,
                                  style: text.titleSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: AppSizes.sm),
            Text(
              selected == PaymentMethod.transfer
                  ? l10n.transferAfterOrderNote
                  : l10n.paymentMethodNote,
              style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        );
      }),
    );
  }
}
