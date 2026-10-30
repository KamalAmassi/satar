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

  /// No description provided for @errorTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الاتصال. حاول مرة أخرى.'**
  String get errorTimeout;

  /// No description provided for @errorSessionExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك. سجّل الدخول مرة أخرى.'**
  String get errorSessionExpired;

  /// No description provided for @errorRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'طلبات كثيرة خلال وقت قصير. انتظر قليلًا ثم حاول.'**
  String get errorRateLimited;

  /// No description provided for @errorRateLimitedSeconds.
  ///
  /// In ar, this message translates to:
  /// **'طلبات كثيرة خلال وقت قصير. حاول بعد {seconds} ثانية.'**
  String errorRateLimitedSeconds(int seconds);

  /// No description provided for @errorAppNotConfigured.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق غير مهيأ للاتصال بالخادم حاليًا.'**
  String get errorAppNotConfigured;

  /// No description provided for @errorOutOfZone.
  ///
  /// In ar, this message translates to:
  /// **'هذا العنوان خارج منطقة التوصيل. اختر عنوانًا آخر.'**
  String get errorOutOfZone;

  /// No description provided for @errorOutOfStock.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المطلوبة غير متوفرة حاليًا.'**
  String get errorOutOfStock;

  /// No description provided for @errorOutOfStockAvailable.
  ///
  /// In ar, this message translates to:
  /// **'الكمية غير متوفرة. المتاح الآن: {count}.'**
  String errorOutOfStockAvailable(int count);

  /// No description provided for @errorStateChanged.
  ///
  /// In ar, this message translates to:
  /// **'تغيّرت حالة الطلب. حدّثنا البيانات، راجعها ثم تابع.'**
  String get errorStateChanged;

  /// No description provided for @remove.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get remove;

  /// No description provided for @reject.
  ///
  /// In ar, this message translates to:
  /// **'ارفض'**
  String get reject;

  /// No description provided for @quoteExpiredBody.
  ///
  /// In ar, this message translates to:
  /// **'حدّث السعر والتوفر قبل تأكيد الطلب.'**
  String get quoteExpiredBody;

  /// No description provided for @quoteUsedBody.
  ///
  /// In ar, this message translates to:
  /// **'راجع طلباتك قبل محاولة إنشاء طلب جديد.'**
  String get quoteUsedBody;
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
