import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_messages.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/widgets/purchase_widgets.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_address.dart';
import 'package:project/customer/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:project/customer/features/checkout/presentation/widgets/checkout_steps.dart';

/// عنوان التوصيل وبيانات المستلم (إطار 18).
class DeliveryView extends StatefulWidget {
  const DeliveryView({super.key});

  @override
  State<DeliveryView> createState() => _DeliveryViewState();
}

class _DeliveryViewState extends State<DeliveryView> {
  final controller = Get.find<CheckoutController>();
  late final _name =
      TextEditingController(text: controller.details.value.recipientName);
  late final _phone =
      TextEditingController(text: controller.details.value.recipientPhone);
  late final _notes =
      TextEditingController(text: controller.details.value.deliveryNotes);

  @override
  void initState() {
    super.initState();
    controller.start();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// عقد العناوين → الدفع: شاشة محمد تعيد معرّف العنوان المحفوظ.
  Future<void> _addAddress() async {
    final result = await Get.toNamed(CustomerRoutes.addressForm);
    await controller.loadAddresses();
    if (result is int) controller.selectAddress(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: PurchaseHeader(
        title: l10n.deliveryTitle,
        cartCount: () => controller.cart.itemCount,
        onCartTap: () => Get.toNamed(CustomerRoutes.cart),
      ),
      bottomNavigationBar: Obx(() => PurchaseBottomBar(
            actionLabel: l10n.continueToPayment,
            onAction: controller.canContinueFromDelivery
                ? () => Get.toNamed(CustomerRoutes.paymentMethod)
                : null,
          )),
      body: Obx(() {
        final selected = controller.details.value.addressId;
        return ListView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          children: [
            const CheckoutSteps(current: 0),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: Text(l10n.whereToDeliver, style: text.titleMedium),
                ),
                TextButton.icon(
                  onPressed: _addAddress,
                  icon: const Icon(Icons.add, size: AppSizes.iconSm),
                  label: Text(l10n.addAddress),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            if (controller.addressesLoading.value &&
                controller.addresses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSizes.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.addressesFailure.value != null)
              PurchaseBanner(
                tone: BannerTone.error,
                message: controller.addressesFailure.value!.describe(context),
                action: TextButton(
                  onPressed: controller.loadAddresses,
                  child: Text(l10n.retry),
                ),
              )
            else if (controller.addresses.isEmpty)
              PurchaseBanner(message: l10n.noAddresses)
            else
              RadioGroup<int>(
                groupValue: selected,
                onChanged: (id) {
                  if (id != null) controller.selectAddress(id);
                },
                child: Column(
                  children: [
                    for (final a in controller.addresses) ...[
                      _AddressCard(
                        address: a,
                        selected: a.id == selected,
                        outOfZone:
                            controller.outOfZoneAddressIds.contains(a.id),
                        onTap: () => controller.selectAddress(a.id),
                      ),
                      const SizedBox(height: AppSizes.sm),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: AppSizes.lg),
            Text(l10n.recipientNameOptional, style: text.titleSmall),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _name,
              maxLength: 255,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  hintText: l10n.recipientNameHint, counterText: ''),
              onChanged: controller.setRecipientName,
            ),
            const SizedBox(height: AppSizes.md),
            Text(l10n.recipientPhoneOptional, style: text.titleSmall),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: '+970 5X XXX XXXX',
                hintTextDirection: TextDirection.ltr,
                errorText:
                    controller.isRecipientPhoneValid ? null : l10n.phoneInvalid,
              ),
              onChanged: controller.setRecipientPhone,
            ),
            const SizedBox(height: AppSizes.md),
            Text(l10n.deliveryNotes, style: text.titleSmall),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              maxLength: 2000,
              decoration: InputDecoration(hintText: l10n.deliveryNotesHint),
              onChanged: controller.setDeliveryNotes,
            ),
            const SizedBox(height: AppSizes.md),
            PurchaseBanner(message: l10n.deliveryFeeAtReview),
            const SizedBox(height: AppSizes.xl),
          ],
        );
      }),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.outOfZone,
    required this.onTap,
  });

  final CheckoutAddress address;
  final bool selected;
  final bool outOfZone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: SectionCard(
        highlighted: selected,
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Radio<int>(value: address.id),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label ?? l10n.addressNumber(address.id),
                    style:
                        text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (address.details != null)
                    Text(address.details!, style: text.bodySmall),
                  Text(
                    outOfZone
                        ? l10n.outsideDeliveryArea
                        : l10n.insideDeliveryArea,
                    style: text.bodySmall?.copyWith(
                      color:
                          outOfZone ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.06),
              child: const Icon(Icons.location_on_outlined,
                  color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
