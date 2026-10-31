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
  String get aiAlternatives => 'Close alternatives at a similar price';

  @override
  String get aiStepListening => 'Listening…';

  @override
  String get aiStepUnderstanding => 'Understanding your request…';

  @override
  String get aiStepSearching => 'Searching for products…';

  @override
  String get aiStop => 'Stop';

  @override
  String get aiCancel => 'Cancel';

  @override
  String get aiTooShort => 'The recording is too short, try again';

  @override
  String get aiMicError => 'Could not start recording';

  @override
  String get aiMicPermission => 'Please allow the app to use the microphone';

  @override
  String get aiOpenSettings => 'Settings';

  @override
  String get aiNotUnderstood =>
      'I did not understand your request, try again or type it';

  @override
  String get aiQuota =>
      'Usage limit reached for now, try again shortly or type your request';

  @override
  String get aiServiceUnavailable =>
      'The assistant is unavailable right now, try again shortly';

  @override
  String get aiRetry => 'Try again';

  @override
  String get aiClose => 'Close';

  @override
  String get aiUnderstood => 'What I understood';

  @override
  String get aiEditRequest => 'Edit request';

  @override
  String aiItemsCount(int count) {
    return '$count items';
  }

  @override
  String get aiAvailable => 'In stock';

  @override
  String get aiOpenPrinting => 'Open printing';

  @override
  String get aiFinalPricesNote =>
      'Final prices appear when you review the order';

  @override
  String get aiTitle => 'Satr Assistant';

  @override
  String get aiHeroTitle => 'Tell me what you need';

  @override
  String get aiHeroSubtitle =>
      'Type or say your order, and I will prepare a suggestion before adding anything to your cart.';

  @override
  String get aiInputHint =>
      'e.g. two blue notebooks, three black pens and A4 printing';

  @override
  String get aiVoiceStart => 'Tap and say your order';

  @override
  String get aiVoiceListening => 'Listening… tap to stop';

  @override
  String get aiPrepare => 'Prepare suggestion';

  @override
  String get aiEmptyInput => 'Type or say your order first';

  @override
  String get aiNothingFound =>
      'I could not understand your request, try rephrasing it';

  @override
  String get aiSpeechUnavailable =>
      'Voice recognition is unavailable. Check microphone permission or type your order';

  @override
  String get aiSheetTitle => 'My suggestion';

  @override
  String get aiSheetSubtitle => 'Adjust quantities, then add them to your cart';

  @override
  String aiAddToCart(int count) {
    return 'Add to cart ($count)';
  }

  @override
  String get aiUnavailable => 'Unavailable';

  @override
  String aiLimitedStock(int available, int requested) {
    return 'Only $available available out of $requested';
  }

  @override
  String get aiUseAlternative => 'Replace';

  @override
  String aiNotFound(String query) {
    return 'No match for “$query”';
  }

  @override
  String get aiNotFoundHint => 'Try rephrasing it or browse the categories';

  @override
  String aiAddedToCart(int count) {
    return '$count items added to your cart';
  }

  @override
  String get errorNoConnection => 'No internet connection';

  @override
  String get errorTimeout => 'The connection is slow, please try again';

  @override
  String get errorUnknown => 'Something went wrong';
}
