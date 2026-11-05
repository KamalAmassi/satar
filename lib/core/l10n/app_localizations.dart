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
  /// **'بدائل قريبة بسعر مشابه'**
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

  /// No description provided for @dismiss.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get dismiss;

  /// No description provided for @increase.
  ///
  /// In ar, this message translates to:
  /// **'زيادة'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In ar, this message translates to:
  /// **'إنقاص'**
  String get decrease;

  /// No description provided for @deliveryFee.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل'**
  String get deliveryFee;

  /// No description provided for @printingServicesTitle.
  ///
  /// In ar, this message translates to:
  /// **'خدمات الطباعة'**
  String get printingServicesTitle;

  /// No description provided for @printingHeroEyebrow.
  ///
  /// In ar, this message translates to:
  /// **'من الملف للورق'**
  String get printingHeroEyebrow;

  /// No description provided for @printingHeroTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملفاتك علينا!'**
  String get printingHeroTitle;

  /// No description provided for @printingHeroBody.
  ///
  /// In ar, this message translates to:
  /// **'ارفع ملفك، اختار المواصفات، وخلي الطباعة علينا.'**
  String get printingHeroBody;

  /// No description provided for @printingServiceBw.
  ///
  /// In ar, this message translates to:
  /// **'أبيض وأسود {paper}'**
  String printingServiceBw(String paper);

  /// No description provided for @printingServiceColor.
  ///
  /// In ar, this message translates to:
  /// **'طباعة ملونة {paper}'**
  String printingServiceColor(String paper);

  /// No description provided for @perPrintedSide.
  ///
  /// In ar, this message translates to:
  /// **'{price} / وجه مطبوع'**
  String perPrintedSide(String price);

  /// No description provided for @perCopy.
  ///
  /// In ar, this message translates to:
  /// **'{price} / نسخة'**
  String perCopy(String price);

  /// No description provided for @printingFinalPriceNote.
  ///
  /// In ar, this message translates to:
  /// **'راجع عرض السعر النهائي قبل تأكيد الطلب.'**
  String get printingFinalPriceNote;

  /// No description provided for @printingStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بطلب طباعة'**
  String get printingStart;

  /// No description provided for @printSpecsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مواصفات الملفات'**
  String get printSpecsTitle;

  /// No description provided for @printSpecsHint.
  ///
  /// In ar, this message translates to:
  /// **'اختار مواصفات كل ملف، وراجع السعر قبل تأكيد طلبك.'**
  String get printSpecsHint;

  /// No description provided for @whatToPrint.
  ///
  /// In ar, this message translates to:
  /// **'شو بدك تطبع؟'**
  String get whatToPrint;

  /// No description provided for @supportedFiles.
  ///
  /// In ar, this message translates to:
  /// **'الملفات المدعومة'**
  String get supportedFiles;

  /// No description provided for @supportedFileTypes.
  ///
  /// In ar, this message translates to:
  /// **'PDF، JPG، PNG، WebP'**
  String get supportedFileTypes;

  /// No description provided for @maxFileSize.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى للحجم'**
  String get maxFileSize;

  /// No description provided for @maxPerFile.
  ///
  /// In ar, this message translates to:
  /// **'{size} لكل ملف'**
  String maxPerFile(String size);

  /// No description provided for @maxFiles.
  ///
  /// In ar, this message translates to:
  /// **'عدد الملفات المسموح'**
  String get maxFiles;

  /// No description provided for @tapToChooseFile.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لاختيار ملف'**
  String get tapToChooseFile;

  /// No description provided for @addAnotherFile.
  ///
  /// In ar, this message translates to:
  /// **'أضف ملف ثاني بمواصفات مختلفة'**
  String get addAnotherFile;

  /// No description provided for @fileLimitBody.
  ///
  /// In ar, this message translates to:
  /// **'وصلت لحد الملفات ({max}). احذف ملفًا قبل إضافة ملف طباعة جديد.'**
  String fileLimitBody(int max);

  /// No description provided for @uploadTooLargeTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف أكبر من الحجم المسموح'**
  String get uploadTooLargeTitle;

  /// No description provided for @uploadTooLargeBody.
  ///
  /// In ar, this message translates to:
  /// **'حجم كل ملف لازم يكون {size} أو أقل. صغّر الملف وحاول مرة ثانية.'**
  String uploadTooLargeBody(String size);

  /// No description provided for @uploadUnsupportedTitle.
  ///
  /// In ar, this message translates to:
  /// **'نوع الملف غير مدعوم'**
  String get uploadUnsupportedTitle;

  /// No description provided for @uploadUnsupportedBody.
  ///
  /// In ar, this message translates to:
  /// **'ارفع ملف بصيغة PDF أو JPG أو PNG أو WebP.'**
  String get uploadUnsupportedBody;

  /// No description provided for @uploadEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'الملف فارغ. اختر ملفًا آخر.'**
  String get uploadEmptyBody;

  /// No description provided for @chooseAnotherFile.
  ///
  /// In ar, this message translates to:
  /// **'اختيار ملف ثاني'**
  String get chooseAnotherFile;

  /// No description provided for @uploadingPercent.
  ///
  /// In ar, this message translates to:
  /// **'جاري الرفع… {percent}%'**
  String uploadingPercent(int percent);

  /// No description provided for @uploadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر رفع الملف.'**
  String get uploadFailed;

  /// No description provided for @pagesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{صفحة واحدة} =2{صفحتان} few{{count} صفحات} many{{count} صفحة} other{{count} صفحة}}'**
  String pagesCount(int count);

  /// No description provided for @paperSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الورق'**
  String get paperSize;

  /// No description provided for @printColor.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get printColor;

  /// No description provided for @printColorBw.
  ///
  /// In ar, this message translates to:
  /// **'أبيض وأسود'**
  String get printColorBw;

  /// No description provided for @printColorColor.
  ///
  /// In ar, this message translates to:
  /// **'ملون'**
  String get printColorColor;

  /// No description provided for @printSides.
  ///
  /// In ar, this message translates to:
  /// **'الطباعة'**
  String get printSides;

  /// No description provided for @printSidesSingle.
  ///
  /// In ar, this message translates to:
  /// **'وجه واحد'**
  String get printSidesSingle;

  /// No description provided for @printSidesDouble.
  ///
  /// In ar, this message translates to:
  /// **'وجهان'**
  String get printSidesDouble;

  /// No description provided for @binding.
  ///
  /// In ar, this message translates to:
  /// **'التجليد'**
  String get binding;

  /// No description provided for @pageRange.
  ///
  /// In ar, this message translates to:
  /// **'نطاق الصفحات'**
  String get pageRange;

  /// No description provided for @pageRangeAllHint.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get pageRangeAllHint;

  /// No description provided for @pageRangeHelper.
  ///
  /// In ar, this message translates to:
  /// **'اتركه فارغًا لطباعة الكل، أو اكتب نطاقًا مثل 1-5 وافصل بين الأجزاء بفاصلة. عدد صفحات الملف: {pages}.'**
  String pageRangeHelper(int pages);

  /// No description provided for @pageRangeInvalid.
  ///
  /// In ar, this message translates to:
  /// **'راجع نطاق الصفحات: اكتب نطاقًا مثل 1-5 وافصل بين الأجزاء بفاصلة، ضمن عدد صفحات الملف.'**
  String get pageRangeInvalid;

  /// No description provided for @copies.
  ///
  /// In ar, this message translates to:
  /// **'عدد النسخ'**
  String get copies;

  /// No description provided for @pagesTimesCopies.
  ///
  /// In ar, this message translates to:
  /// **'الصفحات: {pages} · النسخ: {copies}'**
  String pagesTimesCopies(int pages, int copies);

  /// No description provided for @fileNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات لهذا الملف'**
  String get fileNotes;

  /// No description provided for @fileNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'أي تفاصيل إضافية؟'**
  String get fileNotesHint;

  /// No description provided for @estimateForFile.
  ///
  /// In ar, this message translates to:
  /// **'التقدير لهذا الملف'**
  String get estimateForFile;

  /// No description provided for @estimateLabel.
  ///
  /// In ar, this message translates to:
  /// **'التقدير'**
  String get estimateLabel;

  /// No description provided for @reviewPrice.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة السعر'**
  String get reviewPrice;

  /// No description provided for @cartTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلّتك'**
  String get cartTitle;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلّتك فاضية'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أضف منتجات أو ملفات طباعة للمتابعة.'**
  String get cartEmptyBody;

  /// No description provided for @startShopping.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسوق'**
  String get startShopping;

  /// No description provided for @productsSection.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get productsSection;

  /// No description provided for @printingSection.
  ///
  /// In ar, this message translates to:
  /// **'الطباعة'**
  String get printingSection;

  /// No description provided for @productNumber.
  ///
  /// In ar, this message translates to:
  /// **'منتج رقم {id}'**
  String productNumber(int id);

  /// No description provided for @pricedByLibrary.
  ///
  /// In ar, this message translates to:
  /// **'تسعّره المكتبة'**
  String get pricedByLibrary;

  /// No description provided for @productUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'هذا المنتج غير متوفر حاليًا.'**
  String get productUnavailable;

  /// No description provided for @onlyAvailable.
  ///
  /// In ar, this message translates to:
  /// **'المتوفر حاليًا {count} فقط. عدّل الكمية.'**
  String onlyAvailable(int count);

  /// No description provided for @chooseOption.
  ///
  /// In ar, this message translates to:
  /// **'اختر {label}'**
  String chooseOption(String label);

  /// No description provided for @illustrativePrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر توضيحي'**
  String get illustrativePrice;

  /// No description provided for @printingIllustrative.
  ///
  /// In ar, this message translates to:
  /// **'الطباعة (تقدير)'**
  String get printingIllustrative;

  /// No description provided for @notesForLibrary.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات للمكتبة'**
  String get notesForLibrary;

  /// No description provided for @notesForLibraryHint.
  ///
  /// In ar, this message translates to:
  /// **'أي تفاصيل بتحب تضيفها؟'**
  String get notesForLibraryHint;

  /// No description provided for @ifOutOfStock.
  ///
  /// In ar, this message translates to:
  /// **'لو المنتج خلص'**
  String get ifOutOfStock;

  /// No description provided for @deliveryByAddress.
  ///
  /// In ar, this message translates to:
  /// **'تُحسب حسب العنوان'**
  String get deliveryByAddress;

  /// No description provided for @totalBeforeDelivery.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي قبل التوصيل'**
  String get totalBeforeDelivery;

  /// No description provided for @finalPriceAtReview.
  ///
  /// In ar, this message translates to:
  /// **'الأسعار هنا للعرض. السعر النهائي يظهر في مراجعة الطلب.'**
  String get finalPriceAtReview;

  /// No description provided for @continueToDelivery.
  ///
  /// In ar, this message translates to:
  /// **'تابع للتوصيل'**
  String get continueToDelivery;

  /// No description provided for @waitForUploads.
  ///
  /// In ar, this message translates to:
  /// **'انتظر اكتمال رفع الملفات قبل المتابعة.'**
  String get waitForUploads;

  /// No description provided for @fixFailedUploads.
  ///
  /// In ar, this message translates to:
  /// **'بعض الملفات لم تُرفع. أعد المحاولة أو احذفها.'**
  String get fixFailedUploads;

  /// No description provided for @uploadInterrupted.
  ///
  /// In ar, this message translates to:
  /// **'انقطع رفع هذا الملف لأن التطبيق أُغلق قبل اكتماله. اختر الملف نفسه مرة أخرى أو احذفه.'**
  String get uploadInterrupted;

  /// No description provided for @uploadInterruptedShort.
  ///
  /// In ar, this message translates to:
  /// **'انقطع الرفع — اختر الملف مرة أخرى.'**
  String get uploadInterruptedShort;

  /// No description provided for @chooseFileAgain.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الملف'**
  String get chooseFileAgain;

  /// No description provided for @fixInterruptedUploads.
  ///
  /// In ar, this message translates to:
  /// **'انقطع رفع بعض ملفات الطباعة. افتح مواصفات الطباعة واختر الملفات مرة أخرى أو احذفها.'**
  String get fixInterruptedUploads;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @discount.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get discount;

  /// No description provided for @payment.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get payment;

  /// No description provided for @orderCode.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get orderCode;

  /// No description provided for @orderStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الطلب'**
  String get orderStatus;

  /// No description provided for @viewOrder.
  ///
  /// In ar, this message translates to:
  /// **'عرض الطلب'**
  String get viewOrder;

  /// No description provided for @viewMyOrders.
  ///
  /// In ar, this message translates to:
  /// **'عرض طلباتي'**
  String get viewMyOrders;

  /// No description provided for @deliveryTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان التوصيل'**
  String get deliveryTitle;

  /// No description provided for @whereToDeliver.
  ///
  /// In ar, this message translates to:
  /// **'وين نوصّلك؟'**
  String get whereToDeliver;

  /// No description provided for @addAddress.
  ///
  /// In ar, this message translates to:
  /// **'أضف عنوان'**
  String get addAddress;

  /// No description provided for @noAddresses.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناوين محفوظة. أضف عنوانًا للمتابعة.'**
  String get noAddresses;

  /// No description provided for @addressNumber.
  ///
  /// In ar, this message translates to:
  /// **'عنوان {id}'**
  String addressNumber(int id);

  /// No description provided for @insideDeliveryArea.
  ///
  /// In ar, this message translates to:
  /// **'داخل منطقة التوصيل'**
  String get insideDeliveryArea;

  /// No description provided for @outsideDeliveryArea.
  ///
  /// In ar, this message translates to:
  /// **'خارج منطقة التوصيل'**
  String get outsideDeliveryArea;

  /// No description provided for @recipientNameOptional.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستلم (اختياري)'**
  String get recipientNameOptional;

  /// No description provided for @recipientNameHint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get recipientNameHint;

  /// No description provided for @recipientPhoneOptional.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف (اختياري)'**
  String get recipientPhoneOptional;

  /// No description provided for @phoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير صحيح.'**
  String get phoneInvalid;

  /// No description provided for @deliveryNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات التوصيل'**
  String get deliveryNotes;

  /// No description provided for @deliveryNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'علامة مميزة أو تفاصيل الوصول'**
  String get deliveryNotesHint;

  /// No description provided for @deliveryFeeAtReview.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل والإجمالي النهائي تظهر في مراجعة الطلب.'**
  String get deliveryFeeAtReview;

  /// No description provided for @continueToPayment.
  ///
  /// In ar, this message translates to:
  /// **'متابعة للدفع'**
  String get continueToPayment;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethodTitle;

  /// No description provided for @howToPay.
  ///
  /// In ar, this message translates to:
  /// **'كيف بتحب تدفع؟'**
  String get howToPay;

  /// No description provided for @payCashOnDelivery.
  ///
  /// In ar, this message translates to:
  /// **'نقدًا عند التسليم'**
  String get payCashOnDelivery;

  /// No description provided for @payBankTransfer.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بنكي أو محفظة'**
  String get payBankTransfer;

  /// No description provided for @paymentMethodNote.
  ///
  /// In ar, this message translates to:
  /// **'يظهر مبلغ التحصيل والتفاصيل قبل تأكيد الطلب.'**
  String get paymentMethodNote;

  /// No description provided for @transferAfterOrderNote.
  ///
  /// In ar, this message translates to:
  /// **'ارفع إشعار التحويل بعد أن تؤكد المكتبة سعر الطلب.'**
  String get transferAfterOrderNote;

  /// No description provided for @reviewOrder.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الطلب'**
  String get reviewOrder;

  /// No description provided for @reviewBeforeConfirm.
  ///
  /// In ar, this message translates to:
  /// **'راجع طلبك قبل التأكيد'**
  String get reviewBeforeConfirm;

  /// No description provided for @orderType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الطلب'**
  String get orderType;

  /// No description provided for @orderTypeProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات'**
  String get orderTypeProducts;

  /// No description provided for @orderTypePrinting.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get orderTypePrinting;

  /// No description provided for @orderTypeMixed.
  ///
  /// In ar, this message translates to:
  /// **'منتجات وطباعة'**
  String get orderTypeMixed;

  /// No description provided for @quoteValidFor.
  ///
  /// In ar, this message translates to:
  /// **'التسعيرة صالحة لمدة {minutes}:{seconds}'**
  String quoteValidFor(int minutes, String seconds);

  /// No description provided for @libraryConfirmsNote.
  ///
  /// In ar, this message translates to:
  /// **'بعد التأكيد تراجع المكتبة طلبك وترسل لك عرض السعر النهائي للموافقة.'**
  String get libraryConfirmsNote;

  /// No description provided for @confirmOrder.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب'**
  String get confirmOrder;

  /// No description provided for @quoteLoadingTitle.
  ///
  /// In ar, this message translates to:
  /// **'جاري حساب السعر'**
  String get quoteLoadingTitle;

  /// No description provided for @quoteLoadingBody.
  ///
  /// In ar, this message translates to:
  /// **'بنطلب السعر والتوفر الحاليين.'**
  String get quoteLoadingBody;

  /// No description provided for @quoteFailedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حساب السعر'**
  String get quoteFailedTitle;

  /// No description provided for @quoteFailedBody.
  ///
  /// In ar, this message translates to:
  /// **'راجع الاتصال والعنوان وخيارات الطلب، ثم حاول مجددًا.'**
  String get quoteFailedBody;

  /// No description provided for @quoteNotReady.
  ///
  /// In ar, this message translates to:
  /// **'أكمل السلة والعنوان وطريقة الدفع وانتظر رفع الملفات قبل طلب السعر.'**
  String get quoteNotReady;

  /// No description provided for @fixHighlightedItems.
  ///
  /// In ar, this message translates to:
  /// **'صحّح العناصر المحددة في السلة ثم حاول مجددًا.'**
  String get fixHighlightedItems;

  /// No description provided for @backToCart.
  ///
  /// In ar, this message translates to:
  /// **'العودة للسلة'**
  String get backToCart;

  /// No description provided for @changeAddress.
  ///
  /// In ar, this message translates to:
  /// **'تغيير العنوان'**
  String get changeAddress;

  /// No description provided for @quoteExpiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية التسعيرة'**
  String get quoteExpiredTitle;

  /// No description provided for @quoteStaleTitle.
  ///
  /// In ar, this message translates to:
  /// **'تغيّر طلبك'**
  String get quoteStaleTitle;

  /// No description provided for @quoteStaleBody.
  ///
  /// In ar, this message translates to:
  /// **'عدّلت السلة أو التوصيل بعد التسعيرة. اطلب سعرًا جديدًا وراجعه.'**
  String get quoteStaleBody;

  /// No description provided for @quoteUsedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم استخدام هذه التسعيرة'**
  String get quoteUsedTitle;

  /// No description provided for @refreshQuote.
  ///
  /// In ar, this message translates to:
  /// **'تحديث التسعيرة'**
  String get refreshQuote;

  /// No description provided for @priceChangedBody.
  ///
  /// In ar, this message translates to:
  /// **'تغيّر السعر. راجع السعر الجديد قبل المتابعة.'**
  String get priceChangedBody;

  /// No description provided for @paymentMethodChangedBody.
  ///
  /// In ar, this message translates to:
  /// **'غيّرت طريقة الدفع، فأصدرنا تسعيرة جديدة لها. المبلغ لم يتغيّر.'**
  String get paymentMethodChangedBody;

  /// No description provided for @previousPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر السابق'**
  String get previousPrice;

  /// No description provided for @currentPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر الحالي'**
  String get currentPrice;

  /// No description provided for @acceptNewPrice.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على السعر الجديد'**
  String get acceptNewPrice;

  /// No description provided for @submittingTitle.
  ///
  /// In ar, this message translates to:
  /// **'جاري إنشاء طلبك'**
  String get submittingTitle;

  /// No description provided for @submittingBody.
  ///
  /// In ar, this message translates to:
  /// **'بنثبت تفاصيل الطلب والسعر.'**
  String get submittingBody;

  /// No description provided for @uncertainTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرنا نتأكد من النتيجة'**
  String get uncertainTitle;

  /// No description provided for @uncertainBody.
  ///
  /// In ar, this message translates to:
  /// **'ربما أُنشئ طلبك. تحقق مرة أخرى أو راجع طلباتك قبل إعادة المحاولة حتى لا يتكرر الطلب.'**
  String get uncertainBody;

  /// No description provided for @checkAgain.
  ///
  /// In ar, this message translates to:
  /// **'تحقق مرة أخرى'**
  String get checkAgain;

  /// No description provided for @checkMyOrders.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من طلباتي'**
  String get checkMyOrders;

  /// No description provided for @orderCreatedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الطلب'**
  String get orderCreatedTitle;

  /// No description provided for @orderCreatedBody.
  ///
  /// In ar, this message translates to:
  /// **'تابع حالة الطلب لمعرفة الخطوة التالية.'**
  String get orderCreatedBody;

  /// No description provided for @orderAwaitingPaymentTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء طلبك'**
  String get orderAwaitingPaymentTitle;

  /// No description provided for @orderCreatedTransferBody.
  ///
  /// In ar, this message translates to:
  /// **'ستراجع المكتبة الطلب، ثم حوّل المبلغ وارفع الإشعار عند فتح الدفع.'**
  String get orderCreatedTransferBody;

  /// No description provided for @viewTransferDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض بيانات التحويل'**
  String get viewTransferDetails;

  /// No description provided for @copy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get copied;

  /// No description provided for @copyLink.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الرابط'**
  String get copyLink;

  /// No description provided for @transferTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع بالتحويل'**
  String get transferTitle;

  /// No description provided for @transferHeadline.
  ///
  /// In ar, this message translates to:
  /// **'حوّل المبلغ وارفع الإشعار'**
  String get transferHeadline;

  /// No description provided for @transferSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أكمل التحويل خارج سطر ثم ارفع إشعاره.'**
  String get transferSubtitle;

  /// No description provided for @correctionTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح إشعار الدفع'**
  String get correctionTitle;

  /// No description provided for @correctionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبت المكتبة تصحيحًا. ارفع إشعارًا جديدًا حسب الملاحظة.'**
  String get correctionSubtitle;

  /// No description provided for @libraryNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة المكتبة'**
  String get libraryNote;

  /// No description provided for @previousReceipt.
  ///
  /// In ar, this message translates to:
  /// **'الإشعار السابق'**
  String get previousReceipt;

  /// No description provided for @amountDue.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المطلوب'**
  String get amountDue;

  /// No description provided for @recipientAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب المستلم'**
  String get recipientAccount;

  /// No description provided for @noTransferAccounts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات حساب حاليًا. تواصل مع المكتبة.'**
  String get noTransferAccounts;

  /// No description provided for @wallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة'**
  String get wallet;

  /// No description provided for @bank.
  ///
  /// In ar, this message translates to:
  /// **'بنك'**
  String get bank;

  /// No description provided for @uploadReceipt.
  ///
  /// In ar, this message translates to:
  /// **'ارفع إشعار التحويل'**
  String get uploadReceipt;

  /// No description provided for @receiptTypes.
  ///
  /// In ar, this message translates to:
  /// **'صورة أو PDF · حتى {size}'**
  String receiptTypes(String size);

  /// No description provided for @chooseReceipt.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الإشعار'**
  String get chooseReceipt;

  /// No description provided for @replaceReceipt.
  ///
  /// In ar, this message translates to:
  /// **'استبدال'**
  String get replaceReceipt;

  /// No description provided for @receiptPreview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة الإشعار'**
  String get receiptPreview;

  /// No description provided for @submitReceipt.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إشعار الدفع'**
  String get submitReceipt;

  /// No description provided for @resubmitReceipt.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الإشعار'**
  String get resubmitReceipt;

  /// No description provided for @receiptNotApproval.
  ///
  /// In ar, this message translates to:
  /// **'بعد الإرسال: قيد مراجعة المكتبة — لا يعني اعتماد الدفع.'**
  String get receiptNotApproval;

  /// No description provided for @receiptSentTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الإشعار'**
  String get receiptSentTitle;

  /// No description provided for @receiptUnderReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعار قيد المراجعة'**
  String get receiptUnderReviewTitle;

  /// No description provided for @receiptUnderReviewBody.
  ///
  /// In ar, this message translates to:
  /// **'تراجع المكتبة الإشعار قبل اعتماد الدفع. لا يمكن إرسال إشعار آخر أثناء المراجعة.'**
  String get receiptUnderReviewBody;

  /// No description provided for @refreshStatus.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الحالة'**
  String get refreshStatus;

  /// No description provided for @paymentStateChanged.
  ///
  /// In ar, this message translates to:
  /// **'تغيّرت حالة الدفع. حدّثنا الشاشة بآخر حالة.'**
  String get paymentStateChanged;

  /// No description provided for @transferNotOpenTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدفع لم يُفتح بعد'**
  String get transferNotOpenTitle;

  /// No description provided for @transferNotOpenBody.
  ///
  /// In ar, this message translates to:
  /// **'تراجع المكتبة طلبك. يُفتح رفع الإشعار عندما يصبح الطلب بانتظار الدفع.'**
  String get transferNotOpenBody;

  /// No description provided for @transferNeedsOfferBody.
  ///
  /// In ar, this message translates to:
  /// **'أرسلت المكتبة عرض السعر. وافق عليه أولًا ليُفتح الدفع.'**
  String get transferNeedsOfferBody;

  /// No description provided for @reviewLibraryOffer.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة عرض المكتبة'**
  String get reviewLibraryOffer;

  /// No description provided for @paymentConfirmedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم اعتماد الدفع'**
  String get paymentConfirmedTitle;

  /// No description provided for @paymentConfirmedBody.
  ///
  /// In ar, this message translates to:
  /// **'اعتمدت المكتبة الدفع ويتابع الطلب خطواته.'**
  String get paymentConfirmedBody;

  /// No description provided for @notTransferOrderTitle.
  ///
  /// In ar, this message translates to:
  /// **'هذا الطلب ليس بالتحويل'**
  String get notTransferOrderTitle;

  /// No description provided for @notTransferOrderBody.
  ///
  /// In ar, this message translates to:
  /// **'لا يحتاج هذا الطلب إشعار تحويل.'**
  String get notTransferOrderBody;

  /// No description provided for @libraryOfferTitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض المكتبة'**
  String get libraryOfferTitle;

  /// No description provided for @offerValidFor.
  ///
  /// In ar, this message translates to:
  /// **'العرض صالح لمدة {time}'**
  String offerValidFor(String time);

  /// No description provided for @reviewPriceAndSubstitutes.
  ///
  /// In ar, this message translates to:
  /// **'راجع السعر والبدائل'**
  String get reviewPriceAndSubstitutes;

  /// No description provided for @offerIntro.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة راجعت طلبك وجهّزت العرض التالي.'**
  String get offerIntro;

  /// No description provided for @itemUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'{name} غير متوفر'**
  String itemUnavailable(String name);

  /// No description provided for @qtyTimesUnit.
  ///
  /// In ar, this message translates to:
  /// **'{qty} × {unit}'**
  String qtyTimesUnit(int qty, String unit);

  /// No description provided for @suggestedSubstitute.
  ///
  /// In ar, this message translates to:
  /// **'البديل المقترح: {name}'**
  String suggestedSubstitute(String name);

  /// No description provided for @samePrice.
  ///
  /// In ar, this message translates to:
  /// **'نفس السعر'**
  String get samePrice;

  /// No description provided for @priceHigherBy.
  ///
  /// In ar, this message translates to:
  /// **'أغلى بـ {amount}'**
  String priceHigherBy(String amount);

  /// No description provided for @priceLowerBy.
  ///
  /// In ar, this message translates to:
  /// **'أرخص بـ {amount}'**
  String priceLowerBy(String amount);

  /// No description provided for @acceptSubstitutes.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على التعديلات المقترحة (البنود غير المتوفرة والبدائل)'**
  String get acceptSubstitutes;

  /// No description provided for @productsAndPrinting.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات والطباعة'**
  String get productsAndPrinting;

  /// No description provided for @approvePrice.
  ///
  /// In ar, this message translates to:
  /// **'وافق على السعر'**
  String get approvePrice;

  /// No description provided for @rejectOfferTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفض العرض؟'**
  String get rejectOfferTitle;

  /// No description provided for @rejectOfferBody.
  ///
  /// In ar, this message translates to:
  /// **'رفض العرض يلغي الطلب. إذا كنت دفعت مبلغًا فتواصل مع المكتبة؛ الاسترداد ليس تلقائيًا.'**
  String get rejectOfferBody;

  /// No description provided for @offerNotReadyTitle.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة تراجع طلبك'**
  String get offerNotReadyTitle;

  /// No description provided for @offerNotReadyBody.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر عرض السعر هنا عندما تجهّزه المكتبة.'**
  String get offerNotReadyBody;

  /// No description provided for @refreshOffer.
  ///
  /// In ar, this message translates to:
  /// **'تحديث العرض'**
  String get refreshOffer;

  /// No description provided for @offerExpiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية العرض'**
  String get offerExpiredTitle;

  /// No description provided for @offerExpiredBody.
  ///
  /// In ar, this message translates to:
  /// **'ما بتقدر توافق على هذا العرض. تواصل مع المكتبة أو حدّث العرض.'**
  String get offerExpiredBody;

  /// No description provided for @offerChangedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث العرض'**
  String get offerChangedTitle;

  /// No description provided for @offerChangedBody.
  ///
  /// In ar, this message translates to:
  /// **'حدّث العرض وراجع البنود قبل الموافقة.'**
  String get offerChangedBody;

  /// No description provided for @offerApprovedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تمت الموافقة على العرض'**
  String get offerApprovedTitle;

  /// No description provided for @offerApprovedBody.
  ///
  /// In ar, this message translates to:
  /// **'يتابع طلبك خطواته. تابع حالته من طلباتك.'**
  String get offerApprovedBody;

  /// No description provided for @offerRejectedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض العرض'**
  String get offerRejectedTitle;

  /// No description provided for @offerRejectedBody.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي الطلب. للاستفسار عن أي مبلغ مدفوع تواصل مع المكتبة.'**
  String get offerRejectedBody;

  /// Settings row title for the haptic feedback toggle
  ///
  /// In ar, this message translates to:
  /// **'الاهتزاز'**
  String get vibrationSettingTitle;

  /// Settings row subtitle for the haptic feedback toggle
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز خفيف عند اللمس وتأكيد الإجراءات'**
  String get vibrationSettingSub;

  /// Screen reader label for the quantity stepper plus button
  ///
  /// In ar, this message translates to:
  /// **'زيادة الكمية'**
  String get stepperIncrease;

  /// Screen reader label for the quantity stepper minus button
  ///
  /// In ar, this message translates to:
  /// **'إنقاص الكمية'**
  String get stepperDecrease;

  /// No description provided for @voiceRecordingPill.
  ///
  /// In ar, this message translates to:
  /// **'يسجّل · {time}'**
  String voiceRecordingPill(String time);

  /// No description provided for @voiceRecordingSemantics.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التسجيل، مضى {time}. نحن نستمع إليك.'**
  String voiceRecordingSemantics(String time);

  /// No description provided for @productImageSemantics.
  ///
  /// In ar, this message translates to:
  /// **'صورة {name}'**
  String productImageSemantics(String name);

  /// No description provided for @productImageOpen.
  ///
  /// In ar, this message translates to:
  /// **'فتح صورة المنتج بملء الشاشة'**
  String get productImageOpen;

  /// No description provided for @imageViewerClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get imageViewerClose;

  /// No description provided for @imageViewerPage.
  ///
  /// In ar, this message translates to:
  /// **'الصورة {current} من {total}'**
  String imageViewerPage(int current, int total);

  /// No description provided for @celebrationOrderPlaced.
  ///
  /// In ar, this message translates to:
  /// **'تم بنجاح! أُرسل طلبك إلى المكتبة.'**
  String get celebrationOrderPlaced;

  /// No description provided for @celebrationDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم بنجاح. أحسنت!'**
  String get celebrationDelivered;

  /// No description provided for @celebrationOrderDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم تسليم طلبك.'**
  String get celebrationOrderDelivered;

  /// No description provided for @driverLocationLive.
  ///
  /// In ar, this message translates to:
  /// **'موقع السائق مباشر'**
  String get driverLocationLive;

  /// No description provided for @driverLocationStale.
  ///
  /// In ar, this message translates to:
  /// **'آخر موقع للسائق قبل {minutes} دقيقة. قد يكون في منطقة ضعيفة التغطية.'**
  String driverLocationStale(int minutes);

  /// No description provided for @driverLocationNone.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار أول موقع للسائق.'**
  String get driverLocationNone;

  /// No description provided for @driverEtaShort.
  ///
  /// In ar, this message translates to:
  /// **'نحو {minutes} دقيقة'**
  String driverEtaShort(int minutes);

  /// No description provided for @driverMarkerSemantics.
  ///
  /// In ar, this message translates to:
  /// **'موقع السائق على الخريطة'**
  String get driverMarkerSemantics;

  /// No description provided for @driverOrderUnavailableTitle.
  ///
  /// In ar, this message translates to:
  /// **'هذا الطلب لم يعد متاحًا'**
  String get driverOrderUnavailableTitle;

  /// No description provided for @driverOrderUnavailableText.
  ///
  /// In ar, this message translates to:
  /// **'ربما أُلغي أو تغيّر. سنعرض لك طلبات أخرى قريبة.'**
  String get driverOrderUnavailableText;

  /// No description provided for @driverAvailableOrders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات المتاحة'**
  String get driverAvailableOrders;

  /// No description provided for @driverAcceptOfflineTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل'**
  String get driverAcceptOfflineTitle;

  /// No description provided for @driverAcceptOfflineText.
  ///
  /// In ar, this message translates to:
  /// **'فعّل الاتصال لتتمكن من قبول الطلبات.'**
  String get driverAcceptOfflineText;

  /// No description provided for @driverGoOnline.
  ///
  /// In ar, this message translates to:
  /// **'اتصل الآن'**
  String get driverGoOnline;

  /// No description provided for @driverAcceptInvalidTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن قبول هذا الطلب الآن'**
  String get driverAcceptInvalidTitle;

  /// No description provided for @driverAcceptInvalidText.
  ///
  /// In ar, this message translates to:
  /// **'قد تكون لديك مهمة جارية، أو تغيّرت حالة الطلب.'**
  String get driverAcceptInvalidText;

  /// No description provided for @driverSessionExpiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك'**
  String get driverSessionExpiredTitle;

  /// No description provided for @driverSessionExpiredText.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول من جديد للمتابعة.'**
  String get driverSessionExpiredText;

  /// No description provided for @driverSignIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get driverSignIn;

  /// No description provided for @driverNetworkTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال'**
  String get driverNetworkTitle;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'أعد المحاولة'**
  String get commonRetry;

  /// No description provided for @commonOk.
  ///
  /// In ar, this message translates to:
  /// **'حسنًا'**
  String get commonOk;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد رقمك'**
  String get otpTitle;

  /// No description provided for @otpHeadline.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق'**
  String get otpHeadline;

  /// No description provided for @otpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رمزًا برسالة نصية إلى {phone}.'**
  String otpSubtitle(String phone);

  /// No description provided for @otpCodeSemantics.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق، {length} أرقام'**
  String otpCodeSemantics(int length);

  /// No description provided for @otpVerify.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get otpVerify;

  /// No description provided for @otpResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get otpResend;

  /// No description provided for @otpResendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد {seconds} ث'**
  String otpResendIn(int seconds);

  /// No description provided for @otpChangeNumber.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الرقم'**
  String get otpChangeNumber;

  /// No description provided for @otpResent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل رمز جديد.'**
  String get otpResent;

  /// No description provided for @otpErrInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الرمز غير صحيح. تحقق منه وحاول مجددًا.'**
  String get otpErrInvalid;

  /// No description provided for @otpErrExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية الرمز. اطلب رمزًا جديدًا.'**
  String get otpErrExpired;

  /// No description provided for @otpErrTooMany.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة. انتظر قليلًا ثم حاول.'**
  String get otpErrTooMany;

  /// No description provided for @otpErrPhone.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن إرسال رمز إلى هذا الرقم.'**
  String get otpErrPhone;

  /// No description provided for @otpErrNetwork.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال. تحقق من الإنترنت وحاول مجددًا.'**
  String get otpErrNetwork;

  /// No description provided for @otpErrUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'التحقق غير متاح الآن. حاول لاحقًا.'**
  String get otpErrUnavailable;

  /// No description provided for @otpDevMockNotice.
  ///
  /// In ar, this message translates to:
  /// **'للمطورين فقط: مفاتيح Twilio ناقصة، لذا يُستخدم الرمز التجريبي 1234.'**
  String get otpDevMockNotice;

  /// No description provided for @driverOtpTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد هويتك'**
  String get driverOtpTitle;

  /// No description provided for @driverLoginBrand.
  ///
  /// In ar, this message translates to:
  /// **'سطر | السائق'**
  String get driverLoginBrand;

  /// No description provided for @driverLoginHeadline.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك'**
  String get driverLoginHeadline;

  /// No description provided for @driverLoginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لتبدأ باستلام مهام التوصيل.'**
  String get driverLoginSubtitle;

  /// No description provided for @driverLoginPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get driverLoginPhone;

  /// No description provided for @driverLoginPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get driverLoginPassword;

  /// No description provided for @driverLoginPhoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم جوال صحيحًا، مثل 0599123456.'**
  String get driverLoginPhoneInvalid;

  /// No description provided for @driverLoginPasswordRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور.'**
  String get driverLoginPasswordRequired;

  /// No description provided for @driverLoginBadCredentials.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال أو كلمة المرور غير صحيحة.'**
  String get driverLoginBadCredentials;

  /// No description provided for @driverLoginSubmit.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get driverLoginSubmit;

  /// No description provided for @driverLoginShowPassword.
  ///
  /// In ar, this message translates to:
  /// **'إظهار كلمة المرور'**
  String get driverLoginShowPassword;

  /// No description provided for @driverLoginHidePassword.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء كلمة المرور'**
  String get driverLoginHidePassword;

  /// No description provided for @driverLoginForgot.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get driverLoginForgot;

  /// No description provided for @driverLoginForgotText.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع مشغّل سطر ليعيد ضبطها.'**
  String get driverLoginForgotText;

  /// No description provided for @driverLoginSupport.
  ///
  /// In ar, this message translates to:
  /// **'التواصل مع الدعم'**
  String get driverLoginSupport;

  /// No description provided for @driverLoginSupportText.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع مشغّل سطر للمساعدة في حسابك.'**
  String get driverLoginSupportText;

  /// No description provided for @driverLoginVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String driverLoginVersion(String version);

  /// No description provided for @driverDeliverCta.
  ///
  /// In ar, this message translates to:
  /// **'تسليم الطلب'**
  String get driverDeliverCta;

  /// No description provided for @driverFailDeliveryCta.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التسليم'**
  String get driverFailDeliveryCta;

  /// No description provided for @driverDeliverTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التسليم'**
  String get driverDeliverTitle;

  /// No description provided for @driverDeliverHint.
  ///
  /// In ar, this message translates to:
  /// **'اطلب من الزبون كود التسليم الظاهر في تطبيقه'**
  String get driverDeliverHint;

  /// No description provided for @driverDeliverConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التسليم'**
  String get driverDeliverConfirm;

  /// No description provided for @driverDeliverPaste.
  ///
  /// In ar, this message translates to:
  /// **'لصق الكود'**
  String get driverDeliverPaste;

  /// No description provided for @driverDeliverCollect.
  ///
  /// In ar, this message translates to:
  /// **'حصّل من الزبون'**
  String get driverDeliverCollect;

  /// No description provided for @driverDeliverErrWrong.
  ///
  /// In ar, this message translates to:
  /// **'كود التسليم غير صحيح. تأكد منه مع الزبون وأعد المحاولة.'**
  String get driverDeliverErrWrong;

  /// No description provided for @driverDeliverErrTooMany.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة. انتظر قليلًا ثم أعد المحاولة.'**
  String get driverDeliverErrTooMany;

  /// No description provided for @driverDeliverErrState.
  ///
  /// In ar, this message translates to:
  /// **'لم يعد هذا الطلب قابلًا للتسليم. حدّث المهمة.'**
  String get driverDeliverErrState;

  /// No description provided for @driverDeliverErrNetwork.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال. تحقق من الإنترنت وأعد المحاولة.'**
  String get driverDeliverErrNetwork;

  /// No description provided for @driverDeliverErrSession.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك. سجّل الدخول من جديد.'**
  String get driverDeliverErrSession;

  /// No description provided for @driverDeliverRefresh.
  ///
  /// In ar, this message translates to:
  /// **'حدّث المهمة'**
  String get driverDeliverRefresh;

  /// No description provided for @orderDeliveryCodeTitle.
  ///
  /// In ar, this message translates to:
  /// **'كود التسليم'**
  String get orderDeliveryCodeTitle;

  /// No description provided for @orderDeliveryCodeCaption.
  ///
  /// In ar, this message translates to:
  /// **'أعطِ هذا الكود للسائق عند الاستلام فقط'**
  String get orderDeliveryCodeCaption;

  /// No description provided for @driverSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get driverSettingsTitle;

  /// No description provided for @driverSettingsOnline.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get driverSettingsOnline;

  /// No description provided for @driverSettingsOffline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get driverSettingsOffline;

  /// No description provided for @driverSettingsRatingCount.
  ///
  /// In ar, this message translates to:
  /// **'{rating} · {count} تقييمًا'**
  String driverSettingsRatingCount(String rating, int count);

  /// No description provided for @driverSettingsMyData.
  ///
  /// In ar, this message translates to:
  /// **'بياناتي'**
  String get driverSettingsMyData;

  /// No description provided for @driverSettingsName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get driverSettingsName;

  /// No description provided for @driverSettingsPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get driverSettingsPhone;

  /// No description provided for @driverSettingsVehicle.
  ///
  /// In ar, this message translates to:
  /// **'المركبة'**
  String get driverSettingsVehicle;

  /// No description provided for @driverSettingsZone.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة'**
  String get driverSettingsZone;

  /// No description provided for @driverSettingsCash.
  ///
  /// In ar, this message translates to:
  /// **'النقد معك'**
  String get driverSettingsCash;

  /// No description provided for @driverSettingsCashNearLimit.
  ///
  /// In ar, this message translates to:
  /// **'اقتربت من الحد الأقصى للنقد. سلّم النقد قريبًا.'**
  String get driverSettingsCashNearLimit;

  /// No description provided for @driverSettingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get driverSettingsLanguage;

  /// No description provided for @driverSettingsLoadErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل بياناتك'**
  String get driverSettingsLoadErrorTitle;

  /// No description provided for @driverSettingsLoadErrorText.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من الاتصال ثم أعد المحاولة.'**
  String get driverSettingsLoadErrorText;

  /// No description provided for @driverSettingsRetry.
  ///
  /// In ar, this message translates to:
  /// **'أعد المحاولة'**
  String get driverSettingsRetry;

  /// No description provided for @driverSettingsNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get driverSettingsNotifications;

  /// No description provided for @driverSettingsNotifHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الإشعارات'**
  String get driverSettingsNotifHistory;

  /// No description provided for @driverSettingsLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get driverSettingsLogout;

  /// No description provided for @driverSettingsLogoutSub.
  ///
  /// In ar, this message translates to:
  /// **'ستصبح غير متصل'**
  String get driverSettingsLogoutSub;

  /// No description provided for @driverSettingsLogoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج؟'**
  String get driverSettingsLogoutTitle;

  /// No description provided for @driverSettingsLogoutText.
  ///
  /// In ar, this message translates to:
  /// **'سيصبح حسابك غير متصل ولن تصلك طلبات.'**
  String get driverSettingsLogoutText;

  /// No description provided for @driverSettingsCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get driverSettingsCancel;

  /// No description provided for @vehicleMotorcycle.
  ///
  /// In ar, this message translates to:
  /// **'دراجة نارية'**
  String get vehicleMotorcycle;

  /// No description provided for @vehicleCar.
  ///
  /// In ar, this message translates to:
  /// **'سيارة'**
  String get vehicleCar;

  /// No description provided for @vehicleBicycle.
  ///
  /// In ar, this message translates to:
  /// **'دراجة هوائية'**
  String get vehicleBicycle;

  /// No description provided for @vehicleVan.
  ///
  /// In ar, this message translates to:
  /// **'فان'**
  String get vehicleVan;

  /// No description provided for @vehicleTukTuk.
  ///
  /// In ar, this message translates to:
  /// **'توك توك'**
  String get vehicleTukTuk;

  /// No description provided for @vehicleOnFoot.
  ///
  /// In ar, this message translates to:
  /// **'مشيًا'**
  String get vehicleOnFoot;

  /// No description provided for @pushToggleTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get pushToggleTitle;

  /// No description provided for @pushToggleSub.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الطلبات والتحديثات من سطر'**
  String get pushToggleSub;

  /// No description provided for @pushUnsupported.
  ///
  /// In ar, this message translates to:
  /// **'غير متاحة على هذا الجهاز'**
  String get pushUnsupported;

  /// No description provided for @pushDenied.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات مرفوضة من إعدادات النظام'**
  String get pushDenied;

  /// No description provided for @pushOpenSystem.
  ///
  /// In ar, this message translates to:
  /// **'فتح إعدادات النظام'**
  String get pushOpenSystem;

  /// No description provided for @pushToggleError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديث إعداد الإشعارات'**
  String get pushToggleError;

  /// No description provided for @pushRetry.
  ///
  /// In ar, this message translates to:
  /// **'أعد المحاولة'**
  String get pushRetry;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @notificationsReadAll.
  ///
  /// In ar, this message translates to:
  /// **'قراءة الكل'**
  String get notificationsReadAll;

  /// No description provided for @cartBadgeLabel.
  ///
  /// In ar, this message translates to:
  /// **'السلة، {count} عناصر'**
  String cartBadgeLabel(int count);

  /// No description provided for @voiceModeTitle.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الصوتي التفاعلي'**
  String get voiceModeTitle;

  /// No description provided for @voiceModeTooltip.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الصوتي'**
  String get voiceModeTooltip;

  /// No description provided for @listeningState.
  ///
  /// In ar, this message translates to:
  /// **'أنصت إليك...'**
  String get listeningState;

  /// No description provided for @thinkingState.
  ///
  /// In ar, this message translates to:
  /// **'يفكر في إجابتك...'**
  String get thinkingState;

  /// No description provided for @speakingState.
  ///
  /// In ar, this message translates to:
  /// **'يتحدث الآن...'**
  String get speakingState;

  /// No description provided for @finishVoiceSession.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء المحادثة والمراجعة'**
  String get finishVoiceSession;

  /// No description provided for @voiceConfirmAdd.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد وإضافة للسلة'**
  String get voiceConfirmAdd;

  /// No description provided for @voiceContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة المحادثة'**
  String get voiceContinue;

  /// No description provided for @voiceTapToResume.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للمتابعة'**
  String get voiceTapToResume;

  /// No description provided for @voiceMicDenied.
  ///
  /// In ar, this message translates to:
  /// **'نحتاج إذن الميكروفون لنتحدث معك.'**
  String get voiceMicDenied;

  /// No description provided for @voiceOpenSettings.
  ///
  /// In ar, this message translates to:
  /// **'فتح الإعدادات'**
  String get voiceOpenSettings;

  /// No description provided for @voiceUnsupported.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الصوتي غير متاح على هذا الجهاز'**
  String get voiceUnsupported;

  /// No description provided for @voiceArabicVoiceMissing.
  ///
  /// In ar, this message translates to:
  /// **'لم نجد صوتًا عربيًا على جهازك. ثبّته من إعدادات النظام ثم أعد المحاولة.'**
  String get voiceArabicVoiceMissing;

  /// No description provided for @voiceQuotaMessage.
  ///
  /// In ar, this message translates to:
  /// **'المساعد مشغول حاليًا، جرّب بعد قليل.'**
  String get voiceQuotaMessage;

  /// No description provided for @voiceNetworkMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال، تأكد من الإنترنت وجرّب مرة ثانية.'**
  String get voiceNetworkMessage;

  /// No description provided for @voiceNoItems.
  ///
  /// In ar, this message translates to:
  /// **'ما في أصناف للمراجعة بعد.'**
  String get voiceNoItems;

  /// No description provided for @voiceGreeting.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا، أنا قلم. شو بدك اليوم؟'**
  String get voiceGreeting;

  /// No description provided for @voiceBackToText.
  ///
  /// In ar, this message translates to:
  /// **'العودة للمساعد النصي'**
  String get voiceBackToText;

  /// No description provided for @voiceSummaryTitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الأصناف'**
  String get voiceSummaryTitle;

  /// No description provided for @voiceTotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع'**
  String get voiceTotal;

  /// No description provided for @voiceInStock.
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get voiceInStock;

  /// No description provided for @voiceOutOfStock.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر'**
  String get voiceOutOfStock;

  /// No description provided for @voiceCloseLabel.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get voiceCloseLabel;

  /// No description provided for @voiceAddedToCart.
  ///
  /// In ar, this message translates to:
  /// **'أُضيفت الأصناف إلى السلة'**
  String get voiceAddedToCart;

  /// No description provided for @voiceProposedCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} أصناف مقترحة'**
  String voiceProposedCount(int count);
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
