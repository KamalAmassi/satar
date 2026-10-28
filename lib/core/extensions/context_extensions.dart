import 'package:flutter/widgets.dart';
import 'package:project/core/l10n/app_localizations.dart';

extension ContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}