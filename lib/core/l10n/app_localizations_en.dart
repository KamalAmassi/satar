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

  @override
  String get errorTimeout => 'The connection timed out. Please try again.';

  @override
  String get errorSessionExpired =>
      'Your session has ended. Please sign in again.';

  @override
  String get errorRateLimited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String errorRateLimitedSeconds(int seconds) {
    return 'Too many requests. Try again in $seconds seconds.';
  }

  @override
  String get errorAppNotConfigured =>
      'The app is not configured to reach the server right now.';

  @override
  String get errorOutOfZone =>
      'This address is outside the delivery area. Choose another address.';

  @override
  String get errorOutOfStock =>
      'The requested quantity is not available right now.';

  @override
  String errorOutOfStockAvailable(int count) {
    return 'Not enough stock. Available now: $count.';
  }

  @override
  String get errorStateChanged =>
      'The order status changed. We refreshed it — please review and continue.';

  @override
  String get remove => 'Remove';

  @override
  String get reject => 'Reject';

  @override
  String get quoteExpiredBody =>
      'Refresh the price and availability before confirming.';

  @override
  String get quoteUsedBody =>
      'Check your orders before trying to place a new one.';
}
