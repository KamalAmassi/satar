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
}
