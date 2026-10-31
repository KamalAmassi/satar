import 'package:project/core/errors/failure.dart';
import 'package:project/core/l10n/app_localizations.dart';

extension FailureX on Failure {
  /// رسالة السيرفر إن وجدت، وإلا نص محلي حسب نوع الفشل.
  String localized(AppLocalizations l10n) {
    final text = message;
    if (text != null && text.isNotEmpty) return text;
    if (this is NetworkFailure) return l10n.errorNoConnection;
    if (this is TimeoutFailure) return l10n.errorTimeout;
    return l10n.errorUnknown;
  }
}