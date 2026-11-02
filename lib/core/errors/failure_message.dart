import 'package:project/core/errors/failure.dart';
import 'package:project/core/l10n/app_localizations.dart';

/// رسالة جاهزة للعرض من أي Failure.
String failureMessage(AppLocalizations l10n, Failure failure) {
  if (failure is NetworkFailure || failure is TimeoutFailure) {
    return l10n.errorNetwork;
  }
  final message = failure.message;
  if (message != null && message.trim().isNotEmpty) return message;
  return l10n.errorGeneral;
}
