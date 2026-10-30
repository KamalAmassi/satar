import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_messages.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/routes/route_args.dart';
import 'package:project/core/uploads/file_signature.dart';
import 'package:project/core/utils/money.dart';
import 'package:project/core/widgets/purchase_widgets.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/payment/presentation/controllers/transfer_payment_controller.dart';
import 'package:project/customer/features/printing/domain/entities/file_check.dart';

/// الدفع بالتحويل وإرسال الإشعار وتصحيحه (إطارات 19 و 47 و 48 و 42).
class TransferPaymentView extends GetView<TransferPaymentController> {
  const TransferPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: PurchaseHeader(title: l10n.transferTitle),
      bottomNavigationBar: Obx(() {
        final order = controller.order.value;
        if (order == null || !order.canSubmitReceipt) {
          return const SizedBox.shrink();
        }
        return PurchaseBottomBar(
          actionLabel:
              order.needsCorrection ? l10n.resubmitReceipt : l10n.submitReceipt,
          isLoading: controller.submitting.value,
          onAction: controller.canSubmit ? controller.submit : null,
        );
      }),
      body: Obx(() {
        final order = controller.order.value;
        if (order == null) {
          final f = controller.loadFailure.value;
          if (f != null) {
            return PurchaseStateView(
              tone: BannerTone.error,
              icon: Icons.error_outline,
              title: l10n.errorGeneral,
              body: f.describe(context),
              actionLabel: l10n.retry,
              onAction: controller.load,
            );
          }
          return PurchaseStateView(loading: true, title: l10n.loading);
        }
        if (!order.isTransfer) {
          return PurchaseStateView(
            icon: Icons.payments_outlined,
            title: l10n.notTransferOrderTitle,
            body: l10n.notTransferOrderBody,
            actionLabel: l10n.viewOrder,
            onAction: () => Get.offNamed(
              CustomerRoutes.orderDetails,
              arguments: RouteArgs.order(order.id),
            ),
          );
        }
        if (order.canSubmitReceipt) return _awaitingPayment(context, order);
        return _readOnlyState(context, order);
      }),
    );
  }

  Widget _readOnlyState(BuildContext context, PlacedOrder order) {
    final l10n = context.l10n;
    final currency =
        controller.currency.value?.currency ?? const CurrencyFormat();
    final details = SectionCard(
      tinted: true,
      child: Column(
        children: [
          SummaryRow(label: l10n.orderCode, value: isolate(order.code)),
          SummaryRow(
              label: l10n.amountDue, value: order.total.display(currency)),
          SummaryRow(label: l10n.orderStatus, value: order.statusLabel),
        ],
      ),
    );
    if (order.isReceiptUnderReview) {
      return PurchaseStateView(
        tone: BannerTone.info,
        icon: Icons.hourglass_top_outlined,
        title: controller.justSubmitted.value
            ? l10n.receiptSentTitle
            : l10n.receiptUnderReviewTitle,
        body: l10n.receiptUnderReviewBody,
        actionLabel: l10n.refreshStatus,
        onAction: controller.load,
        child: details,
      );
    }
    final beforePayment = order.statusKey == OrderStatusKey.awaitingPricing ||
        order.statusKey == OrderStatusKey.priced ||
        order.statusKey == OrderStatusKey.pending;
    if (beforePayment) {
      final priced = order.statusKey == OrderStatusKey.priced;
      return PurchaseStateView(
        icon: Icons.schedule_outlined,
        title: l10n.transferNotOpenTitle,
        body: priced ? l10n.transferNeedsOfferBody : l10n.transferNotOpenBody,
        actionLabel: priced ? l10n.reviewLibraryOffer : l10n.refreshStatus,
        onAction: priced
            ? () => Get.toNamed(
                  CustomerRoutes.offer,
                  arguments: RouteArgs.order(order.id),
                )
            : controller.load,
        child: details,
      );
    }
    final paid = order.paymentStatus == 'paid';
    return PurchaseStateView(
      tone: paid ? BannerTone.success : BannerTone.info,
      icon: paid ? Icons.verified_outlined : Icons.info_outline,
      title: paid ? l10n.paymentConfirmedTitle : order.statusLabel,
      body: paid ? l10n.paymentConfirmedBody : null,
      actionLabel: l10n.viewOrder,
      onAction: () => Get.offNamed(
        CustomerRoutes.orderDetails,
        arguments: RouteArgs.order(order.id),
      ),
      child: details,
    );
  }

  Widget _awaitingPayment(BuildContext context, PlacedOrder order) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final config = controller.currency.value;
    final transfer = controller.transfer.value;
    final currency = config?.currency ?? const CurrencyFormat();
    return ListView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      children: [
        Text(
          order.needsCorrection ? l10n.correctionTitle : l10n.transferHeadline,
          style: text.titleLarge,
        ),
        Text(
          order.needsCorrection
              ? l10n.correctionSubtitle
              : l10n.transferSubtitle,
          style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.md),
        if (controller.stateChanged.value) ...[
          PurchaseBanner(
            tone: BannerTone.warning,
            message: l10n.paymentStateChanged,
          ),
          const SizedBox(height: AppSizes.md),
        ],
        if (order.needsCorrection) ...[
          SectionCard(
            highlighted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.libraryNote, style: text.titleSmall),
                const SizedBox(height: AppSizes.xs),
                Text(order.reviewNote!, style: text.bodyMedium),
              ],
            ),
          ),
          if (order.receipt != null) ...[
            const SizedBox(height: AppSizes.sm),
            SectionCard(
              child: Row(
                children: [
                  const Icon(Icons.attachment_outlined),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(child: Text(l10n.previousReceipt)),
                  if (order.receipt!.url != null)
                    IconButton(
                      tooltip: l10n.copyLink,
                      icon: const Icon(Icons.link),
                      onPressed: () => _copy(context, order.receipt!.url!),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.md),
        ],
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SummaryRow(
                label: l10n.amountDue,
                value: order.total.display(currency),
                emphasized: true,
              ),
              SummaryRow(label: l10n.orderCode, value: isolate(order.code)),
              const Divider(),
              Text(l10n.recipientAccount, style: text.titleSmall),
              const SizedBox(height: AppSizes.sm),
              if (transfer == null || transfer.accounts.isEmpty)
                Text(l10n.noTransferAccounts, style: text.bodySmall)
              else
                for (final a in transfer.accounts) _AccountTile(account: a),
              if (transfer?.instructions != null) ...[
                const SizedBox(height: AppSizes.sm),
                Text(
                  transfer!.instructions!,
                  style:
                      text.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _ReceiptPicker(controller: controller, transfer: transfer),
        const SizedBox(height: AppSizes.md),
        Text(
          l10n.receiptNotApproval,
          style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.xl),
      ],
    );
  }

  static void _copy(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.copied)),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account});

  final TransferAccount account;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: SectionCard(
        tinted: true,
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${account.kind == 'wallet' ? l10n.wallet : l10n.bank} · ${account.provider}',
              style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            Text(account.holder, style: text.titleSmall),
            Row(
              children: [
                Expanded(
                  child: LtrText(
                    account.number,
                    style:
                        text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      TransferPaymentView._copy(context, account.number),
                  icon: const Icon(Icons.copy, size: AppSizes.iconSm),
                  label: Text(l10n.copy),
                ),
              ],
            ),
            if (account.iban != null)
              Row(
                children: [
                  Expanded(child: LtrText('IBAN ${account.iban}', maxLines: 2)),
                  IconButton(
                    tooltip: l10n.copy,
                    onPressed: () =>
                        TransferPaymentView._copy(context, account.iban!),
                    icon: const Icon(Icons.copy, size: AppSizes.iconSm),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptPicker extends StatelessWidget {
  const _ReceiptPicker({required this.controller, required this.transfer});

  final TransferPaymentController controller;
  final TransferConfig? transfer;

  // Obx هنا لأن الحالة تُقرأ داخل هذه البطاقة لا داخل Obx الشاشة.
  @override
  Widget build(BuildContext context) => Obx(() => _card(context));

  Widget _card(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final selected = controller.receipt.value;
    final rejection = controller.rejection.value;
    final failure = controller.submitFailure.value;
    final maxBytes = transfer?.receiptMaxBytes ?? 10 * 1024 * 1024;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.uploadReceipt, style: text.titleSmall),
          Text(
            l10n.receiptTypes(formatBytes(maxBytes)),
            style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.md),
          if (selected == null)
            OutlinedButton.icon(
              onPressed:
                  controller.submitting.value ? null : controller.pickReceipt,
              icon: const Icon(Icons.upload_outlined),
              label: Text(l10n.chooseReceipt),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: FileSignature.isImage(selected.mime)
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: Image.memory(
                        selected.bytes,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        semanticLabel: l10n.receiptPreview,
                        errorBuilder: (_, __, ___) => const SizedBox(
                          height: 96,
                          child: Center(
                            child: Icon(Icons.image_not_supported_outlined,
                                size: 40),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: 96,
                      color: AppColors.primary.withValues(alpha: 0.05),
                      child: const Center(
                        child: Icon(Icons.picture_as_pdf_outlined, size: 40),
                      ),
                    ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              '${isolate(selected.name)} · ${formatBytes(selected.size)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.bodySmall,
            ),
            if (controller.submitting.value)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.sm),
                child: LinearProgressIndicator(
                  value: controller.uploadProgress.value > 0
                      ? controller.uploadProgress.value
                      : null,
                ),
              )
            else
              Wrap(
                spacing: AppSizes.sm,
                children: [
                  TextButton(
                    onPressed: controller.pickReceipt,
                    child: Text(l10n.replaceReceipt),
                  ),
                  TextButton(
                    onPressed: controller.removeReceipt,
                    style:
                        TextButton.styleFrom(foregroundColor: AppColors.error),
                    child: Text(l10n.remove),
                  ),
                ],
              ),
          ],
          if (rejection != null) ...[
            const SizedBox(height: AppSizes.sm),
            PurchaseBanner(
              tone: BannerTone.error,
              message: rejection == FileRejection.tooLarge
                  ? l10n.uploadTooLargeBody(formatBytes(maxBytes))
                  : l10n.uploadUnsupportedBody,
            ),
          ],
          if (failure != null) ...[
            const SizedBox(height: AppSizes.sm),
            PurchaseBanner(
              tone: BannerTone.error,
              message: failure.describe(context),
            ),
          ],
        ],
      ),
    );
  }
}
