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

  /// No description provided for @driverLoginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل دخول السائق'**
  String get driverLoginTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً فيك'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك وابدأ باستقبال طلبات التوصيل.'**
  String get loginSubtitle;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumberLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordLabel;

  /// No description provided for @enterPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get enterPasswordHint;

  /// No description provided for @loginButton.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginButton;

  /// No description provided for @driverAppTag.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق السائق'**
  String get driverAppTag;

  /// No description provided for @showPassword.
  ///
  /// In ar, this message translates to:
  /// **'إظهار'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get hidePassword;

  /// No description provided for @phoneValidationError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم الهاتف'**
  String get phoneValidationError;

  /// No description provided for @passwordValidationError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كلمة المرور'**
  String get passwordValidationError;

  /// No description provided for @authInvalidCredentialsError.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف أو كلمة المرور غير صحيحة، راجع البيانات وحاول مرة ثانية.'**
  String get authInvalidCredentialsError;

  /// No description provided for @loggingInStatus.
  ///
  /// In ar, this message translates to:
  /// **'جاري تسجيل الدخول...'**
  String get loggingInStatus;

  /// No description provided for @availableOrdersTitle.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات المتاحة'**
  String get availableOrdersTitle;

  /// No description provided for @noAvailableOrders.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلبات متاحة حالياً'**
  String get noAvailableOrders;

  /// No description provided for @pickupFrom.
  ///
  /// In ar, this message translates to:
  /// **'من:'**
  String get pickupFrom;

  /// No description provided for @deliverTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى:'**
  String get deliverTo;

  /// No description provided for @deliveryFeeLabel.
  ///
  /// In ar, this message translates to:
  /// **'أجر التوصيل'**
  String get deliveryFeeLabel;

  /// No description provided for @acceptOrderButton.
  ///
  /// In ar, this message translates to:
  /// **'قبول الطلب'**
  String get acceptOrderButton;

  /// No description provided for @orderCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'شحنة رقم #'**
  String get orderCodeLabel;

  /// No description provided for @notConnectedStatus.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get notConnectedStatus;

  /// No description provided for @connectDesc.
  ///
  /// In ar, this message translates to:
  /// **'اتصل عشان تشوف طلبات التوصيل المتاحة حواليك.'**
  String get connectDesc;

  /// No description provided for @connectNow.
  ///
  /// In ar, this message translates to:
  /// **'اتصل الآن'**
  String get connectNow;

  /// No description provided for @connectedStatus.
  ///
  /// In ar, this message translates to:
  /// **'أنت متصل'**
  String get connectedStatus;

  /// No description provided for @connectedDesc.
  ///
  /// In ar, this message translates to:
  /// **'جاهز لاستقبال الطلبات'**
  String get connectedDesc;

  /// No description provided for @disconnectBtn.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف الاتصال'**
  String get disconnectBtn;

  /// No description provided for @todaySummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص اليوم'**
  String get todaySummary;

  /// No description provided for @completedOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات مكتملة'**
  String get completedOrders;

  /// No description provided for @activeTask.
  ///
  /// In ar, this message translates to:
  /// **'مهمة نشطة'**
  String get activeTask;

  /// No description provided for @hiddenOrdersTitle.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات المتاحة مخفية'**
  String get hiddenOrdersTitle;

  /// No description provided for @hiddenOrdersDesc.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تحميل قائمة الطلبات وأنت غير متصل.'**
  String get hiddenOrdersDesc;

  /// No description provided for @locationNeedTitle.
  ///
  /// In ar, this message translates to:
  /// **'نحتاج موقعك الحالي'**
  String get locationNeedTitle;

  /// No description provided for @locationNeedDesc.
  ///
  /// In ar, this message translates to:
  /// **'فعل إذن الموقع وحدّث موقعك قبل الاتصال.'**
  String get locationNeedDesc;

  /// No description provided for @updateLocationBtn.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموقع'**
  String get updateLocationBtn;

  /// No description provided for @nearbyOrdersTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات قريبة منك'**
  String get nearbyOrdersTitle;

  /// No description provided for @nearbyOrdersDesc.
  ///
  /// In ar, this message translates to:
  /// **'يتم تحديث القائمة حسب موقعك'**
  String get nearbyOrdersDesc;

  /// No description provided for @viewDetailsBtn.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetailsBtn;

  /// No description provided for @noOrdersNow.
  ///
  /// In ar, this message translates to:
  /// **'ما في طلبات متاحة الآن'**
  String get noOrdersNow;

  /// No description provided for @noOrdersNowDesc.
  ///
  /// In ar, this message translates to:
  /// **'خليك متصل، وبنحدث القائمة أول ما يتوفر طلب قريب.'**
  String get noOrdersNowDesc;

  /// No description provided for @failLoadOrders.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الطلبات'**
  String get failLoadOrders;

  /// No description provided for @failLoadOrdersDesc.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من اتصالك وحاول تحديث القائمة.'**
  String get failLoadOrdersDesc;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get orderDetailsTitle;

  /// No description provided for @availableOrderTag.
  ///
  /// In ar, this message translates to:
  /// **'طلب متاح'**
  String get availableOrderTag;

  /// No description provided for @distanceAway.
  ///
  /// In ar, this message translates to:
  /// **'على بُعد {distance} كم'**
  String distanceAway(Object distance);

  /// No description provided for @pickupZone.
  ///
  /// In ar, this message translates to:
  /// **'منطقة الاستلام'**
  String get pickupZone;

  /// No description provided for @deliveryZone.
  ///
  /// In ar, this message translates to:
  /// **'منطقة التسليم'**
  String get deliveryZone;

  /// No description provided for @orderSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الطلب'**
  String get orderSummary;

  /// No description provided for @orderTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الطلب'**
  String get orderTypeLabel;

  /// No description provided for @itemsCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد العناصر'**
  String get itemsCountLabel;

  /// No description provided for @itemsCountValue.
  ///
  /// In ar, this message translates to:
  /// **'{count} عناصر'**
  String itemsCountValue(Object count);

  /// No description provided for @hideOrderBtn.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء هذا الطلب'**
  String get hideOrderBtn;

  /// No description provided for @acceptOrderBtn.
  ///
  /// In ar, this message translates to:
  /// **'قبول الطلب'**
  String get acceptOrderBtn;

  /// No description provided for @detailsHiddenNotice.
  ///
  /// In ar, this message translates to:
  /// **'تظهر معلومات مختصرة فقط قبل القبول. بيانات الاتصال والعنوان الدقيق والمرفقات تبقى مخفية.'**
  String get detailsHiddenNotice;

  /// No description provided for @detailsHiddenAlert.
  ///
  /// In ar, this message translates to:
  /// **'العنوان التفصيلي وبيانات العميل تظهر بعد قبول الطلب فقط.'**
  String get detailsHiddenAlert;

  /// No description provided for @acceptingOrderTitle.
  ///
  /// In ar, this message translates to:
  /// **'جاري قبول الطلب'**
  String get acceptingOrderTitle;

  /// No description provided for @acceptingOrderDesc.
  ///
  /// In ar, this message translates to:
  /// **'لحظة واحدة، بنأكد إن الطلب ما زال متاحًا.'**
  String get acceptingOrderDesc;

  /// No description provided for @orderAcceptedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الطلب'**
  String get orderAcceptedTitle;

  /// No description provided for @orderAcceptedDesc.
  ///
  /// In ar, this message translates to:
  /// **'صار الطلب مهمتك. راجع تفاصيل المهمة قبل التحرك.'**
  String get orderAcceptedDesc;

  /// No description provided for @viewActiveTaskBtn.
  ///
  /// In ar, this message translates to:
  /// **'عرض المهمة النشطة'**
  String get viewActiveTaskBtn;

  /// No description provided for @alreadyTakenTitle.
  ///
  /// In ar, this message translates to:
  /// **'سبقك سائق آخر'**
  String get alreadyTakenTitle;

  /// No description provided for @alreadyTakenDesc.
  ///
  /// In ar, this message translates to:
  /// **'الطلب تم قبوله من سائق آخر. ارجع للقائمة واختار طلبًا ثانيًا.'**
  String get alreadyTakenDesc;

  /// No description provided for @busyStatusTitle.
  ///
  /// In ar, this message translates to:
  /// **'عندك مهمة نشطة'**
  String get busyStatusTitle;

  /// No description provided for @busyStatusDesc.
  ///
  /// In ar, this message translates to:
  /// **'أنهِ مهمتك الحالية قبل قبول طلب جديد.'**
  String get busyStatusDesc;

  /// No description provided for @cashLimitTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصلت حد التحصيل النقدي'**
  String get cashLimitTitle;

  /// No description provided for @cashLimitDesc.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر قبول الطلب بسبب حد التحصيل. راجع رصيدك أو تواصل مع المكتبة.'**
  String get cashLimitDesc;

  /// No description provided for @unexpectedErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرنا نقبل الطلب'**
  String get unexpectedErrorTitle;

  /// No description provided for @unexpectedErrorDesc.
  ///
  /// In ar, this message translates to:
  /// **'صار خطأ غير متوقع. حاول مرة ثانية أو ارجع للقائمة.'**
  String get unexpectedErrorDesc;

  /// No description provided for @backToOrdersBtn.
  ///
  /// In ar, this message translates to:
  /// **'العودة للطلبات'**
  String get backToOrdersBtn;

  /// No description provided for @drAcceptActiveTaskBody.
  ///
  /// In ar, this message translates to:
  /// **'خلّص مهمتك الحالية قبل ما تقبل طلب جديد'**
  String get drAcceptActiveTaskBody;

  /// No description provided for @drAcceptActiveTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'عندك مهمة نشطة'**
  String get drAcceptActiveTaskTitle;

  /// No description provided for @drAcceptBackToOrders.
  ///
  /// In ar, this message translates to:
  /// **'العودة للطلبات'**
  String get drAcceptBackToOrders;

  /// No description provided for @drAcceptCashLimitBody.
  ///
  /// In ar, this message translates to:
  /// **'سلّم المبالغ المحصّلة للمكتب حتى تكمل استلام الطلبات'**
  String get drAcceptCashLimitBody;

  /// No description provided for @drAcceptCashLimitTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصلت حد التحصيل النقدي'**
  String get drAcceptCashLimitTitle;

  /// No description provided for @drAcceptFailedBody.
  ///
  /// In ar, this message translates to:
  /// **'صار خطأ غير متوقع. حاول مرة ثانية'**
  String get drAcceptFailedBody;

  /// No description provided for @drAcceptFailedTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرنا نقبل الطلب'**
  String get drAcceptFailedTitle;

  /// No description provided for @drAcceptGoOnline.
  ///
  /// In ar, this message translates to:
  /// **'اتصل الآن'**
  String get drAcceptGoOnline;

  /// No description provided for @drAcceptOfflineBody.
  ///
  /// In ar, this message translates to:
  /// **'اتصل أول حتى تقدر تقبل الطلبات'**
  String get drAcceptOfflineBody;

  /// No description provided for @drAcceptOfflineTitle.
  ///
  /// In ar, this message translates to:
  /// **'لازم تكون متصل'**
  String get drAcceptOfflineTitle;

  /// No description provided for @drAcceptTakenBody.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول هذا الطلب من سائق ثاني. جرّب طلب ثاني'**
  String get drAcceptTakenBody;

  /// No description provided for @drAcceptTakenTitle.
  ///
  /// In ar, this message translates to:
  /// **'سبقك سائق آخر'**
  String get drAcceptTakenTitle;

  /// No description provided for @drAcceptViewCash.
  ///
  /// In ar, this message translates to:
  /// **'عرض الرصيد النقدي'**
  String get drAcceptViewCash;

  /// No description provided for @drAcceptedBody.
  ///
  /// In ar, this message translates to:
  /// **'الطلب صار مهمتك الحالية. توجّه لنقطة الاستلام'**
  String get drAcceptedBody;

  /// No description provided for @drAcceptedGoTask.
  ///
  /// In ar, this message translates to:
  /// **'عرض المهمة الحالية'**
  String get drAcceptedGoTask;

  /// No description provided for @drAcceptedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الطلب'**
  String get drAcceptedTitle;

  /// No description provided for @drAcceptingBody.
  ///
  /// In ar, this message translates to:
  /// **'لحظات…'**
  String get drAcceptingBody;

  /// No description provided for @drAcceptingTitle.
  ///
  /// In ar, this message translates to:
  /// **'جاري قبول الطلب'**
  String get drAcceptingTitle;

  /// No description provided for @drAddPhoto.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get drAddPhoto;

  /// No description provided for @drAmountToCollect.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المطلوب تحصيله'**
  String get drAmountToCollect;

  /// No description provided for @drCallAction.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get drCallAction;

  /// No description provided for @drCashEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما في حركات نقدية'**
  String get drCashEmptyTitle;

  /// No description provided for @drCashErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الرصيد'**
  String get drCashErrorTitle;

  /// No description provided for @drCashLimit.
  ///
  /// In ar, this message translates to:
  /// **'حد التحصيل'**
  String get drCashLimit;

  /// No description provided for @drCashNearLimit.
  ///
  /// In ar, this message translates to:
  /// **'قربت من حد التحصيل. سلّم المبالغ للمكتب'**
  String get drCashNearLimit;

  /// No description provided for @drCashOnHand.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد النقدي'**
  String get drCashOnHand;

  /// No description provided for @drCashTab.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد النقدي'**
  String get drCashTab;

  /// No description provided for @drCommonBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get drCommonBack;

  /// No description provided for @drDeliveryCashReceived.
  ///
  /// In ar, this message translates to:
  /// **'استلمت المبلغ كاملاً'**
  String get drDeliveryCashReceived;

  /// No description provided for @drDeliveryCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز من الزبون'**
  String get drDeliveryCodeHint;

  /// No description provided for @drDeliveryCodeInvalid.
  ///
  /// In ar, this message translates to:
  /// **'رمز التسليم غير صحيح'**
  String get drDeliveryCodeInvalid;

  /// No description provided for @drDeliveryCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'رمز التسليم'**
  String get drDeliveryCodeLabel;

  /// No description provided for @drDeliveryCollectCash.
  ///
  /// In ar, this message translates to:
  /// **'حصّل المبلغ من الزبون'**
  String get drDeliveryCollectCash;

  /// No description provided for @drDeliveryConfirmButton.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التسليم'**
  String get drDeliveryConfirmButton;

  /// No description provided for @drDeliveryConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تسليم الطلب'**
  String get drDeliveryConfirmTitle;

  /// No description provided for @drDeliveryNeedCash.
  ///
  /// In ar, this message translates to:
  /// **'أكّد استلام المبلغ أول'**
  String get drDeliveryNeedCash;

  /// No description provided for @drDeliveryNoCashNote.
  ///
  /// In ar, this message translates to:
  /// **'هذا الطلب مدفوع مسبقاً، لا تحصّل أي مبلغ'**
  String get drDeliveryNoCashNote;

  /// No description provided for @drDeliverySuccessCollected.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المحصّل'**
  String get drDeliverySuccessCollected;

  /// No description provided for @drDeliverySuccessHistory.
  ///
  /// In ar, this message translates to:
  /// **'عرض سجل المهام'**
  String get drDeliverySuccessHistory;

  /// No description provided for @drDeliverySuccessHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get drDeliverySuccessHome;

  /// No description provided for @drDeliverySuccessOrder.
  ///
  /// In ar, this message translates to:
  /// **'الطلب'**
  String get drDeliverySuccessOrder;

  /// No description provided for @drDeliverySuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم بنجاح'**
  String get drDeliverySuccessTitle;

  /// No description provided for @drDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get drDetailsTitle;

  /// No description provided for @drEarningsEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أرباحك رح تظهر هنا بعد أول مهمة'**
  String get drEarningsEmptyBody;

  /// No description provided for @drEarningsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد أرباح بعد'**
  String get drEarningsEmptyTitle;

  /// No description provided for @drEarningsErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الأرباح'**
  String get drEarningsErrorTitle;

  /// No description provided for @drEarningsTab.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get drEarningsTab;

  /// No description provided for @drEarningsThisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get drEarningsThisWeek;

  /// No description provided for @drEarningsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح والرصيد'**
  String get drEarningsTitle;

  /// No description provided for @drFailureBannerTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التسليم'**
  String get drFailureBannerTitle;

  /// No description provided for @drFailureNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات إضافية (اختياري)'**
  String get drFailureNotesHint;

  /// No description provided for @drFailurePickReason.
  ///
  /// In ar, this message translates to:
  /// **'اختر السبب أول'**
  String get drFailurePickReason;

  /// No description provided for @drFailureReasonNotHome.
  ///
  /// In ar, this message translates to:
  /// **'ما في حدا بالعنوان'**
  String get drFailureReasonNotHome;

  /// No description provided for @drFailureReasonOther.
  ///
  /// In ar, this message translates to:
  /// **'سبب آخر'**
  String get drFailureReasonOther;

  /// No description provided for @drFailureReasonRefused.
  ///
  /// In ar, this message translates to:
  /// **'الزبون رفض الاستلام'**
  String get drFailureReasonRefused;

  /// No description provided for @drFailureReasonUnreachable.
  ///
  /// In ar, this message translates to:
  /// **'الزبون لا يرد'**
  String get drFailureReasonUnreachable;

  /// No description provided for @drFailureReasonWrongAddress.
  ///
  /// In ar, this message translates to:
  /// **'الموقع غير صحيح'**
  String get drFailureReasonWrongAddress;

  /// No description provided for @drFailureRecordedBody.
  ///
  /// In ar, this message translates to:
  /// **'سجّلنا السبب وسنتابع الطلب مع الإدارة'**
  String get drFailureRecordedBody;

  /// No description provided for @drFailureRecordedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل تعذّر التسليم'**
  String get drFailureRecordedTitle;

  /// No description provided for @drFailureSubmit.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل تعذّر التسليم'**
  String get drFailureSubmit;

  /// No description provided for @drFailureTitle.
  ///
  /// In ar, this message translates to:
  /// **'شو سبب تعذّر التسليم؟'**
  String get drFailureTitle;

  /// No description provided for @drFailureViewTask.
  ///
  /// In ar, this message translates to:
  /// **'عرض المهمة'**
  String get drFailureViewTask;

  /// No description provided for @drHistoryDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل مهمة سابقة'**
  String get drHistoryDetailsTitle;

  /// No description provided for @drHistoryEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'مهامك المنجزة رح تظهر هنا'**
  String get drHistoryEmptyBody;

  /// No description provided for @drHistoryEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك مهام سابقة'**
  String get drHistoryEmptyTitle;

  /// No description provided for @drHistoryErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل السجل'**
  String get drHistoryErrorTitle;

  /// No description provided for @drHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل المهام'**
  String get drHistoryTitle;

  /// No description provided for @drHomeCash.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد النقدي'**
  String get drHomeCash;

  /// No description provided for @drHomeEarnings.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get drHomeEarnings;

  /// No description provided for @drHomeGoOffline.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف الاتصال'**
  String get drHomeGoOffline;

  /// No description provided for @drHomeGoOnline.
  ///
  /// In ar, this message translates to:
  /// **'اتصل الآن'**
  String get drHomeGoOnline;

  /// No description provided for @drHomeNearbyOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلبات قريبة منك'**
  String get drHomeNearbyOrders;

  /// No description provided for @drHomeOffline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get drHomeOffline;

  /// No description provided for @drHomeOfflineBody.
  ///
  /// In ar, this message translates to:
  /// **'اتصل لتبدأ باستلام طلبات التوصيل القريبة منك'**
  String get drHomeOfflineBody;

  /// No description provided for @drHomeOnline.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get drHomeOnline;

  /// No description provided for @drHomeOnlineBody.
  ///
  /// In ar, this message translates to:
  /// **'جاهز لاستلام الطلبات'**
  String get drHomeOnlineBody;

  /// No description provided for @drHomeSeeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get drHomeSeeAll;

  /// No description provided for @drHomeTodaySummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص اليوم'**
  String get drHomeTodaySummary;

  /// No description provided for @drLocationGrant.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالوصول للموقع'**
  String get drLocationGrant;

  /// No description provided for @drLocationOpenSettings.
  ///
  /// In ar, this message translates to:
  /// **'فتح الإعدادات'**
  String get drLocationOpenSettings;

  /// No description provided for @drLocationRequiredBody.
  ///
  /// In ar, this message translates to:
  /// **'فعّل إذن الموقع حتى نوصلك بالطلبات القريبة'**
  String get drLocationRequiredBody;

  /// No description provided for @drLocationRequiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'نحتاج موقعك'**
  String get drLocationRequiredTitle;

  /// No description provided for @drLocationServiceOffBody.
  ///
  /// In ar, this message translates to:
  /// **'شغّل الـ GPS من إعدادات الجهاز'**
  String get drLocationServiceOffBody;

  /// No description provided for @drLocationServiceOffTitle.
  ///
  /// In ar, this message translates to:
  /// **'خدمة الموقع مغلقة'**
  String get drLocationServiceOffTitle;

  /// No description provided for @drLoginPasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get drLoginPasswordHint;

  /// No description provided for @drLoginPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get drLoginPasswordLabel;

  /// No description provided for @drLoginPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'05XXXXXXXX'**
  String get drLoginPhoneHint;

  /// No description provided for @drLoginPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get drLoginPhoneLabel;

  /// No description provided for @drLoginRequiredField.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get drLoginRequiredField;

  /// No description provided for @drLoginTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً فيك'**
  String get drLoginTitle;

  /// No description provided for @drMapArrived.
  ///
  /// In ar, this message translates to:
  /// **'وصلت'**
  String get drMapArrived;

  /// No description provided for @drMapDestination.
  ///
  /// In ar, this message translates to:
  /// **'الوجهة'**
  String get drMapDestination;

  /// No description provided for @drMapNoCoords.
  ///
  /// In ar, this message translates to:
  /// **'إحداثيات الوجهة غير متوفرة'**
  String get drMapNoCoords;

  /// No description provided for @drMapOpenExternal.
  ///
  /// In ar, this message translates to:
  /// **'فتح في الخرائط'**
  String get drMapOpenExternal;

  /// No description provided for @drMapTitle.
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get drMapTitle;

  /// No description provided for @drNavEarnings.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get drNavEarnings;

  /// No description provided for @drNavHistory.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get drNavHistory;

  /// No description provided for @drNavHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get drNavHome;

  /// No description provided for @drNavOrders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get drNavOrders;

  /// No description provided for @drNavTask.
  ///
  /// In ar, this message translates to:
  /// **'المهمة'**
  String get drNavTask;

  /// No description provided for @drNextArrivedBody.
  ///
  /// In ar, this message translates to:
  /// **'أكّد وصولك حتى يتم إشعار الزبون'**
  String get drNextArrivedBody;

  /// No description provided for @drNextArrivedButton.
  ///
  /// In ar, this message translates to:
  /// **'وصلت'**
  String get drNextArrivedButton;

  /// No description provided for @drNextArrivedTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصلت للزبون؟'**
  String get drNextArrivedTitle;

  /// No description provided for @drNextDeliveredBody.
  ///
  /// In ar, this message translates to:
  /// **'أكّد التسليم بعد ما تسلّم الطلب'**
  String get drNextDeliveredBody;

  /// No description provided for @drNextDeliveredButton.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التسليم'**
  String get drNextDeliveredButton;

  /// No description provided for @drNextDeliveredTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلّم الطلب للزبون'**
  String get drNextDeliveredTitle;

  /// No description provided for @drNextGenericButton.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة'**
  String get drNextGenericButton;

  /// No description provided for @drNextOnTheWayBody.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التوصيل وسنوجّهك للزبون'**
  String get drNextOnTheWayBody;

  /// No description provided for @drNextOnTheWayButton.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التوصيل'**
  String get drNextOnTheWayButton;

  /// No description provided for @drNextOnTheWayTitle.
  ///
  /// In ar, this message translates to:
  /// **'جاهز تنطلق؟'**
  String get drNextOnTheWayTitle;

  /// No description provided for @drNextPickedUpBody.
  ///
  /// In ar, this message translates to:
  /// **'توجّه لنقطة الاستلام وأكّد استلام الطلب'**
  String get drNextPickedUpBody;

  /// No description provided for @drNextPickedUpButton.
  ///
  /// In ar, this message translates to:
  /// **'استلمت الطلب'**
  String get drNextPickedUpButton;

  /// No description provided for @drNextPickedUpTitle.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للاستلام؟'**
  String get drNextPickedUpTitle;

  /// No description provided for @drNotificationsEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'رح تظهر هنا إشعارات المهام'**
  String get drNotificationsEmptyBody;

  /// No description provided for @drNotificationsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get drNotificationsEmptyTitle;

  /// No description provided for @drNotificationsErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الإشعارات'**
  String get drNotificationsErrorTitle;

  /// No description provided for @drNotificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get drNotificationsTitle;

  /// No description provided for @drOpenMap.
  ///
  /// In ar, this message translates to:
  /// **'فتح الخريطة'**
  String get drOpenMap;

  /// No description provided for @drOrderAccept.
  ///
  /// In ar, this message translates to:
  /// **'قبول الطلب'**
  String get drOrderAccept;

  /// No description provided for @drOrderIgnore.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get drOrderIgnore;

  /// No description provided for @drOrderNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get drOrderNotes;

  /// No description provided for @drOrderTotal.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الطلب'**
  String get drOrderTotal;

  /// No description provided for @drOrdersEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'رح نعلمك أول ما يتوفر طلب جديد قربك'**
  String get drOrdersEmptyBody;

  /// No description provided for @drOrdersEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما في طلبات متاحة الآن'**
  String get drOrdersEmptyTitle;

  /// No description provided for @drOrdersErrorBody.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من الاتصال وحاول مرة ثانية'**
  String get drOrdersErrorBody;

  /// No description provided for @drOrdersErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الطلبات'**
  String get drOrdersErrorTitle;

  /// No description provided for @drOrdersNearby.
  ///
  /// In ar, this message translates to:
  /// **'طلبات قريبة منك'**
  String get drOrdersNearby;

  /// No description provided for @drOrdersOfflineBody.
  ///
  /// In ar, this message translates to:
  /// **'اتصل حتى تشوف الطلبات المتاحة'**
  String get drOrdersOfflineBody;

  /// No description provided for @drOrdersOfflineTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل'**
  String get drOrdersOfflineTitle;

  /// No description provided for @drOrdersViewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get drOrdersViewDetails;

  /// No description provided for @drPhotoAdded.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة الصورة'**
  String get drPhotoAdded;

  /// No description provided for @drPhotoOptional.
  ///
  /// In ar, this message translates to:
  /// **'صورة إثبات (اختياري)'**
  String get drPhotoOptional;

  /// No description provided for @drPickupConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'تأكد إن الطلب كامل قبل التأكيد'**
  String get drPickupConfirmBody;

  /// No description provided for @drPickupConfirmButton.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الاستلام'**
  String get drPickupConfirmButton;

  /// No description provided for @drPickupConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'استلمت الطلب من المكتبة؟'**
  String get drPickupConfirmTitle;

  /// No description provided for @drPickupConfirming.
  ///
  /// In ar, this message translates to:
  /// **'جاري تأكيد الاستلام…'**
  String get drPickupConfirming;

  /// No description provided for @drPickupNotYet.
  ///
  /// In ar, this message translates to:
  /// **'ليس بعد'**
  String get drPickupNotYet;

  /// No description provided for @drProfileLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get drProfileLogout;

  /// No description provided for @drProfileLogoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج؟'**
  String get drProfileLogoutConfirm;

  /// No description provided for @drProfilePhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get drProfilePhone;

  /// No description provided for @drProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get drProfileTitle;

  /// No description provided for @drProfileVehicle.
  ///
  /// In ar, this message translates to:
  /// **'المركبة'**
  String get drProfileVehicle;

  /// No description provided for @drReportFailure.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر التسليم'**
  String get drReportFailure;

  /// No description provided for @drRetryDelivery.
  ///
  /// In ar, this message translates to:
  /// **'إعادة محاولة التوصيل'**
  String get drRetryDelivery;

  /// No description provided for @drStepAccepted.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get drStepAccepted;

  /// No description provided for @drStepArrived.
  ///
  /// In ar, this message translates to:
  /// **'وصلت'**
  String get drStepArrived;

  /// No description provided for @drStepDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تسليم'**
  String get drStepDelivered;

  /// No description provided for @drStepOnTheWay.
  ///
  /// In ar, this message translates to:
  /// **'بالطريق'**
  String get drStepOnTheWay;

  /// No description provided for @drStepPickedUp.
  ///
  /// In ar, this message translates to:
  /// **'استلام'**
  String get drStepPickedUp;

  /// No description provided for @drStopDropoff.
  ///
  /// In ar, this message translates to:
  /// **'التسليم'**
  String get drStopDropoff;

  /// No description provided for @drStopPickup.
  ///
  /// In ar, this message translates to:
  /// **'الاستلام'**
  String get drStopPickup;

  /// No description provided for @drTaskDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المهمة'**
  String get drTaskDetailsTitle;

  /// No description provided for @drTaskEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'اقبل طلب من قائمة الطلبات لتبدأ'**
  String get drTaskEmptyBody;

  /// No description provided for @drTaskEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك مهمة حالية'**
  String get drTaskEmptyTitle;

  /// No description provided for @drTaskErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل المهمة'**
  String get drTaskErrorTitle;

  /// No description provided for @drTaskGoOrders.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح الطلبات'**
  String get drTaskGoOrders;

  /// No description provided for @drTaskOfflineTitle.
  ///
  /// In ar, this message translates to:
  /// **'انقطع الاتصال'**
  String get drTaskOfflineTitle;

  /// No description provided for @drTaskRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث المهمة'**
  String get drTaskRefresh;

  /// No description provided for @drTaskStaleBody.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث حالة المهمة. حدّث الصفحة لتشوف آخر حالة'**
  String get drTaskStaleBody;

  /// No description provided for @drTaskStaleTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحالة تغيّرت'**
  String get drTaskStaleTitle;

  /// No description provided for @drTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'المهمة الحالية'**
  String get drTaskTitle;

  /// No description provided for @drYourEarning.
  ///
  /// In ar, this message translates to:
  /// **'ربحك من الطلب'**
  String get drYourEarning;

  /// No description provided for @drKmUnit.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get drKmUnit;

  /// No description provided for @drOrderItems.
  ///
  /// In ar, this message translates to:
  /// **'محتويات الطلب'**
  String get drOrderItems;

  /// No description provided for @drPhotoRequired.
  ///
  /// In ar, this message translates to:
  /// **'صورة إثبات (مطلوبة)'**
  String get drPhotoRequired;

  /// No description provided for @drOrdersUnit.
  ///
  /// In ar, this message translates to:
  /// **'طلب'**
  String get drOrdersUnit;

  /// No description provided for @drCashCollected.
  ///
  /// In ar, this message translates to:
  /// **'نقد محصّل'**
  String get drCashCollected;

  /// No description provided for @drCashRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي قبل الحد'**
  String get drCashRemaining;

  /// No description provided for @drCashUnsettled.
  ///
  /// In ar, this message translates to:
  /// **'طلبات غير مسوّاة'**
  String get drCashUnsettled;

  /// No description provided for @drCashSettlement.
  ///
  /// In ar, this message translates to:
  /// **'تسوية نقدية'**
  String get drCashSettlement;

  /// No description provided for @drCollectAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ للتحصيل'**
  String get drCollectAmount;

  /// No description provided for @drCollectFromCustomerHint.
  ///
  /// In ar, this message translates to:
  /// **'يُحصّل من العميل'**
  String get drCollectFromCustomerHint;

  /// No description provided for @drYourFeeHint.
  ///
  /// In ar, this message translates to:
  /// **'أجرتك لهذه المهمة'**
  String get drYourFeeHint;

  /// No description provided for @drCurrentTaskTitle.
  ///
  /// In ar, this message translates to:
  /// **'المهمة الحالية'**
  String get drCurrentTaskTitle;

  /// No description provided for @drHomeEarningsHint.
  ///
  /// In ar, this message translates to:
  /// **'تابع أرباحك ورصيدك النقدي'**
  String get drHomeEarningsHint;

  /// No description provided for @drHomeOrdersHint.
  ///
  /// In ar, this message translates to:
  /// **'شوف الطلبات القريبة منك'**
  String get drHomeOrdersHint;

  /// No description provided for @drHomeTaskHint.
  ///
  /// In ar, this message translates to:
  /// **'كمّل مهمتك الحالية'**
  String get drHomeTaskHint;

  /// No description provided for @drLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get drLogout;

  /// No description provided for @drLogoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج؟'**
  String get drLogoutConfirm;

  /// No description provided for @drNavProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get drNavProfile;

  /// No description provided for @drStepA.
  ///
  /// In ar, this message translates to:
  /// **'أ'**
  String get drStepA;

  /// No description provided for @drStepB.
  ///
  /// In ar, this message translates to:
  /// **'ب'**
  String get drStepB;

  /// No description provided for @drViewCash.
  ///
  /// In ar, this message translates to:
  /// **'عرض الرصيد النقدي'**
  String get drViewCash;

  /// No description provided for @drFailureNotice.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من محاولة الاتصال بالزبون قبل تسجيل تعذّر التسليم.'**
  String get drFailureNotice;
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
