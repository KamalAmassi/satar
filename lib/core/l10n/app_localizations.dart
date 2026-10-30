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
