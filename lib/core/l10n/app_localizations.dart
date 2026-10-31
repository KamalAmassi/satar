import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'سطر'**
  String get appName;

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكتبة سطر الذكية'**
  String get appTitle;

  /// No description provided for @errorGeneral.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'**
  String get errorGeneral;

  /// No description provided for @errorNetwork.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال بالشبكة. يرجى التحقق من اتصالك.'**
  String get errorNetwork;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @splashTagline.
  ///
  /// In ar, this message translates to:
  /// **'كل احتياجاتك، بسطر واحد'**
  String get splashTagline;

  /// No description provided for @splashContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get splashContinue;

  /// No description provided for @onboardingSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In ar, this message translates to:
  /// **'يلا نبدأ'**
  String get onboardingStart;

  /// No description provided for @onboardingPageCounter.
  ///
  /// In ar, this message translates to:
  /// **'{current} من {total}'**
  String onboardingPageCounter(int current, int total);

  /// No description provided for @onboarding1Title.
  ///
  /// In ar, this message translates to:
  /// **'كل اللي بتحتاجه، بسطر واحد'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In ar, this message translates to:
  /// **'كتب، قرطاسية، ألعاب وهدايا… كل إشي بتحتاجه بمكان واحد.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In ar, this message translates to:
  /// **'ملفاتك جاهزة للطباعة'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In ar, this message translates to:
  /// **'ارفع ملفك، اختر مواصفات الطباعة، وإحنا بنجهّزلك طلبك.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In ar, this message translates to:
  /// **'اطلبها بسهولة، وخلي الباقي علينا'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In ar, this message translates to:
  /// **'اطلب بالكتابة أو بالصوت، وسطر بيجهزلك السلة ويوصلها لبابك.'**
  String get onboarding3Body;

  /// No description provided for @roleWelcomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً فيك بسطر!'**
  String get roleWelcomeTitle;

  /// No description provided for @roleWelcomeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر كيف بدك تكمل'**
  String get roleWelcomeSubtitle;

  /// No description provided for @roleCustomer.
  ///
  /// In ar, this message translates to:
  /// **'أنا زبون'**
  String get roleCustomer;

  /// No description provided for @roleDriver.
  ///
  /// In ar, this message translates to:
  /// **'أنا سائق'**
  String get roleDriver;

  /// No description provided for @roleTermsNote.
  ///
  /// In ar, this message translates to:
  /// **'بالمتابعة أنت توافق على شروط الاستخدام وسياسة الخصوصية'**
  String get roleTermsNote;

  /// No description provided for @aiAlternatives.
  ///
  /// In ar, this message translates to:
  /// **'بدائل مقترحة'**
  String get aiAlternatives;

  /// No description provided for @aiStepListening.
  ///
  /// In ar, this message translates to:
  /// **'عم بسمعك…'**
  String get aiStepListening;

  /// No description provided for @aiStepUnderstanding.
  ///
  /// In ar, this message translates to:
  /// **'عم بفهم طلبك…'**
  String get aiStepUnderstanding;

  /// No description provided for @aiStepSearching.
  ///
  /// In ar, this message translates to:
  /// **'عم بدور على المنتجات…'**
  String get aiStepSearching;

  /// No description provided for @aiStop.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get aiStop;

  /// No description provided for @aiCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get aiCancel;

  /// No description provided for @aiTooShort.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل قصير، جرب مرة ثانية'**
  String get aiTooShort;

  /// No description provided for @aiMicError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر بدء التسجيل'**
  String get aiMicError;

  /// No description provided for @aiMicPermission.
  ///
  /// In ar, this message translates to:
  /// **'لازم تسمح للتطبيق باستخدام المايك'**
  String get aiMicPermission;

  /// No description provided for @aiOpenSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get aiOpenSettings;

  /// No description provided for @aiNotUnderstood.
  ///
  /// In ar, this message translates to:
  /// **'ما فهمت طلبك، جرب مرة ثانية أو اكتبه'**
  String get aiNotUnderstood;

  /// No description provided for @aiQuota.
  ///
  /// In ar, this message translates to:
  /// **'وصلنا لحد الاستخدام مؤقتاً، جرب بعد شوي أو اكتب طلبك'**
  String get aiQuota;

  /// No description provided for @aiServiceUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'المساعد مش متاح هلأ، جرب بعد شوي'**
  String get aiServiceUnavailable;

  /// No description provided for @aiRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get aiRetry;

  /// No description provided for @aiClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get aiClose;

  /// No description provided for @aiUnderstood.
  ///
  /// In ar, this message translates to:
  /// **'ما فهمته'**
  String get aiUnderstood;

  /// No description provided for @aiEditRequest.
  ///
  /// In ar, this message translates to:
  /// **'عدّل الطلب'**
  String get aiEditRequest;

  /// No description provided for @aiItemsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} منتجات'**
  String aiItemsCount(int count);

  /// No description provided for @aiAvailable.
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get aiAvailable;

  /// No description provided for @aiOpenPrinting.
  ///
  /// In ar, this message translates to:
  /// **'افتح الطباعة'**
  String get aiOpenPrinting;

  /// No description provided for @aiFinalPricesNote.
  ///
  /// In ar, this message translates to:
  /// **'الأسعار النهائية تظهر عند مراجعة الطلب'**
  String get aiFinalPricesNote;

  /// No description provided for @aiTitle.
  ///
  /// In ar, this message translates to:
  /// **'مساعد سطر'**
  String get aiTitle;

  /// No description provided for @aiHeroTitle.
  ///
  /// In ar, this message translates to:
  /// **'احكيلي شو بدك'**
  String get aiHeroTitle;

  /// No description provided for @aiHeroSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتب طلبك أو احكيلنا بصوتك، وأنا برتّبلك اقتراح قبل ما تضيفه للسلة.'**
  String get aiHeroSubtitle;

  /// No description provided for @aiInputHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: بدي دفترين أزرق وثلاث أقلام سوداء وطباعة A4'**
  String get aiInputHint;

  /// No description provided for @aiVoiceStart.
  ///
  /// In ar, this message translates to:
  /// **'اضغط واحكي طلبك'**
  String get aiVoiceStart;

  /// No description provided for @aiVoiceListening.
  ///
  /// In ar, this message translates to:
  /// **'عم بسمعك… اضغط للإيقاف'**
  String get aiVoiceListening;

  /// No description provided for @aiPrepare.
  ///
  /// In ar, this message translates to:
  /// **'جهّز اقتراح'**
  String get aiPrepare;

  /// No description provided for @aiEmptyInput.
  ///
  /// In ar, this message translates to:
  /// **'اكتب طلبك أو احكيه أول'**
  String get aiEmptyInput;

  /// No description provided for @aiNothingFound.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرت أفهم طلبك، جرب تكتبه بشكل ثاني'**
  String get aiNothingFound;

  /// No description provided for @aiSpeechUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'التعرف على الصوت مش متاح، تأكد من إذن المايك أو اكتب طلبك'**
  String get aiSpeechUnavailable;

  /// No description provided for @aiSheetTitle.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحي إلك'**
  String get aiSheetTitle;

  /// No description provided for @aiSheetSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عدّل الكميات وبعدين أضفهم للسلة'**
  String get aiSheetSubtitle;

  /// No description provided for @aiAddToCart.
  ///
  /// In ar, this message translates to:
  /// **'أضف للسلة ({count})'**
  String aiAddToCart(int count);

  /// No description provided for @aiUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر'**
  String get aiUnavailable;

  /// No description provided for @aiLimitedStock.
  ///
  /// In ar, this message translates to:
  /// **'المتوفر {available} فقط من {requested}'**
  String aiLimitedStock(int available, int requested);

  /// No description provided for @aiUseAlternative.
  ///
  /// In ar, this message translates to:
  /// **'استبدل'**
  String get aiUseAlternative;

  /// No description provided for @aiNotFound.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا «{query}»'**
  String aiNotFound(String query);

  /// No description provided for @aiNotFoundHint.
  ///
  /// In ar, this message translates to:
  /// **'جرب تكتبه بشكل ثاني أو تصفح الأقسام'**
  String get aiNotFoundHint;

  /// No description provided for @aiAddedToCart.
  ///
  /// In ar, this message translates to:
  /// **'انضافت {count} منتجات للسلة'**
  String aiAddedToCart(int count);

  /// No description provided for @errorNoConnection.
  ///
  /// In ar, this message translates to:
  /// **'ما في اتصال بالإنترنت'**
  String get errorNoConnection;

  /// No description provided for @errorTimeout.
  ///
  /// In ar, this message translates to:
  /// **'الاتصال بطيء، جرب مرة ثانية'**
  String get errorTimeout;

  /// No description provided for @errorUnknown.
  ///
  /// In ar, this message translates to:
  /// **'صار خطأ غير متوقع'**
  String get errorUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
