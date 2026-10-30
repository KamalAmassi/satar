import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_messages.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/routes/route_args.dart';
import 'package:project/core/utils/money.dart';
import 'package:project/core/widgets/purchase_widgets.dart';
import 'package:project/customer/features/library_offer/domain/entities/library_offer.dart';
import 'package:project/customer/features/library_offer/presentation/controllers/offer_controller.dart';

/// عرض المكتبة: البنود والبدائل والموافقة أو الرفض (إطارات 23 و 45 و C3).
class OfferView extends GetView<OfferController> {
  const OfferView({super.key});

  CurrencyFormat get _currency =>
      Get.find<RemoteConfigRepository>().current?.currency ??
      const CurrencyFormat();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: PurchaseHeader(title: l10n.libraryOfferTitle),
      bottomNavigationBar: Obx(() {
        if (controller.viewState.value != OfferViewState.open) {
          return const SizedBox.shrink();
        }
        return PurchaseBottomBar(
          actionLabel: l10n.approvePrice,
          isLoading: controller.acting.value,
          onAction: controller.canApprove ? controller.approve : null,
          secondary: TextButton(
            onPressed:
                controller.acting.value ? null : () => _confirmReject(context),
            child: Text(l10n.reject),
          ),
        );
      }),
      body: Obx(() {
        final o = controller.offer.value;
        switch (controller.viewState.value) {
          case OfferViewState.loading:
            return PurchaseStateView(loading: true, title: l10n.loading);
          case OfferViewState.notReady:
            return PurchaseStateView(
              icon: Icons.hourglass_top_outlined,
              title: l10n.offerNotReadyTitle,
              body: l10n.offerNotReadyBody,
              actionLabel: l10n.refreshOffer,
              onAction: controller.load,
            );
          case OfferViewState.failed:
            return PurchaseStateView(
              tone: BannerTone.error,
              icon: Icons.error_outline,
              title: l10n.errorGeneral,
              body: controller.failure.value?.describe(context),
              actionLabel: l10n.retry,
              onAction: controller.load,
            );
          case OfferViewState.expired:
            return PurchaseStateView(
              tone: BannerTone.warning,
              icon: Icons.timer_off_outlined,
              title: l10n.offerExpiredTitle,
              body: l10n.offerExpiredBody,
              actionLabel: l10n.refreshOffer,
              onAction: controller.load,
            );
          case OfferViewState.changed:
            return PurchaseStateView(
              tone: BannerTone.warning,
              icon: Icons.sync_outlined,
              title: l10n.offerChangedTitle,
              body: l10n.offerChangedBody,
              actionLabel: l10n.refreshOffer,
              onAction: controller.load,
            );
          case OfferViewState.approved:
            return PurchaseStateView(
              tone: BannerTone.success,
              icon: Icons.check_circle_outline,
              title: l10n.offerApprovedTitle,
              body: l10n.offerApprovedBody,
              actionLabel: l10n.viewOrder,
              onAction: () => Get.offNamed(
                CustomerRoutes.orderDetails,
                arguments: RouteArgs.order(controller.orderId),
              ),
            );
          case OfferViewState.rejected:
            return PurchaseStateView(
              icon: Icons.cancel_outlined,
              title: l10n.offerRejectedTitle,
              body: l10n.offerRejectedBody,
              actionLabel: l10n.viewOrder,
              onAction: () => Get.offNamed(
                CustomerRoutes.orderDetails,
                arguments: RouteArgs.order(controller.orderId),
              ),
            );
          case OfferViewState.open:
            return _open(context, o!);
        }
      }),
    );
  }

  Widget _open(BuildContext context, LibraryOffer o) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final currency = _currency;
    final left = controller.remaining.value;
    final h = left.inHours.toString().padLeft(2, '0');
    final m = (left.inMinutes % 60).toString().padLeft(2, '0');
    final s = (left.inSeconds % 60).toString().padLeft(2, '0');
    final failure = controller.failure.value;
    return ListView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      children: [
        if (o.expiresAt != null)
          PurchaseBanner(
            tone: BannerTone.warning,
            icon: Icons.timer_outlined,
            message: l10n.offerValidFor('$h:$m:$s'),
          ),
        const SizedBox(height: AppSizes.lg),
        Text(l10n.reviewPriceAndSubstitutes, style: text.titleLarge),
        Text(
          o.note?.trim().isNotEmpty == true ? o.note! : l10n.offerIntro,
          style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.md),
        if (failure != null) ...[
          PurchaseBanner(
              tone: BannerTone.error, message: failure.describe(context)),
          const SizedBox(height: AppSizes.md),
        ],
        SectionCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg - 1),
            child: Column(
              children: [
                for (final (i, item) in o.items.indexed) ...[
                  if (i > 0) const Divider(height: 1),
                  _OfferItemTile(item: item, currency: currency),
                ],
              ],
            ),
          ),
        ),
        if (o.hasSubstitutions) ...[
          const SizedBox(height: AppSizes.sm),
          CheckboxListTile(
            value: controller.substitutionsAccepted.value,
            onChanged: (v) =>
                controller.substitutionsAccepted.value = v ?? false,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.acceptSubstitutes),
          ),
        ],
        const SizedBox(height: AppSizes.md),
        SectionCard(
          tinted: true,
          child: Column(
            children: [
              SummaryRow(
                label: l10n.productsAndPrinting,
                value: o.itemsTotal.display(currency),
              ),
              SummaryRow(
                  label: l10n.deliveryFee,
                  value: o.deliveryFee.display(currency)),
              const Divider(),
              SummaryRow(
                label: l10n.total,
                value: o.total.display(currency),
                emphasized: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.xl),
      ],
    );
  }

  Future<void> _confirmReject(BuildContext context) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rejectOfferTitle),
        content: Text(l10n.rejectOfferBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.reject),
          ),
        ],
      ),
    );
    if (ok == true) await controller.reject();
  }
}

class _OfferItemTile extends StatelessWidget {
  const _OfferItemTile({required this.item, required this.currency});

  final LibraryOfferItem item;
  final CurrencyFormat currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final diff = item.substituteDifference;
    return Container(
      color: item.available ? null : AppColors.primary.withValues(alpha: 0.04),
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.available ? item.name : l10n.itemUnavailable(item.name),
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                item.lineTotal.display(currency),
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Text(
            l10n.qtyTimesUnit(item.qty, item.unitPrice.display(currency)),
            style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          if (item.substitute != null) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              l10n.suggestedSubstitute(item.substitute!.name),
              style: text.bodySmall,
            ),
            Text(
              diff == null || diff.amount == 0
                  ? l10n.samePrice
                  : diff.amount > 0
                      ? l10n.priceHigherBy(diff.display(currency))
                      : l10n.priceLowerBy(
                          Money(amount: -diff.amount).display(currency)),
              style: text.bodySmall?.copyWith(
                color: (diff?.amount ?? 0) > 0
                    ? const Color(0xFF8A5A00)
                    : AppColors.textSecondary,
              ),
            ),
          ],
          if (item.note?.trim().isNotEmpty == true)
            Text(item.note!, style: text.bodySmall),
        ],
      ),
    );
  }
}
