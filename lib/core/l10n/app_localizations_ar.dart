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
  String get aiAlternatives => 'بدائل قريبة بسعر مشابه';

  @override
  String get aiStepListening => 'عم بسمعك…';

  @override
  String get aiStepUnderstanding => 'عم بفهم طلبك…';

  @override
  String get aiStepSearching => 'عم بدور على المنتجات…';

  @override
  String get aiStop => 'إيقاف';

  @override
  String get aiCancel => 'إلغاء';

  @override
  String get aiTooShort => 'التسجيل قصير، جرب مرة ثانية';

  @override
  String get aiMicError => 'تعذر بدء التسجيل';

  @override
  String get aiMicPermission => 'لازم تسمح للتطبيق باستخدام المايك';

  @override
  String get aiOpenSettings => 'الإعدادات';

  @override
  String get aiNotUnderstood => 'ما فهمت طلبك، جرب مرة ثانية أو اكتبه';

  @override
  String get aiQuota => 'وصلنا لحد الاستخدام مؤقتاً، جرب بعد شوي أو اكتب طلبك';

  @override
  String get aiServiceUnavailable => 'المساعد مش متاح هلأ، جرب بعد شوي';

  @override
  String get aiRetry => 'إعادة المحاولة';

  @override
  String get aiClose => 'إغلاق';

  @override
  String get aiUnderstood => 'ما فهمته';

  @override
  String get aiEditRequest => 'عدّل الطلب';

  @override
  String aiItemsCount(int count) {
    return '$count منتجات';
  }

  @override
  String get aiAvailable => 'متوفر';

  @override
  String get aiOpenPrinting => 'افتح الطباعة';

  @override
  String get aiFinalPricesNote => 'الأسعار النهائية تظهر عند مراجعة الطلب';

  @override
  String get aiTitle => 'مساعد سطر';

  @override
  String get aiHeroTitle => 'احكيلي شو بدك';

  @override
  String get aiHeroSubtitle =>
      'اكتب طلبك أو احكيلنا بصوتك، وأنا برتّبلك اقتراح قبل ما تضيفه للسلة.';

  @override
  String get aiInputHint =>
      'مثلاً: بدي دفترين أزرق وثلاث أقلام سوداء وطباعة A4';

  @override
  String get aiVoiceStart => 'اضغط واحكي طلبك';

  @override
  String get aiVoiceListening => 'عم بسمعك… اضغط للإيقاف';

  @override
  String get aiPrepare => 'جهّز اقتراح';

  @override
  String get aiEmptyInput => 'اكتب طلبك أو احكيه أول';

  @override
  String get aiNothingFound => 'ما قدرت أفهم طلبك، جرب تكتبه بشكل ثاني';

  @override
  String get aiSpeechUnavailable =>
      'التعرف على الصوت مش متاح، تأكد من إذن المايك أو اكتب طلبك';

  @override
  String get aiSheetTitle => 'اقتراحي إلك';

  @override
  String get aiSheetSubtitle => 'عدّل الكميات وبعدين أضفهم للسلة';

  @override
  String aiAddToCart(int count) {
    return 'أضف للسلة ($count)';
  }

  @override
  String get aiUnavailable => 'غير متوفر';

  @override
  String aiLimitedStock(int available, int requested) {
    return 'المتوفر $available فقط من $requested';
  }

  @override
  String get aiUseAlternative => 'استبدل';

  @override
  String aiNotFound(String query) {
    return 'ما لقينا «$query»';
  }

  @override
  String get aiNotFoundHint => 'جرب تكتبه بشكل ثاني أو تصفح الأقسام';

  @override
  String aiAddedToCart(int count) {
    return 'انضافت $count منتجات للسلة';
  }

  @override
  String get errorNoConnection => 'ما في اتصال بالإنترنت';

  @override
  String get errorTimeout => 'انتهت مهلة الاتصال. حاول مرة أخرى.';

  @override
  String get errorSessionExpired => 'انتهت جلستك. سجّل الدخول مرة أخرى.';

  @override
  String get errorRateLimited =>
      'طلبات كثيرة خلال وقت قصير. انتظر قليلًا ثم حاول.';

  @override
  String errorRateLimitedSeconds(int seconds) {
    return 'طلبات كثيرة خلال وقت قصير. حاول بعد $seconds ثانية.';
  }

  @override
  String get errorAppNotConfigured =>
      'التطبيق غير مهيأ للاتصال بالخادم حاليًا.';

  @override
  String get errorOutOfZone =>
      'هذا العنوان خارج منطقة التوصيل. اختر عنوانًا آخر.';

  @override
  String get errorOutOfStock => 'الكمية المطلوبة غير متوفرة حاليًا.';

  @override
  String errorOutOfStockAvailable(int count) {
    return 'الكمية غير متوفرة. المتاح الآن: $count.';
  }

  @override
  String get errorStateChanged =>
      'تغيّرت حالة الطلب. حدّثنا البيانات، راجعها ثم تابع.';

  @override
  String get remove => 'حذف';

  @override
  String get reject => 'ارفض';

  @override
  String get quoteExpiredBody => 'حدّث السعر والتوفر قبل تأكيد الطلب.';

  @override
  String get quoteUsedBody => 'راجع طلباتك قبل محاولة إنشاء طلب جديد.';

  @override
  String get dismiss => 'إغلاق';

  @override
  String get increase => 'زيادة';

  @override
  String get decrease => 'إنقاص';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get printingServicesTitle => 'خدمات الطباعة';

  @override
  String get printingHeroEyebrow => 'من الملف للورق';

  @override
  String get printingHeroTitle => 'ملفاتك علينا!';

  @override
  String get printingHeroBody =>
      'ارفع ملفك، اختار المواصفات، وخلي الطباعة علينا.';

  @override
  String printingServiceBw(String paper) {
    return 'أبيض وأسود $paper';
  }

  @override
  String printingServiceColor(String paper) {
    return 'طباعة ملونة $paper';
  }

  @override
  String perPrintedSide(String price) {
    return '$price / وجه مطبوع';
  }

  @override
  String perCopy(String price) {
    return '$price / نسخة';
  }

  @override
  String get printingFinalPriceNote =>
      'راجع عرض السعر النهائي قبل تأكيد الطلب.';

  @override
  String get printingStart => 'ابدأ بطلب طباعة';

  @override
  String get printSpecsTitle => 'مواصفات الملفات';

  @override
  String get printSpecsHint =>
      'اختار مواصفات كل ملف، وراجع السعر قبل تأكيد طلبك.';

  @override
  String get whatToPrint => 'شو بدك تطبع؟';

  @override
  String get supportedFiles => 'الملفات المدعومة';

  @override
  String get supportedFileTypes => 'PDF، JPG، PNG، WebP';

  @override
  String get maxFileSize => 'الحد الأقصى للحجم';

  @override
  String maxPerFile(String size) {
    return '$size لكل ملف';
  }

  @override
  String get maxFiles => 'عدد الملفات المسموح';

  @override
  String get tapToChooseFile => 'اضغط لاختيار ملف';

  @override
  String get addAnotherFile => 'أضف ملف ثاني بمواصفات مختلفة';

  @override
  String fileLimitBody(int max) {
    return 'وصلت لحد الملفات ($max). احذف ملفًا قبل إضافة ملف طباعة جديد.';
  }

  @override
  String get uploadTooLargeTitle => 'الملف أكبر من الحجم المسموح';

  @override
  String uploadTooLargeBody(String size) {
    return 'حجم كل ملف لازم يكون $size أو أقل. صغّر الملف وحاول مرة ثانية.';
  }

  @override
  String get uploadUnsupportedTitle => 'نوع الملف غير مدعوم';

  @override
  String get uploadUnsupportedBody =>
      'ارفع ملف بصيغة PDF أو JPG أو PNG أو WebP.';

  @override
  String get uploadEmptyBody => 'الملف فارغ. اختر ملفًا آخر.';

  @override
  String get chooseAnotherFile => 'اختيار ملف ثاني';

  @override
  String uploadingPercent(int percent) {
    return 'جاري الرفع… $percent%';
  }

  @override
  String get uploadFailed => 'تعذّر رفع الملف.';

  @override
  String pagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحة',
      many: '$count صفحة',
      few: '$count صفحات',
      two: 'صفحتان',
      one: 'صفحة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get paperSize => 'حجم الورق';

  @override
  String get printColor => 'اللون';

  @override
  String get printColorBw => 'أبيض وأسود';

  @override
  String get printColorColor => 'ملون';

  @override
  String get printSides => 'الطباعة';

  @override
  String get printSidesSingle => 'وجه واحد';

  @override
  String get printSidesDouble => 'وجهان';

  @override
  String get binding => 'التجليد';

  @override
  String get pageRange => 'نطاق الصفحات';

  @override
  String get pageRangeAllHint => 'الكل';

  @override
  String pageRangeHelper(int pages) {
    return 'اتركه فارغًا لطباعة الكل، أو اكتب نطاقًا مثل 1-5 وافصل بين الأجزاء بفاصلة. عدد صفحات الملف: $pages.';
  }

  @override
  String get pageRangeInvalid =>
      'راجع نطاق الصفحات: اكتب نطاقًا مثل 1-5 وافصل بين الأجزاء بفاصلة، ضمن عدد صفحات الملف.';

  @override
  String get copies => 'عدد النسخ';

  @override
  String pagesTimesCopies(int pages, int copies) {
    return 'الصفحات: $pages · النسخ: $copies';
  }

  @override
  String get fileNotes => 'ملاحظات لهذا الملف';

  @override
  String get fileNotesHint => 'أي تفاصيل إضافية؟';

  @override
  String get estimateForFile => 'التقدير لهذا الملف';

  @override
  String get estimateLabel => 'التقدير';

  @override
  String get reviewPrice => 'مراجعة السعر';

  @override
  String get cartTitle => 'سلّتك';

  @override
  String get cartEmptyTitle => 'سلّتك فاضية';

  @override
  String get cartEmptyBody => 'أضف منتجات أو ملفات طباعة للمتابعة.';

  @override
  String get startShopping => 'ابدأ التسوق';

  @override
  String get productsSection => 'المنتجات';

  @override
  String get printingSection => 'الطباعة';

  @override
  String productNumber(int id) {
    return 'منتج رقم $id';
  }

  @override
  String get pricedByLibrary => 'تسعّره المكتبة';

  @override
  String get productUnavailable => 'هذا المنتج غير متوفر حاليًا.';

  @override
  String onlyAvailable(int count) {
    return 'المتوفر حاليًا $count فقط. عدّل الكمية.';
  }

  @override
  String chooseOption(String label) {
    return 'اختر $label';
  }

  @override
  String get illustrativePrice => 'سعر توضيحي';

  @override
  String get printingIllustrative => 'الطباعة (تقدير)';

  @override
  String get notesForLibrary => 'ملاحظات للمكتبة';

  @override
  String get notesForLibraryHint => 'أي تفاصيل بتحب تضيفها؟';

  @override
  String get ifOutOfStock => 'لو المنتج خلص';

  @override
  String get deliveryByAddress => 'تُحسب حسب العنوان';

  @override
  String get totalBeforeDelivery => 'الإجمالي قبل التوصيل';

  @override
  String get finalPriceAtReview =>
      'الأسعار هنا للعرض. السعر النهائي يظهر في مراجعة الطلب.';

  @override
  String get continueToDelivery => 'تابع للتوصيل';

  @override
  String get waitForUploads => 'انتظر اكتمال رفع الملفات قبل المتابعة.';

  @override
  String get fixFailedUploads =>
      'بعض الملفات لم تُرفع. أعد المحاولة أو احذفها.';

  @override
  String get uploadInterrupted =>
      'انقطع رفع هذا الملف لأن التطبيق أُغلق قبل اكتماله. اختر الملف نفسه مرة أخرى أو احذفه.';

  @override
  String get uploadInterruptedShort => 'انقطع الرفع — اختر الملف مرة أخرى.';

  @override
  String get chooseFileAgain => 'اختيار الملف';

  @override
  String get fixInterruptedUploads =>
      'انقطع رفع بعض ملفات الطباعة. افتح مواصفات الطباعة واختر الملفات مرة أخرى أو احذفها.';

  @override
  String get total => 'الإجمالي';

  @override
  String get discount => 'الخصم';

  @override
  String get payment => 'الدفع';

  @override
  String get orderCode => 'رقم الطلب';

  @override
  String get orderStatus => 'حالة الطلب';

  @override
  String get viewOrder => 'عرض الطلب';

  @override
  String get viewMyOrders => 'عرض طلباتي';

  @override
  String get deliveryTitle => 'عنوان التوصيل';

  @override
  String get whereToDeliver => 'وين نوصّلك؟';

  @override
  String get addAddress => 'أضف عنوان';

  @override
  String get noAddresses => 'لا توجد عناوين محفوظة. أضف عنوانًا للمتابعة.';

  @override
  String addressNumber(int id) {
    return 'عنوان $id';
  }

  @override
  String get insideDeliveryArea => 'داخل منطقة التوصيل';

  @override
  String get outsideDeliveryArea => 'خارج منطقة التوصيل';

  @override
  String get recipientNameOptional => 'اسم المستلم (اختياري)';

  @override
  String get recipientNameHint => 'الاسم';

  @override
  String get recipientPhoneOptional => 'رقم الهاتف (اختياري)';

  @override
  String get phoneInvalid => 'رقم الهاتف غير صحيح.';

  @override
  String get deliveryNotes => 'ملاحظات التوصيل';

  @override
  String get deliveryNotesHint => 'علامة مميزة أو تفاصيل الوصول';

  @override
  String get deliveryFeeAtReview =>
      'رسوم التوصيل والإجمالي النهائي تظهر في مراجعة الطلب.';

  @override
  String get continueToPayment => 'متابعة للدفع';

  @override
  String get paymentMethodTitle => 'طريقة الدفع';

  @override
  String get howToPay => 'كيف بتحب تدفع؟';

  @override
  String get payCashOnDelivery => 'نقدًا عند التسليم';

  @override
  String get payBankTransfer => 'تحويل بنكي أو محفظة';

  @override
  String get paymentMethodNote =>
      'يظهر مبلغ التحصيل والتفاصيل قبل تأكيد الطلب.';

  @override
  String get transferAfterOrderNote =>
      'ارفع إشعار التحويل بعد أن تؤكد المكتبة سعر الطلب.';

  @override
  String get reviewOrder => 'مراجعة الطلب';

  @override
  String get reviewBeforeConfirm => 'راجع طلبك قبل التأكيد';

  @override
  String get orderType => 'نوع الطلب';

  @override
  String get orderTypeProducts => 'منتجات';

  @override
  String get orderTypePrinting => 'طباعة';

  @override
  String get orderTypeMixed => 'منتجات وطباعة';

  @override
  String quoteValidFor(int minutes, String seconds) {
    return 'التسعيرة صالحة لمدة $minutes:$seconds';
  }

  @override
  String get libraryConfirmsNote =>
      'بعد التأكيد تراجع المكتبة طلبك وترسل لك عرض السعر النهائي للموافقة.';

  @override
  String get confirmOrder => 'تأكيد الطلب';

  @override
  String get quoteLoadingTitle => 'جاري حساب السعر';

  @override
  String get quoteLoadingBody => 'بنطلب السعر والتوفر الحاليين.';

  @override
  String get quoteFailedTitle => 'تعذّر حساب السعر';

  @override
  String get quoteFailedBody =>
      'راجع الاتصال والعنوان وخيارات الطلب، ثم حاول مجددًا.';

  @override
  String get quoteNotReady =>
      'أكمل السلة والعنوان وطريقة الدفع وانتظر رفع الملفات قبل طلب السعر.';

  @override
  String get fixHighlightedItems =>
      'صحّح العناصر المحددة في السلة ثم حاول مجددًا.';

  @override
  String get backToCart => 'العودة للسلة';

  @override
  String get changeAddress => 'تغيير العنوان';

  @override
  String get quoteExpiredTitle => 'انتهت صلاحية التسعيرة';

  @override
  String get quoteStaleTitle => 'تغيّر طلبك';

  @override
  String get quoteStaleBody =>
      'عدّلت السلة أو التوصيل بعد التسعيرة. اطلب سعرًا جديدًا وراجعه.';

  @override
  String get quoteUsedTitle => 'تم استخدام هذه التسعيرة';

  @override
  String get refreshQuote => 'تحديث التسعيرة';

  @override
  String get priceChangedBody => 'تغيّر السعر. راجع السعر الجديد قبل المتابعة.';

  @override
  String get paymentMethodChangedBody =>
      'غيّرت طريقة الدفع، فأصدرنا تسعيرة جديدة لها. المبلغ لم يتغيّر.';

  @override
  String get previousPrice => 'السعر السابق';

  @override
  String get currentPrice => 'السعر الحالي';

  @override
  String get acceptNewPrice => 'أوافق على السعر الجديد';

  @override
  String get submittingTitle => 'جاري إنشاء طلبك';

  @override
  String get submittingBody => 'بنثبت تفاصيل الطلب والسعر.';

  @override
  String get uncertainTitle => 'ما قدرنا نتأكد من النتيجة';

  @override
  String get uncertainBody =>
      'ربما أُنشئ طلبك. تحقق مرة أخرى أو راجع طلباتك قبل إعادة المحاولة حتى لا يتكرر الطلب.';

  @override
  String get checkAgain => 'تحقق مرة أخرى';

  @override
  String get checkMyOrders => 'تحقق من طلباتي';

  @override
  String get orderCreatedTitle => 'تم إنشاء الطلب';

  @override
  String get orderCreatedBody => 'تابع حالة الطلب لمعرفة الخطوة التالية.';

  @override
  String get orderAwaitingPaymentTitle => 'تم إنشاء طلبك';

  @override
  String get orderCreatedTransferBody =>
      'ستراجع المكتبة الطلب، ثم حوّل المبلغ وارفع الإشعار عند فتح الدفع.';

  @override
  String get viewTransferDetails => 'عرض بيانات التحويل';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get transferTitle => 'الدفع بالتحويل';

  @override
  String get transferHeadline => 'حوّل المبلغ وارفع الإشعار';

  @override
  String get transferSubtitle => 'أكمل التحويل خارج سطر ثم ارفع إشعاره.';

  @override
  String get correctionTitle => 'تصحيح إشعار الدفع';

  @override
  String get correctionSubtitle =>
      'طلبت المكتبة تصحيحًا. ارفع إشعارًا جديدًا حسب الملاحظة.';

  @override
  String get libraryNote => 'ملاحظة المكتبة';

  @override
  String get previousReceipt => 'الإشعار السابق';

  @override
  String get amountDue => 'المبلغ المطلوب';

  @override
  String get recipientAccount => 'الحساب المستلم';

  @override
  String get noTransferAccounts =>
      'لا توجد بيانات حساب حاليًا. تواصل مع المكتبة.';

  @override
  String get wallet => 'محفظة';

  @override
  String get bank => 'بنك';

  @override
  String get uploadReceipt => 'ارفع إشعار التحويل';

  @override
  String receiptTypes(String size) {
    return 'صورة أو PDF · حتى $size';
  }

  @override
  String get chooseReceipt => 'اختيار الإشعار';

  @override
  String get replaceReceipt => 'استبدال';

  @override
  String get receiptPreview => 'معاينة الإشعار';

  @override
  String get submitReceipt => 'إرسال إشعار الدفع';

  @override
  String get resubmitReceipt => 'إعادة إرسال الإشعار';

  @override
  String get receiptNotApproval =>
      'بعد الإرسال: قيد مراجعة المكتبة — لا يعني اعتماد الدفع.';

  @override
  String get receiptSentTitle => 'تم إرسال الإشعار';

  @override
  String get receiptUnderReviewTitle => 'الإشعار قيد المراجعة';

  @override
  String get receiptUnderReviewBody =>
      'تراجع المكتبة الإشعار قبل اعتماد الدفع. لا يمكن إرسال إشعار آخر أثناء المراجعة.';

  @override
  String get refreshStatus => 'تحديث الحالة';

  @override
  String get paymentStateChanged =>
      'تغيّرت حالة الدفع. حدّثنا الشاشة بآخر حالة.';

  @override
  String get transferNotOpenTitle => 'الدفع لم يُفتح بعد';

  @override
  String get transferNotOpenBody =>
      'تراجع المكتبة طلبك. يُفتح رفع الإشعار عندما يصبح الطلب بانتظار الدفع.';

  @override
  String get transferNeedsOfferBody =>
      'أرسلت المكتبة عرض السعر. وافق عليه أولًا ليُفتح الدفع.';

  @override
  String get reviewLibraryOffer => 'مراجعة عرض المكتبة';

  @override
  String get paymentConfirmedTitle => 'تم اعتماد الدفع';

  @override
  String get paymentConfirmedBody =>
      'اعتمدت المكتبة الدفع ويتابع الطلب خطواته.';

  @override
  String get notTransferOrderTitle => 'هذا الطلب ليس بالتحويل';

  @override
  String get notTransferOrderBody => 'لا يحتاج هذا الطلب إشعار تحويل.';

  @override
  String get libraryOfferTitle => 'عرض المكتبة';

  @override
  String offerValidFor(String time) {
    return 'العرض صالح لمدة $time';
  }

  @override
  String get reviewPriceAndSubstitutes => 'راجع السعر والبدائل';

  @override
  String get offerIntro => 'المكتبة راجعت طلبك وجهّزت العرض التالي.';

  @override
  String itemUnavailable(String name) {
    return '$name غير متوفر';
  }

  @override
  String qtyTimesUnit(int qty, String unit) {
    return '$qty × $unit';
  }

  @override
  String suggestedSubstitute(String name) {
    return 'البديل المقترح: $name';
  }

  @override
  String get samePrice => 'نفس السعر';

  @override
  String priceHigherBy(String amount) {
    return 'أغلى بـ $amount';
  }

  @override
  String priceLowerBy(String amount) {
    return 'أرخص بـ $amount';
  }

  @override
  String get acceptSubstitutes =>
      'أوافق على التعديلات المقترحة (البنود غير المتوفرة والبدائل)';

  @override
  String get productsAndPrinting => 'المنتجات والطباعة';

  @override
  String get approvePrice => 'وافق على السعر';

  @override
  String get rejectOfferTitle => 'رفض العرض؟';

  @override
  String get rejectOfferBody =>
      'رفض العرض يلغي الطلب. إذا كنت دفعت مبلغًا فتواصل مع المكتبة؛ الاسترداد ليس تلقائيًا.';

  @override
  String get offerNotReadyTitle => 'المكتبة تراجع طلبك';

  @override
  String get offerNotReadyBody => 'سيظهر عرض السعر هنا عندما تجهّزه المكتبة.';

  @override
  String get refreshOffer => 'تحديث العرض';

  @override
  String get offerExpiredTitle => 'انتهت صلاحية العرض';

  @override
  String get offerExpiredBody =>
      'ما بتقدر توافق على هذا العرض. تواصل مع المكتبة أو حدّث العرض.';

  @override
  String get offerChangedTitle => 'تم تحديث العرض';

  @override
  String get offerChangedBody => 'حدّث العرض وراجع البنود قبل الموافقة.';

  @override
  String get offerApprovedTitle => 'تمت الموافقة على العرض';

  @override
  String get offerApprovedBody => 'يتابع طلبك خطواته. تابع حالته من طلباتك.';

  @override
  String get offerRejectedTitle => 'تم رفض العرض';

  @override
  String get offerRejectedBody =>
      'أُلغي الطلب. للاستفسار عن أي مبلغ مدفوع تواصل مع المكتبة.';

  @override
  String get vibrationSettingTitle => 'الاهتزاز';

  @override
  String get vibrationSettingSub => 'اهتزاز خفيف عند اللمس وتأكيد الإجراءات';

  @override
  String get stepperIncrease => 'زيادة الكمية';

  @override
  String get stepperDecrease => 'إنقاص الكمية';

  @override
  String voiceRecordingPill(String time) {
    return 'يسجّل · $time';
  }

  @override
  String voiceRecordingSemantics(String time) {
    return 'جارٍ التسجيل، مضى $time. نحن نستمع إليك.';
  }

  @override
  String productImageSemantics(String name) {
    return 'صورة $name';
  }

  @override
  String get productImageOpen => 'فتح صورة المنتج بملء الشاشة';

  @override
  String get imageViewerClose => 'إغلاق';

  @override
  String imageViewerPage(int current, int total) {
    return 'الصورة $current من $total';
  }

  @override
  String get celebrationOrderPlaced => 'تم بنجاح! أُرسل طلبك إلى المكتبة.';

  @override
  String get celebrationDelivered => 'تم التسليم بنجاح. أحسنت!';

  @override
  String get celebrationOrderDelivered => 'تم تسليم طلبك.';

  @override
  String get driverLocationLive => 'موقع السائق مباشر';

  @override
  String driverLocationStale(int minutes) {
    return 'آخر موقع للسائق قبل $minutes دقيقة. قد يكون في منطقة ضعيفة التغطية.';
  }

  @override
  String get driverLocationNone => 'بانتظار أول موقع للسائق.';

  @override
  String driverEtaShort(int minutes) {
    return 'نحو $minutes دقيقة';
  }

  @override
  String get driverMarkerSemantics => 'موقع السائق على الخريطة';

  @override
  String get driverOrderUnavailableTitle => 'هذا الطلب لم يعد متاحًا';

  @override
  String get driverOrderUnavailableText =>
      'ربما أُلغي أو تغيّر. سنعرض لك طلبات أخرى قريبة.';

  @override
  String get driverAvailableOrders => 'الطلبات المتاحة';

  @override
  String get driverAcceptOfflineTitle => 'أنت غير متصل';

  @override
  String get driverAcceptOfflineText => 'فعّل الاتصال لتتمكن من قبول الطلبات.';

  @override
  String get driverGoOnline => 'اتصل الآن';

  @override
  String get driverAcceptInvalidTitle => 'لا يمكن قبول هذا الطلب الآن';

  @override
  String get driverAcceptInvalidText =>
      'قد تكون لديك مهمة جارية، أو تغيّرت حالة الطلب.';

  @override
  String get driverSessionExpiredTitle => 'انتهت جلستك';

  @override
  String get driverSessionExpiredText => 'سجّل الدخول من جديد للمتابعة.';

  @override
  String get driverSignIn => 'تسجيل الدخول';

  @override
  String get driverNetworkTitle => 'تعذّر الاتصال';

  @override
  String get commonRetry => 'أعد المحاولة';

  @override
  String get commonOk => 'حسنًا';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get otpTitle => 'تأكيد رقمك';

  @override
  String get otpHeadline => 'أدخل رمز التحقق';

  @override
  String otpSubtitle(String phone) {
    return 'أرسلنا رمزًا برسالة نصية إلى $phone.';
  }

  @override
  String otpCodeSemantics(int length) {
    return 'رمز التحقق، $length أرقام';
  }

  @override
  String get otpVerify => 'تأكيد';

  @override
  String get otpResend => 'إعادة إرسال الرمز';

  @override
  String otpResendIn(int seconds) {
    return 'إعادة الإرسال بعد $seconds ث';
  }

  @override
  String get otpChangeNumber => 'تغيير الرقم';

  @override
  String get otpResent => 'أُرسل رمز جديد.';

  @override
  String get otpErrInvalid => 'الرمز غير صحيح. تحقق منه وحاول مجددًا.';

  @override
  String get otpErrExpired => 'انتهت صلاحية الرمز. اطلب رمزًا جديدًا.';

  @override
  String get otpErrTooMany => 'محاولات كثيرة. انتظر قليلًا ثم حاول.';

  @override
  String get otpErrPhone => 'لا يمكن إرسال رمز إلى هذا الرقم.';

  @override
  String get otpErrNetwork => 'تعذّر الاتصال. تحقق من الإنترنت وحاول مجددًا.';

  @override
  String get otpErrUnavailable => 'التحقق غير متاح الآن. حاول لاحقًا.';

  @override
  String get otpDevMockNotice =>
      'للمطورين فقط: مفاتيح Twilio ناقصة، لذا يُستخدم الرمز التجريبي 1234.';

  @override
  String get driverOtpTitle => 'تأكيد هويتك';

  @override
  String get driverLoginBrand => 'سطر | السائق';

  @override
  String get driverLoginHeadline => 'مرحباً بعودتك';

  @override
  String get driverLoginSubtitle => 'سجّل الدخول لتبدأ باستلام مهام التوصيل.';

  @override
  String get driverLoginPhone => 'رقم الجوال';

  @override
  String get driverLoginPassword => 'كلمة المرور';

  @override
  String get driverLoginPhoneInvalid => 'أدخل رقم جوال صحيحًا، مثل 0599123456.';

  @override
  String get driverLoginPasswordRequired => 'أدخل كلمة المرور.';

  @override
  String get driverLoginBadCredentials =>
      'رقم الجوال أو كلمة المرور غير صحيحة.';

  @override
  String get driverLoginSubmit => 'دخول';

  @override
  String get driverLoginShowPassword => 'إظهار كلمة المرور';

  @override
  String get driverLoginHidePassword => 'إخفاء كلمة المرور';

  @override
  String get driverLoginForgot => 'نسيت كلمة المرور؟';

  @override
  String get driverLoginForgotText => 'تواصل مع مشغّل سطر ليعيد ضبطها.';

  @override
  String get driverLoginSupport => 'التواصل مع الدعم';

  @override
  String get driverLoginSupportText => 'تواصل مع مشغّل سطر للمساعدة في حسابك.';

  @override
  String driverLoginVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get driverDeliverCta => 'تسليم الطلب';

  @override
  String get driverFailDeliveryCta => 'تعذّر التسليم';

  @override
  String get driverDeliverTitle => 'تأكيد التسليم';

  @override
  String get driverDeliverHint => 'اطلب من الزبون كود التسليم الظاهر في تطبيقه';

  @override
  String get driverDeliverConfirm => 'تأكيد التسليم';

  @override
  String get driverDeliverPaste => 'لصق الكود';

  @override
  String get driverDeliverCollect => 'حصّل من الزبون';

  @override
  String get driverDeliverErrWrong =>
      'كود التسليم غير صحيح. تأكد منه مع الزبون وأعد المحاولة.';

  @override
  String get driverDeliverErrTooMany =>
      'محاولات كثيرة. انتظر قليلًا ثم أعد المحاولة.';

  @override
  String get driverDeliverErrState =>
      'لم يعد هذا الطلب قابلًا للتسليم. حدّث المهمة.';

  @override
  String get driverDeliverErrNetwork =>
      'تعذّر الاتصال. تحقق من الإنترنت وأعد المحاولة.';

  @override
  String get driverDeliverErrSession => 'انتهت جلستك. سجّل الدخول من جديد.';

  @override
  String get driverDeliverRefresh => 'حدّث المهمة';

  @override
  String get orderDeliveryCodeTitle => 'كود التسليم';

  @override
  String get orderDeliveryCodeCaption =>
      'أعطِ هذا الكود للسائق عند الاستلام فقط';

  @override
  String get driverSettingsTitle => 'الإعدادات';

  @override
  String get driverSettingsOnline => 'متصل';

  @override
  String get driverSettingsOffline => 'غير متصل';

  @override
  String driverSettingsRatingCount(String rating, int count) {
    return '$rating · $count تقييمًا';
  }

  @override
  String get driverSettingsMyData => 'بياناتي';

  @override
  String get driverSettingsName => 'الاسم';

  @override
  String get driverSettingsPhone => 'رقم الجوال';

  @override
  String get driverSettingsVehicle => 'المركبة';

  @override
  String get driverSettingsZone => 'المنطقة';

  @override
  String get driverSettingsCash => 'النقد معك';

  @override
  String get driverSettingsCashNearLimit =>
      'اقتربت من الحد الأقصى للنقد. سلّم النقد قريبًا.';

  @override
  String get driverSettingsLanguage => 'اللغة';

  @override
  String get driverSettingsLoadErrorTitle => 'تعذّر تحميل بياناتك';

  @override
  String get driverSettingsLoadErrorText => 'تحقق من الاتصال ثم أعد المحاولة.';

  @override
  String get driverSettingsRetry => 'أعد المحاولة';

  @override
  String get driverSettingsNotifications => 'الإشعارات';

  @override
  String get driverSettingsNotifHistory => 'سجل الإشعارات';

  @override
  String get driverSettingsLogout => 'تسجيل الخروج';

  @override
  String get driverSettingsLogoutSub => 'ستصبح غير متصل';

  @override
  String get driverSettingsLogoutTitle => 'تسجيل الخروج؟';

  @override
  String get driverSettingsLogoutText => 'سيصبح حسابك غير متصل ولن تصلك طلبات.';

  @override
  String get driverSettingsCancel => 'إلغاء';

  @override
  String get vehicleMotorcycle => 'دراجة نارية';

  @override
  String get vehicleCar => 'سيارة';

  @override
  String get vehicleBicycle => 'دراجة هوائية';

  @override
  String get vehicleVan => 'فان';

  @override
  String get vehicleTukTuk => 'توك توك';

  @override
  String get vehicleOnFoot => 'مشيًا';

  @override
  String get pushToggleTitle => 'تفعيل الإشعارات';

  @override
  String get pushToggleSub => 'تنبيهات الطلبات والتحديثات من سطر';

  @override
  String get pushUnsupported => 'غير متاحة على هذا الجهاز';

  @override
  String get pushDenied => 'الإشعارات مرفوضة من إعدادات النظام';

  @override
  String get pushOpenSystem => 'فتح إعدادات النظام';

  @override
  String get pushToggleError => 'تعذّر تحديث إعداد الإشعارات';

  @override
  String get pushRetry => 'أعد المحاولة';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsReadAll => 'قراءة الكل';

  @override
  String cartBadgeLabel(int count) {
    return 'السلة، $count عناصر';
  }

  @override
  String get voiceModeTitle => 'الوضع الصوتي التفاعلي';

  @override
  String get voiceModeTooltip => 'الوضع الصوتي';

  @override
  String get listeningState => 'أنصت إليك...';

  @override
  String get thinkingState => 'يفكر في إجابتك...';

  @override
  String get speakingState => 'يتحدث الآن...';

  @override
  String get finishVoiceSession => 'إنهاء المحادثة والمراجعة';

  @override
  String get voiceConfirmAdd => 'تأكيد وإضافة للسلة';

  @override
  String get voiceContinue => 'متابعة المحادثة';

  @override
  String get voiceTapToResume => 'اضغط للمتابعة';

  @override
  String get voiceMicDenied => 'نحتاج إذن الميكروفون لنتحدث معك.';

  @override
  String get voiceOpenSettings => 'فتح الإعدادات';

  @override
  String get voiceUnsupported => 'الوضع الصوتي غير متاح على هذا الجهاز';

  @override
  String get voiceArabicVoiceMissing =>
      'لم نجد صوتًا عربيًا على جهازك. ثبّته من إعدادات النظام ثم أعد المحاولة.';

  @override
  String get voiceQuotaMessage => 'المساعد مشغول حاليًا، جرّب بعد قليل.';

  @override
  String get voiceNetworkMessage =>
      'تعذّر الاتصال، تأكد من الإنترنت وجرّب مرة ثانية.';

  @override
  String get voiceNoItems => 'ما في أصناف للمراجعة بعد.';

  @override
  String get voiceGreeting => 'أهلًا، أنا قلم. شو بدك اليوم؟';

  @override
  String get voiceBackToText => 'العودة للمساعد النصي';

  @override
  String get voiceSummaryTitle => 'مراجعة الأصناف';

  @override
  String get voiceTotal => 'المجموع';

  @override
  String get voiceInStock => 'متوفر';

  @override
  String get voiceOutOfStock => 'غير متوفر';

  @override
  String get voiceCloseLabel => 'إغلاق';

  @override
  String get voiceAddedToCart => 'أُضيفت الأصناف إلى السلة';

  @override
  String voiceProposedCount(int count) {
    return '$count أصناف مقترحة';
  }
}
