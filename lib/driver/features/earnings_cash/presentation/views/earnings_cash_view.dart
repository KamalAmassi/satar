import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_message.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/utils/view_status.dart';
import 'package:project/core/widgets/app_card.dart';
import 'package:project/core/widgets/app_skeleton.dart';
import 'package:project/core/widgets/app_state_view.dart';
import 'package:project/driver/features/earnings_cash/presentation/controllers/earnings_cash_controller.dart';
import 'package:project/driver/features/earnings_cash/presentation/widgets/ledger_list.dart';
import 'package:project/driver/shared/domain/order_extensions.dart';
import 'package:project/driver/shared/presentation/widgets/driver_app_bar.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

class DriverEarningsCashView extends GetView<DriverEarningsCashController> {
  const DriverEarningsCashView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: DriverUi.bg,
      appBar: driverAppBar(l10n.drEarningsTitle),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Obx(
                  () => SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: 0, label: Text(l10n.drEarningsTab)),
                    ButtonSegment(value: 1, label: Text(l10n.drCashTab)),
                  ],
                  selected: {controller.tab.value},
                  onSelectionChanged: (s) => controller.tab.value = s.first,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
                  () => controller.tab.value == 0
                  ? _EarningsTab(controller: controller, l10n: l10n)
                  : _CashTab(controller: controller, l10n: l10n),
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningsTab extends StatelessWidget {
  const _EarningsTab({required this.controller, required this.l10n});

  final DriverEarningsCashController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    switch (controller.earningsStatus.value) {
      case ViewStatus.loading:
        return const AppSkeletonList(count: 4, itemHeight: 64);
      case ViewStatus.error:
        return AppStateView(
          icon: Icons.error_outline_rounded,
          tone: AppStateTone.error,
          title: l10n.drEarningsErrorTitle,
          message: controller.earningsFailure.value == null
              ? null
              : failureMessage(l10n, controller.earningsFailure.value!),
          primaryLabel: l10n.retry,
          onPrimary: controller.loadEarnings,
        );
      case ViewStatus.empty:
        return AppStateView(
          icon: Icons.payments_outlined,
          title: l10n.drEarningsEmptyTitle,
          message: l10n.drEarningsEmptyBody,
        );
      case ViewStatus.success:
        final e = controller.earnings.value!;
        return RefreshIndicator(
          onRefresh: () => controller.loadEarnings(silent: true),
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            children: [
              AppCard(
                color: AppColors.primary,
                borderColor: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.drEarningsThisWeek,
                      style: t.labelLarge?.copyWith(color: AppColors.sand.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.earnings.display,
                      style: t.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      '${e.orders} ${l10n.drOrdersUnit}  •  ${l10n.drCashCollected}: ${e.cashCollected.display}',
                      style: t.bodySmall?.copyWith(color: AppColors.sand.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              LedgerList(
                entries: [
                  for (final s in e.series)
                    LedgerEntry(
                      title: s.date,
                      subtitle: '${s.orders} ${l10n.drOrdersUnit}',
                      amount: s.earnings.display,
                    ),
                ],
              ),
            ],
          ),
        );
    }
  }
}

class _CashTab extends StatelessWidget {
  const _CashTab({required this.controller, required this.l10n});

  final DriverEarningsCashController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    switch (controller.cashStatus.value) {
      case ViewStatus.loading:
        return const AppSkeletonList(count: 3, itemHeight: 80);
      case ViewStatus.error:
        return AppStateView(
          icon: Icons.error_outline_rounded,
          tone: AppStateTone.error,
          title: l10n.drCashErrorTitle,
          message: controller.cashFailure.value == null
              ? null
              : failureMessage(l10n, controller.cashFailure.value!),
          primaryLabel: l10n.retry,
          onPrimary: controller.loadCash,
        );
      case ViewStatus.empty:
      case ViewStatus.success:
        final c = controller.cash.value!;
        final nearLimit = c.maxCash.amount > 0 && c.cashOnHand.amount / c.maxCash.amount >= 0.8;
        return RefreshIndicator(
          onRefresh: () => controller.loadCash(silent: true),
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            children: [
              AppCard(
                color: AppColors.sand.withValues(alpha: 0.5),
                borderColor: AppColors.secondary.withValues(alpha: 0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.drCashOnHand,
                        style: t.labelLarge?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      c.cashOnHand.display,
                      style: t.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${l10n.drCashLimit}: ${c.maxCash.display}', style: t.bodySmall),
                    if (c.remaining != null)
                      Text('${l10n.drCashRemaining}: ${c.remaining!.display}', style: t.bodySmall),
                    Text('${l10n.drCashUnsettled}: ${c.unsettledOrders}', style: t.bodySmall),
                  ],
                ),
              ),
              if (nearLimit) ...[
                const SizedBox(height: AppSizes.md),
                AppCard(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderColor: AppColors.warning.withValues(alpha: 0.4),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                      const SizedBox(width: AppSizes.md),
                      Expanded(child: Text(l10n.drCashNearLimit)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.lg),
              if (c.settlements.isEmpty)
                Text(
                  l10n.drCashEmptyTitle,
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
                )
              else
                LedgerList(
                  entries: [
                    for (final s in c.settlements)
                      LedgerEntry(
                        title: s.note ?? l10n.drCashSettlement,
                        subtitle:
                        '${s.at.year}-${s.at.month.toString().padLeft(2, '0')}-${s.at.day.toString().padLeft(2, '0')}',
                        amount: s.amount.display,
                      ),
                  ],
                ),
            ],
          ),
        );
    }
  }
}
