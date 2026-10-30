import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/errors/failure_messages.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/routes/route_args.dart';
import 'package:project/core/routes/route_nav.dart';
import 'package:project/core/utils/money.dart';
import 'package:project/core/widgets/purchase_widgets.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_details.dart';
import 'package:project/customer/features/checkout/domain/entities/placed_order.dart';
import 'package:project/customer/features/checkout/domain/entities/quote.dart';
import 'package:project/customer/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:project/customer/features/checkout/presentation/widgets/checkout_steps.dart';

/// مراجعة تسعيرة الخادم وتأكيد الطلب، بكل حالاتها (إطارات C3 / Quote و Checkout).
class QuoteReviewView extends StatefulWidget {
  const QuoteReviewView({super.key});

  @override
  State<QuoteReviewView> createState() => _QuoteReviewViewState();
}

class _QuoteReviewViewState extends State<QuoteReviewView> {
  final controller = Get.find<CheckoutController>();

  @override
  void initState() {
    super.initState();
    if (controller.submitState.value != SubmitState.uncertain &&
        !controller.canConfirm) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => controller.requestQuote());
    }
  }

  /// شاشات مسار الشراء التي تُزال بعد إنشاء الطلب.
  static const _purchaseFlow = {
    CustomerRoutes.printing,
    CustomerRoutes.printPreview,
    CustomerRoutes.cart,
    CustomerRoutes.checkout,
    CustomerRoutes.paymentMethod,
    CustomerRoutes.priceReview,
  };

  void _openOrder(PlacedOrder order) {
    controller.resetAfterExit();
    // عقد الدفع → الطلبات: معرّف الطلب المؤكد فقط.
    leaveFlowTo(
      order.isTransfer ? CustomerRoutes.payment : CustomerRoutes.orderDetails,
      _purchaseFlow,
      arguments: RouteArgs.order(order.id),
    );
  }

  void _openOrders() {
    controller.resetAfterExit();
    leaveFlowTo(CustomerRoutes.orders, _purchaseFlow);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Obx حتى يتبع canPop حالة الإرسال. بعد إنشاء الطلب يخرج الرجوع من مسار
    // الشراء كله بدل العودة لصفحات الدفع والتوصيل بسلة فارغة.
    return Obx(() {
      final state = controller.submitState.value;
      return PopScope(
        canPop: state != SubmitState.submitting && state != SubmitState.created,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop || controller.submitState.value != SubmitState.created) {
            return;
          }
          controller.resetAfterExit();
          leaveFlow(_purchaseFlow);
        },
        child: Scaffold(
          backgroundColor: AppColors.cream,
          appBar: PurchaseHeader(
            title: l10n.reviewOrder,
            cartCount: () => controller.cart.itemCount,
          ),
          bottomNavigationBar: Obx(_bottomBar),
          body: Obx(_body),
        ),
      );
    });
  }

  Widget _bottomBar() {
    final l10n = context.l10n;
    final submit = controller.submitState.value;
    final q = controller.quote.value;
    if (submit == SubmitState.created || submit == SubmitState.uncertain) {
      return const SizedBox.shrink();
    }
    if (controller.quoteState.value != QuoteState.ready || q == null) {
      return const SizedBox.shrink();
    }
    final currency =
        controller.remoteConfig.value?.currency ?? const CurrencyFormat();
    if (controller.needsPriceAcceptance.value) {
      // السعر الجديد ظاهر في البطاقة؛ الزر بعرض كامل حتى لا يُقص النص.
      return PurchaseBottomBar(
        actionLabel: l10n.acceptNewPrice,
        onAction: controller.acceptNewPrice,
      );
    }
    return PurchaseBottomBar(
      amountLabel: l10n.total,
      amount: q.total.display(currency),
      actionLabel: l10n.confirmOrder,
      isLoading: submit == SubmitState.submitting,
      onAction: controller.canConfirm ? controller.confirmOrder : null,
    );
  }

  Widget _body() {
    final l10n = context.l10n;
    final submit = controller.submitState.value;

    if (submit == SubmitState.submitting) {
      return PurchaseStateView(
        loading: true,
        title: l10n.submittingTitle,
        body: l10n.submittingBody,
      );
    }
    if (submit == SubmitState.created &&
        controller.createdOrder.value != null) {
      return _created(controller.createdOrder.value!);
    }
    if (submit == SubmitState.uncertain) {
      return PurchaseStateView(
        tone: BannerTone.warning,
        icon: Icons.help_outline,
        title: l10n.uncertainTitle,
        body: l10n.uncertainBody,
        actionLabel: l10n.checkAgain,
        onAction: controller.recheckSubmission,
        secondaryLabel: l10n.checkMyOrders,
        onSecondary: _openOrders,
      );
    }

    switch (controller.quoteState.value) {
      case QuoteState.idle:
      case QuoteState.loading:
        return PurchaseStateView(
          loading: true,
          title: l10n.quoteLoadingTitle,
          body: l10n.quoteLoadingBody,
        );
      case QuoteState.expired:
        return PurchaseStateView(
          tone: BannerTone.warning,
          icon: Icons.timer_off_outlined,
          title: l10n.quoteExpiredTitle,
          body: l10n.quoteExpiredBody,
          actionLabel: l10n.refreshQuote,
          onAction: controller.requestQuote,
        );
      case QuoteState.stale:
        return PurchaseStateView(
          tone: BannerTone.warning,
          icon: Icons.sync_problem_outlined,
          title: l10n.quoteStaleTitle,
          body: l10n.quoteStaleBody,
          actionLabel: l10n.refreshQuote,
          onAction: controller.requestQuote,
        );
      case QuoteState.used:
        return PurchaseStateView(
          tone: BannerTone.warning,
          icon: Icons.receipt_long_outlined,
          title: l10n.quoteUsedTitle,
          body: l10n.quoteUsedBody,
          actionLabel: l10n.viewMyOrders,
          onAction: _openOrders,
        );
      case QuoteState.failed:
        return _failed();
      case QuoteState.ready:
        return _review(controller.quote.value!);
    }
  }

  Widget _failed() {
    final l10n = context.l10n;
    final failure = controller.quoteFailure.value;
    final (_, blockers) = controller.currentDraft();
    final code = failure?.code;
    String? action;
    VoidCallback? onAction = controller.requestQuote;
    String body = failure?.describe(context) ?? l10n.quoteFailedBody;

    if (failure == null && blockers.isNotEmpty) {
      body = l10n.quoteNotReady;
      action = l10n.backToCart;
      onAction = () => backTo(CustomerRoutes.cart);
    } else if (failure is ValidationFailure ||
        code == ApiErrorCodes.outOfStock) {
      action = l10n.backToCart;
      onAction = () => backTo(CustomerRoutes.cart);
    } else if (code == ApiErrorCodes.outOfZone) {
      action = l10n.changeAddress;
      onAction = () => backTo(CustomerRoutes.checkout);
    }
    final rateLimited = code == ApiErrorCodes.tooManyRequests;
    return PurchaseStateView(
      tone: BannerTone.error,
      icon: rateLimited ? Icons.hourglass_empty : Icons.error_outline,
      title: l10n.quoteFailedTitle,
      body: body,
      actionLabel: action ?? l10n.retry,
      onAction: onAction,
      child: failure is ValidationFailure && failure.fieldErrors.isNotEmpty
          ? Text(
              l10n.fixHighlightedItems,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
    );
  }

  Widget _review(Quote q) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final currency =
        controller.remoteConfig.value?.currency ?? const CurrencyFormat();
    final method = controller.details.value.paymentMethod;
    final (draft, _) = controller.currentDraft();
    final previous = controller.previousQuote.value;
    final failure = controller.submitFailure.value;
    final minutes = controller.remaining.value.inMinutes;
    final seconds = controller.remaining.value.inSeconds % 60;
    return ListView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      children: [
        const CheckoutSteps(current: 2),
        const SizedBox(height: AppSizes.lg),
        Text(l10n.reviewBeforeConfirm, style: text.titleLarge),
        const SizedBox(height: AppSizes.md),
        if (controller.needsPriceAcceptance.value && previous != null) ...[
          PurchaseBanner(
            tone: BannerTone.warning,
            icon: Icons.trending_up,
            message: l10n.priceChangedBody,
          ),
          const SizedBox(height: AppSizes.sm),
          SectionCard(
            child: Column(
              children: [
                SummaryRow(
                  label: l10n.previousPrice,
                  value: previous.total.display(currency),
                ),
                SummaryRow(
                  label: l10n.currentPrice,
                  value: q.total.display(currency),
                  emphasized: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
        ],
        if (controller.paymentTermsChanged.value &&
            !controller.needsPriceAcceptance.value) ...[
          PurchaseBanner(
            tone: BannerTone.info,
            icon: Icons.info_outline,
            message: l10n.paymentMethodChangedBody,
          ),
          const SizedBox(height: AppSizes.md),
        ],
        if (failure != null &&
            controller.submitState.value == SubmitState.rejected)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: PurchaseBanner(
              tone: BannerTone.error,
              message: failure.describe(context),
            ),
          ),
        SectionCard(
          tinted: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (draft != null)
                SummaryRow(
                  label: l10n.orderType,
                  value: switch (draft.orderType) {
                    'mixed' => l10n.orderTypeMixed,
                    'printing' => l10n.orderTypePrinting,
                    _ => l10n.orderTypeProducts,
                  },
                ),
              for (final line in q.breakdown)
                SummaryRow(
                  label: line.label,
                  value: line.amount.display(currency),
                ),
              if (q.discount.amount != 0 &&
                  q.breakdown.every((l) => l.key != 'discount'))
                SummaryRow(
                  label: l10n.discount,
                  value: q.discount.display(currency),
                ),
              const Divider(),
              SummaryRow(
                label: l10n.total,
                value: q.total.display(currency),
                emphasized: true,
              ),
              SummaryRow(
                label: l10n.payment,
                value: method == PaymentMethod.transfer
                    ? l10n.payBankTransfer
                    : l10n.payCashOnDelivery,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        PurchaseBanner(
          icon: Icons.timer_outlined,
          message:
              l10n.quoteValidFor(minutes, seconds.toString().padLeft(2, '0')),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          method == PaymentMethod.transfer
              ? l10n.transferAfterOrderNote
              : l10n.libraryConfirmsNote,
          style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSizes.xl),
      ],
    );
  }

  Widget _created(PlacedOrder order) {
    final l10n = context.l10n;
    final currency =
        controller.remoteConfig.value?.currency ?? const CurrencyFormat();
    return PurchaseStateView(
      tone: BannerTone.success,
      icon: Icons.check_circle_outline,
      title: order.isTransfer
          ? l10n.orderAwaitingPaymentTitle
          : l10n.orderCreatedTitle,
      body: order.isTransfer
          ? l10n.orderCreatedTransferBody
          : l10n.orderCreatedBody,
      actionLabel: order.isTransfer ? l10n.viewTransferDetails : l10n.viewOrder,
      onAction: () => _openOrder(order),
      child: SectionCard(
        tinted: true,
        child: Column(
          children: [
            SummaryRow(label: l10n.orderCode, value: isolate(order.code)),
            SummaryRow(label: l10n.total, value: order.total.display(currency)),
            SummaryRow(label: l10n.orderStatus, value: order.statusLabel),
          ],
        ),
      ),
    );
  }
}
