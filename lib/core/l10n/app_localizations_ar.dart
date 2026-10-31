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
  String get aiAlternatives => 'بدائل مقترحة';

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
  String get errorTimeout => 'الاتصال بطيء، جرب مرة ثانية';

  @override
  String get errorUnknown => 'صار خطأ غير متوقع';
}
