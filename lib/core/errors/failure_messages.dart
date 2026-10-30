import 'package:flutter/widgets.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/extensions/context_extensions.dart';

/// نص مفهوم للزبون. لا يعرض رموز الـ API أو تفاصيل تقنية.
extension FailureMessage on Failure {
  String describe(BuildContext context) {
    final l10n = context.l10n;
    final f = this;
    if (f is NetworkFailure) return l10n.errorNetwork;
    if (f is TimeoutFailure) return l10n.errorTimeout;
    if (f is UnauthorizedFailure) return l10n.errorSessionExpired;
    if (f is ServerFailure && f.code == ApiErrorCodes.tooManyRequests) {
      final s = f.retryAfterSeconds;
      return s == null
          ? l10n.errorRateLimited
          : l10n.errorRateLimitedSeconds(s);
    }
    switch (code) {
      case ApiErrorCodes.missingProjectKey:
      case ApiErrorCodes.invalidProjectKey:
        return l10n.errorAppNotConfigured;
      case ApiErrorCodes.outOfZone:
        return l10n.errorOutOfZone;
      case ApiErrorCodes.outOfStock:
        final available = details?['available'];
        return available is int
            ? l10n.errorOutOfStockAvailable(available)
            : l10n.errorOutOfStock;
      case ApiErrorCodes.quoteExpired:
        return l10n.quoteExpiredBody;
      case ApiErrorCodes.quoteUsed:
        return l10n.quoteUsedBody;
      case ApiErrorCodes.invalidTransition:
        return l10n.errorStateChanged;
    }
    final server = message;
    if (server != null && server.trim().isNotEmpty) return server;
    return l10n.errorGeneral;
  }
}
