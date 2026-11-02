import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/driver/features/home/presentation/controllers/driver_session_controller.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// حالة "غير متصل" (D04): بطاقة داكنة + ملخص اليوم + رسالة إخفاء الطلبات.
class DriverOffline extends StatelessWidget {
  final VoidCallback onConnectPressed;
  final bool isConnecting;
  final Widget? summary;

  const DriverOffline({
    super.key,
    required this.onConnectPressed,
    this.isConnecting = false,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(DriverUi.pagePadding),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA49B9F),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.notConnectedStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.connectDesc,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: l10n.connectNow,
                variant: AppButtonVariant.light,
                isLoading: isConnecting,
                onPressed: onConnectPressed,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        summary ?? const DriverTodaySummary(),
        const SizedBox(height: 48),
        const Icon(Icons.location_off_outlined, size: 40, color: DriverUi.muted),
        const SizedBox(height: 12),
        Text(
          l10n.hiddenOrdersTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.hiddenOrdersDesc,
          textAlign: TextAlign.center,
          style: const TextStyle(color: DriverUi.muted, fontSize: 13),
        ),
      ],
    );
  }
}

/// ملخص اليوم: طلبات مكتملة + مهمة نشطة (يقرأ من الجلسة، "—" لو غير متاح).
class DriverTodaySummary extends StatelessWidget {
  const DriverTodaySummary({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = Get.find<DriverSessionController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.todaySummary,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _box(session.completedToday.value?.toString() ?? '—', l10n.completedOrders),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _box(session.hasActiveTask.value ? '1' : '—', l10n.activeTask),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _box(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DriverUi.border),
        color: DriverUi.card,
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: DriverUi.muted)),
        ],
      ),
    );
  }
}
