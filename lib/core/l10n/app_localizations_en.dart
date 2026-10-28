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

  @override
  String get splashTagline => 'Everything you need, in one line';

  @override
  String get splashContinue => 'Continue';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Let’s start';

  @override
  String onboardingPageCounter(int current, int total) {
    return '$current of $total';
  }

  @override
  String get onboarding1Title => 'Everything you need, in one line';

  @override
  String get onboarding1Body =>
      'Books, stationery, toys and gifts… all in one place.';

  @override
  String get onboarding2Title => 'Your files, ready to print';

  @override
  String get onboarding2Body =>
      'Upload your file, pick the print options, and we prepare your order.';

  @override
  String get onboarding3Title => 'Order easily, we handle the rest';

  @override
  String get onboarding3Body =>
      'Type or speak your request, and Satr builds your cart and delivers it.';

  @override
  String get roleWelcomeTitle => 'Welcome to Satr!';

  @override
  String get roleWelcomeSubtitle => 'Choose how you want to continue';

  @override
  String get roleCustomer => 'I’m a customer';

  @override
  String get roleDriver => 'I’m a driver';

  @override
  String get roleTermsNote =>
      'By continuing you agree to the Terms of Use and Privacy Policy';
}
