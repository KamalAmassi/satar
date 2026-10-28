// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Satr';

  @override
  String get appTitle => 'Satr Smart Library';

  @override
  String get errorGeneral => 'An unexpected error occurred. Please try again.';

  @override
  String get errorNetwork =>
      'Network connection error. Please check your connection.';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get loading => 'Loading...';
}
