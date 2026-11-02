// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سطر';

  @override
  String get appTitle => 'مكتبة سطر الذكية';

  @override
  String get errorGeneral => 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNetwork => 'خطأ في الاتصال بالشبكة. يرجى التحقق من اتصالك.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get splashTagline => 'كل احتياجاتك، بسطر واحد';

  @override
  String get splashContinue => 'متابعة';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'يلا نبدأ';

  @override
  String onboardingPageCounter(int current, int total) {
    return '$current من $total';
  }

  @override
  String get onboarding1Title => 'كل اللي بتحتاجه، بسطر واحد';

  @override
  String get onboarding1Body =>
      'كتب، قرطاسية، ألعاب وهدايا… كل إشي بتحتاجه بمكان واحد.';

  @override
  String get onboarding2Title => 'ملفاتك جاهزة للطباعة';

  @override
  String get onboarding2Body =>
      'ارفع ملفك، اختر مواصفات الطباعة، وإحنا بنجهّزلك طلبك.';

  @override
  String get onboarding3Title => 'اطلبها بسهولة، وخلي الباقي علينا';

  @override
  String get onboarding3Body =>
      'اطلب بالكتابة أو بالصوت، وسطر بيجهزلك السلة ويوصلها لبابك.';

  @override
  String get roleWelcomeTitle => 'أهلاً فيك بسطر!';

  @override
  String get roleWelcomeSubtitle => 'اختر كيف بدك تكمل';

  @override
  String get roleCustomer => 'أنا زبون';

  @override
  String get roleDriver => 'أنا سائق';

  @override
  String get roleTermsNote =>
      'بالمتابعة أنت توافق على شروط الاستخدام وسياسة الخصوصية';

  @override
  String get driverLoginTitle => 'تسجيل دخول السائق';

  @override
  String get welcomeBack => 'أهلاً فيك';

  @override
  String get loginSubtitle => 'سجّل دخولك وابدأ باستقبال طلبات التوصيل.';

  @override
  String get phoneNumberLabel => 'رقم الهاتف';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get enterPasswordHint => 'أدخل كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get driverAppTag => 'تطبيق السائق';

  @override
  String get showPassword => 'إظهار';

  @override
  String get hidePassword => 'إخفاء';

  @override
  String get phoneValidationError => 'يرجى إدخال رقم الهاتف';

  @override
  String get passwordValidationError => 'يرجى إدخال كلمة المرور';

  @override
  String get authInvalidCredentialsError =>
      'رقم الهاتف أو كلمة المرور غير صحيحة، راجع البيانات وحاول مرة ثانية.';

  @override
  String get loggingInStatus => 'جاري تسجيل الدخول...';

  @override
  String get availableOrdersTitle => 'الطلبات المتاحة';

  @override
  String get noAvailableOrders => 'لا يوجد طلبات متاحة حالياً';

  @override
  String get pickupFrom => 'من:';

  @override
  String get deliverTo => 'إلى:';

  @override
  String get deliveryFeeLabel => 'أجر التوصيل';

  @override
  String get acceptOrderButton => 'قبول الطلب';

  @override
  String get orderCodeLabel => 'شحنة رقم #';

  @override
  String get notConnectedStatus => 'غير متصل';

  @override
  String get connectDesc => 'اتصل عشان تشوف طلبات التوصيل المتاحة حواليك.';

  @override
  String get connectNow => 'اتصل الآن';

  @override
  String get connectedStatus => 'أنت متصل';

  @override
  String get connectedDesc => 'جاهز لاستقبال الطلبات';

  @override
  String get disconnectBtn => 'إيقاف الاتصال';

  @override
  String get todaySummary => 'ملخص اليوم';

  @override
  String get completedOrders => 'طلبات مكتملة';

  @override
  String get activeTask => 'مهمة نشطة';

  @override
  String get hiddenOrdersTitle => 'الطلبات المتاحة مخفية';

  @override
  String get hiddenOrdersDesc => 'لا يمكن تحميل قائمة الطلبات وأنت غير متصل.';

  @override
  String get locationNeedTitle => 'نحتاج موقعك الحالي';

  @override
  String get locationNeedDesc => 'فعل إذن الموقع وحدّث موقعك قبل الاتصال.';

  @override
  String get updateLocationBtn => 'تحديث الموقع';

  @override
  String get nearbyOrdersTitle => 'طلبات قريبة منك';

  @override
  String get nearbyOrdersDesc => 'يتم تحديث القائمة حسب موقعك';

  @override
  String get viewDetailsBtn => 'عرض التفاصيل';

  @override
  String get noOrdersNow => 'ما في طلبات متاحة الآن';

  @override
  String get noOrdersNowDesc =>
      'خليك متصل، وبنحدث القائمة أول ما يتوفر طلب قريب.';

  @override
  String get failLoadOrders => 'تعذّر تحميل الطلبات';

  @override
  String get failLoadOrdersDesc => 'تأكد من اتصالك وحاول تحديث القائمة.';

  @override
  String get orderDetailsTitle => 'تفاصيل الطلب';

  @override
  String get availableOrderTag => 'طلب متاح';

  @override
  String distanceAway(Object distance) {
    return 'على بُعد $distance كم';
  }

  @override
  String get pickupZone => 'منطقة الاستلام';

  @override
  String get deliveryZone => 'منطقة التسليم';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get orderTypeLabel => 'نوع الطلب';

  @override
  String get itemsCountLabel => 'عدد العناصر';

  @override
  String itemsCountValue(Object count) {
    return '$count عناصر';
  }

  @override
  String get hideOrderBtn => 'إخفاء هذا الطلب';

  @override
  String get acceptOrderBtn => 'قبول الطلب';

  @override
  String get detailsHiddenNotice =>
      'تظهر معلومات مختصرة فقط قبل القبول. بيانات الاتصال والعنوان الدقيق والمرفقات تبقى مخفية.';

  @override
  String get detailsHiddenAlert =>
      'العنوان التفصيلي وبيانات العميل تظهر بعد قبول الطلب فقط.';

  @override
  String get acceptingOrderTitle => 'جاري قبول الطلب';

  @override
  String get acceptingOrderDesc => 'لحظة واحدة، بنأكد إن الطلب ما زال متاحًا.';

  @override
  String get orderAcceptedTitle => 'تم قبول الطلب';

  @override
  String get orderAcceptedDesc =>
      'صار الطلب مهمتك. راجع تفاصيل المهمة قبل التحرك.';

  @override
  String get viewActiveTaskBtn => 'عرض المهمة النشطة';

  @override
  String get alreadyTakenTitle => 'سبقك سائق آخر';

  @override
  String get alreadyTakenDesc =>
      'الطلب تم قبوله من سائق آخر. ارجع للقائمة واختار طلبًا ثانيًا.';

  @override
  String get busyStatusTitle => 'عندك مهمة نشطة';

  @override
  String get busyStatusDesc => 'أنهِ مهمتك الحالية قبل قبول طلب جديد.';

  @override
  String get cashLimitTitle => 'وصلت حد التحصيل النقدي';

  @override
  String get cashLimitDesc =>
      'تعذّر قبول الطلب بسبب حد التحصيل. راجع رصيدك أو تواصل مع المكتبة.';

  @override
  String get unexpectedErrorTitle => 'ما قدرنا نقبل الطلب';

  @override
  String get unexpectedErrorDesc =>
      'صار خطأ غير متوقع. حاول مرة ثانية أو ارجع للقائمة.';

  @override
  String get backToOrdersBtn => 'العودة للطلبات';

  @override
  String get drAcceptActiveTaskBody =>
      'خلّص مهمتك الحالية قبل ما تقبل طلب جديد';

  @override
  String get drAcceptActiveTaskTitle => 'عندك مهمة نشطة';

  @override
  String get drAcceptBackToOrders => 'العودة للطلبات';

  @override
  String get drAcceptCashLimitBody =>
      'سلّم المبالغ المحصّلة للمكتب حتى تكمل استلام الطلبات';

  @override
  String get drAcceptCashLimitTitle => 'وصلت حد التحصيل النقدي';

  @override
  String get drAcceptFailedBody => 'صار خطأ غير متوقع. حاول مرة ثانية';

  @override
  String get drAcceptFailedTitle => 'ما قدرنا نقبل الطلب';

  @override
  String get drAcceptGoOnline => 'اتصل الآن';

  @override
  String get drAcceptOfflineBody => 'اتصل أول حتى تقدر تقبل الطلبات';

  @override
  String get drAcceptOfflineTitle => 'لازم تكون متصل';

  @override
  String get drAcceptTakenBody =>
      'تم قبول هذا الطلب من سائق ثاني. جرّب طلب ثاني';

  @override
  String get drAcceptTakenTitle => 'سبقك سائق آخر';

  @override
  String get drAcceptViewCash => 'عرض الرصيد النقدي';

  @override
  String get drAcceptedBody => 'الطلب صار مهمتك الحالية. توجّه لنقطة الاستلام';

  @override
  String get drAcceptedGoTask => 'عرض المهمة الحالية';

  @override
  String get drAcceptedTitle => 'تم قبول الطلب';

  @override
  String get drAcceptingBody => 'لحظات…';

  @override
  String get drAcceptingTitle => 'جاري قبول الطلب';

  @override
  String get drAddPhoto => 'إضافة صورة';

  @override
  String get drAmountToCollect => 'المبلغ المطلوب تحصيله';

  @override
  String get drCallAction => 'اتصال';

  @override
  String get drCashEmptyTitle => 'ما في حركات نقدية';

  @override
  String get drCashErrorTitle => 'تعذّر تحميل الرصيد';

  @override
  String get drCashLimit => 'حد التحصيل';

  @override
  String get drCashNearLimit => 'قربت من حد التحصيل. سلّم المبالغ للمكتب';

  @override
  String get drCashOnHand => 'الرصيد النقدي';

  @override
  String get drCashTab => 'الرصيد النقدي';

  @override
  String get drCommonBack => 'رجوع';

  @override
  String get drDeliveryCashReceived => 'استلمت المبلغ كاملاً';

  @override
  String get drDeliveryCodeHint => 'أدخل الرمز من الزبون';

  @override
  String get drDeliveryCodeInvalid => 'رمز التسليم غير صحيح';

  @override
  String get drDeliveryCodeLabel => 'رمز التسليم';

  @override
  String get drDeliveryCollectCash => 'حصّل المبلغ من الزبون';

  @override
  String get drDeliveryConfirmButton => 'تأكيد التسليم';

  @override
  String get drDeliveryConfirmTitle => 'تأكيد تسليم الطلب';

  @override
  String get drDeliveryNeedCash => 'أكّد استلام المبلغ أول';

  @override
  String get drDeliveryNoCashNote => 'هذا الطلب مدفوع مسبقاً، لا تحصّل أي مبلغ';

  @override
  String get drDeliverySuccessCollected => 'المبلغ المحصّل';

  @override
  String get drDeliverySuccessHistory => 'عرض سجل المهام';

  @override
  String get drDeliverySuccessHome => 'العودة للرئيسية';

  @override
  String get drDeliverySuccessOrder => 'الطلب';

  @override
  String get drDeliverySuccessTitle => 'تم التسليم بنجاح';

  @override
  String get drDetailsTitle => 'تفاصيل الطلب';

  @override
  String get drEarningsEmptyBody => 'أرباحك رح تظهر هنا بعد أول مهمة';

  @override
  String get drEarningsEmptyTitle => 'لا يوجد أرباح بعد';

  @override
  String get drEarningsErrorTitle => 'تعذّر تحميل الأرباح';

  @override
  String get drEarningsTab => 'الأرباح';

  @override
  String get drEarningsThisWeek => 'هذا الأسبوع';

  @override
  String get drEarningsTitle => 'الأرباح والرصيد';

  @override
  String get drFailureBannerTitle => 'تعذّر التسليم';

  @override
  String get drFailureNotesHint => 'ملاحظات إضافية (اختياري)';

  @override
  String get drFailurePickReason => 'اختر السبب أول';

  @override
  String get drFailureReasonNotHome => 'ما في حدا بالعنوان';

  @override
  String get drFailureReasonOther => 'سبب آخر';

  @override
  String get drFailureReasonRefused => 'الزبون رفض الاستلام';

  @override
  String get drFailureReasonUnreachable => 'الزبون لا يرد';

  @override
  String get drFailureReasonWrongAddress => 'الموقع غير صحيح';

  @override
  String get drFailureRecordedBody => 'سجّلنا السبب وسنتابع الطلب مع الإدارة';

  @override
  String get drFailureRecordedTitle => 'تم تسجيل تعذّر التسليم';

  @override
  String get drFailureSubmit => 'تسجيل تعذّر التسليم';

  @override
  String get drFailureTitle => 'شو سبب تعذّر التسليم؟';

  @override
  String get drFailureViewTask => 'عرض المهمة';

  @override
  String get drHistoryDetailsTitle => 'تفاصيل مهمة سابقة';

  @override
  String get drHistoryEmptyBody => 'مهامك المنجزة رح تظهر هنا';

  @override
  String get drHistoryEmptyTitle => 'ما عندك مهام سابقة';

  @override
  String get drHistoryErrorTitle => 'تعذّر تحميل السجل';

  @override
  String get drHistoryTitle => 'سجل المهام';

  @override
  String get drHomeCash => 'الرصيد النقدي';

  @override
  String get drHomeEarnings => 'الأرباح';

  @override
  String get drHomeGoOffline => 'إيقاف الاتصال';

  @override
  String get drHomeGoOnline => 'اتصل الآن';

  @override
  String get drHomeNearbyOrders => 'طلبات قريبة منك';

  @override
  String get drHomeOffline => 'غير متصل';

  @override
  String get drHomeOfflineBody =>
      'اتصل لتبدأ باستلام طلبات التوصيل القريبة منك';

  @override
  String get drHomeOnline => 'متصل';

  @override
  String get drHomeOnlineBody => 'جاهز لاستلام الطلبات';

  @override
  String get drHomeSeeAll => 'عرض الكل';

  @override
  String get drHomeTodaySummary => 'ملخص اليوم';

  @override
  String get drLocationGrant => 'السماح بالوصول للموقع';

  @override
  String get drLocationOpenSettings => 'فتح الإعدادات';

  @override
  String get drLocationRequiredBody =>
      'فعّل إذن الموقع حتى نوصلك بالطلبات القريبة';

  @override
  String get drLocationRequiredTitle => 'نحتاج موقعك';

  @override
  String get drLocationServiceOffBody => 'شغّل الـ GPS من إعدادات الجهاز';

  @override
  String get drLocationServiceOffTitle => 'خدمة الموقع مغلقة';

  @override
  String get drLoginPasswordHint => 'أدخل كلمة المرور';

  @override
  String get drLoginPasswordLabel => 'كلمة المرور';

  @override
  String get drLoginPhoneHint => '05XXXXXXXX';

  @override
  String get drLoginPhoneLabel => 'رقم الجوال';

  @override
  String get drLoginRequiredField => 'هذا الحقل مطلوب';

  @override
  String get drLoginTitle => 'أهلاً فيك';

  @override
  String get drMapArrived => 'وصلت';

  @override
  String get drMapDestination => 'الوجهة';

  @override
  String get drMapNoCoords => 'إحداثيات الوجهة غير متوفرة';

  @override
  String get drMapOpenExternal => 'فتح في الخرائط';

  @override
  String get drMapTitle => 'في الطريق';

  @override
  String get drNavEarnings => 'الأرباح';

  @override
  String get drNavHistory => 'السجل';

  @override
  String get drNavHome => 'الرئيسية';

  @override
  String get drNavOrders => 'الطلبات';

  @override
  String get drNavTask => 'المهمة';

  @override
  String get drNextArrivedBody => 'أكّد وصولك حتى يتم إشعار الزبون';

  @override
  String get drNextArrivedButton => 'وصلت';

  @override
  String get drNextArrivedTitle => 'وصلت للزبون؟';

  @override
  String get drNextDeliveredBody => 'أكّد التسليم بعد ما تسلّم الطلب';

  @override
  String get drNextDeliveredButton => 'تأكيد التسليم';

  @override
  String get drNextDeliveredTitle => 'سلّم الطلب للزبون';

  @override
  String get drNextGenericButton => 'المتابعة';

  @override
  String get drNextOnTheWayBody => 'ابدأ التوصيل وسنوجّهك للزبون';

  @override
  String get drNextOnTheWayButton => 'ابدأ التوصيل';

  @override
  String get drNextOnTheWayTitle => 'جاهز تنطلق؟';

  @override
  String get drNextPickedUpBody => 'توجّه لنقطة الاستلام وأكّد استلام الطلب';

  @override
  String get drNextPickedUpButton => 'استلمت الطلب';

  @override
  String get drNextPickedUpTitle => 'جاهز للاستلام؟';

  @override
  String get drNotificationsEmptyBody => 'رح تظهر هنا إشعارات المهام';

  @override
  String get drNotificationsEmptyTitle => 'لا توجد إشعارات';

  @override
  String get drNotificationsErrorTitle => 'تعذّر تحميل الإشعارات';

  @override
  String get drNotificationsTitle => 'الإشعارات';

  @override
  String get drOpenMap => 'فتح الخريطة';

  @override
  String get drOrderAccept => 'قبول الطلب';

  @override
  String get drOrderIgnore => 'تجاهل';

  @override
  String get drOrderNotes => 'ملاحظات';

  @override
  String get drOrderTotal => 'قيمة الطلب';

  @override
  String get drOrdersEmptyBody => 'رح نعلمك أول ما يتوفر طلب جديد قربك';

  @override
  String get drOrdersEmptyTitle => 'ما في طلبات متاحة الآن';

  @override
  String get drOrdersErrorBody => 'تأكد من الاتصال وحاول مرة ثانية';

  @override
  String get drOrdersErrorTitle => 'تعذّر تحميل الطلبات';

  @override
  String get drOrdersNearby => 'طلبات قريبة منك';

  @override
  String get drOrdersOfflineBody => 'اتصل حتى تشوف الطلبات المتاحة';

  @override
  String get drOrdersOfflineTitle => 'أنت غير متصل';

  @override
  String get drOrdersViewDetails => 'عرض التفاصيل';

  @override
  String get drPhotoAdded => 'تمت إضافة الصورة';

  @override
  String get drPhotoOptional => 'صورة إثبات (اختياري)';

  @override
  String get drPickupConfirmBody => 'تأكد إن الطلب كامل قبل التأكيد';

  @override
  String get drPickupConfirmButton => 'تأكيد الاستلام';

  @override
  String get drPickupConfirmTitle => 'استلمت الطلب من المكتبة؟';

  @override
  String get drPickupConfirming => 'جاري تأكيد الاستلام…';

  @override
  String get drPickupNotYet => 'ليس بعد';

  @override
  String get drProfileLogout => 'تسجيل الخروج';

  @override
  String get drProfileLogoutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get drProfilePhone => 'رقم الجوال';

  @override
  String get drProfileTitle => 'حسابي';

  @override
  String get drProfileVehicle => 'المركبة';

  @override
  String get drReportFailure => 'تعذّر التسليم';

  @override
  String get drRetryDelivery => 'إعادة محاولة التوصيل';

  @override
  String get drStepAccepted => 'مقبول';

  @override
  String get drStepArrived => 'وصلت';

  @override
  String get drStepDelivered => 'تسليم';

  @override
  String get drStepOnTheWay => 'بالطريق';

  @override
  String get drStepPickedUp => 'استلام';

  @override
  String get drStopDropoff => 'التسليم';

  @override
  String get drStopPickup => 'الاستلام';

  @override
  String get drTaskDetailsTitle => 'تفاصيل المهمة';

  @override
  String get drTaskEmptyBody => 'اقبل طلب من قائمة الطلبات لتبدأ';

  @override
  String get drTaskEmptyTitle => 'ما عندك مهمة حالية';

  @override
  String get drTaskErrorTitle => 'تعذّر تحميل المهمة';

  @override
  String get drTaskGoOrders => 'تصفّح الطلبات';

  @override
  String get drTaskOfflineTitle => 'انقطع الاتصال';

  @override
  String get drTaskRefresh => 'تحديث المهمة';

  @override
  String get drTaskStaleBody =>
      'تم تحديث حالة المهمة. حدّث الصفحة لتشوف آخر حالة';

  @override
  String get drTaskStaleTitle => 'الحالة تغيّرت';

  @override
  String get drTaskTitle => 'المهمة الحالية';

  @override
  String get drYourEarning => 'ربحك من الطلب';

  @override
  String get drKmUnit => 'كم';

  @override
  String get drOrderItems => 'محتويات الطلب';

  @override
  String get drPhotoRequired => 'صورة إثبات (مطلوبة)';

  @override
  String get drOrdersUnit => 'طلب';

  @override
  String get drCashCollected => 'نقد محصّل';

  @override
  String get drCashRemaining => 'المتبقي قبل الحد';

  @override
  String get drCashUnsettled => 'طلبات غير مسوّاة';

  @override
  String get drCashSettlement => 'تسوية نقدية';

  @override
  String get drCollectAmount => 'المبلغ للتحصيل';

  @override
  String get drCollectFromCustomerHint => 'يُحصّل من العميل';

  @override
  String get drYourFeeHint => 'أجرتك لهذه المهمة';

  @override
  String get drCurrentTaskTitle => 'المهمة الحالية';

  @override
  String get drHomeEarningsHint => 'تابع أرباحك ورصيدك النقدي';

  @override
  String get drHomeOrdersHint => 'شوف الطلبات القريبة منك';

  @override
  String get drHomeTaskHint => 'كمّل مهمتك الحالية';

  @override
  String get drLogout => 'تسجيل الخروج';

  @override
  String get drLogoutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String get drNavProfile => 'حسابي';

  @override
  String get drStepA => 'أ';

  @override
  String get drStepB => 'ب';

  @override
  String get drViewCash => 'عرض الرصيد النقدي';

  @override
  String get drFailureNotice =>
      'تأكد من محاولة الاتصال بالزبون قبل تسجيل تعذّر التسليم.';
}
