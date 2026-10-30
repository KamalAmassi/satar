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
}
