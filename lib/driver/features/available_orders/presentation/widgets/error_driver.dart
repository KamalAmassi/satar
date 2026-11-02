import 'package:flutter/material.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';

/// D10: تعذّر تحميل الطلبات + زر إعادة المحاولة.
class DriverFetchError extends StatelessWidget {
  const DriverFetchError({super.key, required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(DriverUi.pagePadding + 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: DriverUi.dangerBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.failLoadOrders,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message ?? l10n.failLoadOrdersDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: DriverUi.muted, height: 1.5),
          ),
          const SizedBox(height: 20),
          AppButton(label: l10n.retry, onPressed: onRetry),
        ],
      ),
    );
  }
}
