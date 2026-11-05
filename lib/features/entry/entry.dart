import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/config/app_env.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/services/push/push_service.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';
import 'package:project/data/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// مقارنة نسخ x.y.z. true إذا [a] أقدم من [b].
bool versionLess(String a, String b) {
  List<int> p(String s) => [for (final x in s.split('.')) int.tryParse(x) ?? 0];
  final pa = p(a), pb = p(b);
  for (var i = 0; i < 3; i++) {
    final x = i < pa.length ? pa[i] : 0, y = i < pb.length ? pb[i] : 0;
    if (x != y) return x < y;
  }
  return false;
}

// ------------------------------------------------------------------- splash

enum SplashState { loading, offline, error }

class SplashController extends GetxController {
  final state = SplashState.loading.obs;
  final failure = Rxn<Failure>();

  @override
  void onReady() {
    super.onReady();
    run();
  }

  Future<void> run() async {
    state.value = SplashState.loading;
    final session = Get.find<SessionStore>();
    final repo = Get.find<RemoteConfigRepository>();
    repo.app = session.isDriver ? 'driver' : 'user';
    final started = DateTime.now();
    final result = await repo.load(refresh: true);
    final elapsed = DateTime.now().difference(started);
    if (elapsed < const Duration(milliseconds: 900)) {
      await Future.delayed(const Duration(milliseconds: 900) - elapsed);
    }
    await result.fold((f) async {
      failure.value = f;
      // خطأ يملك شاشته (426/503...) فتح بالفعل عبر AppGate.
      state.value = (f is NetworkFailure || f is TimeoutFailure) ? SplashState.offline : SplashState.error;
    }, (config) async {
      final min = config.minAppVersion;
      if (min != null && min.isNotEmpty && versionLess(AppEnv.appVersion, min)) {
        Get.offAllNamed('/update-required');
        return;
      }
      if (session.isSignedIn) {
        Get.offAllNamed(session.isDriver ? '/driver/home' : '/home');
        PushService.maybe?.handleInitialMessage();
      } else {
        Get.offAllNamed('/role');
      }
    });
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(SplashController());
    return Obx(() {
      if (ctl.state.value == SplashState.offline) {
        return SystemStateScreen(
            ill: 'offline',
            title: 'لا يوجد اتصال',
            text: 'تحقق من الإنترنت ثم حاول مجددًا. سلتك ومسوّداتك محفوظة.',
            actions: [SBtn('أعد المحاولة', icon: 'refresh', full: true, onTap: ctl.run)]);
      }
      if (ctl.state.value == SplashState.error) {
        final f = ctl.failure.value;
        final rid = f is ServerFailure ? f.requestId : null;
        final noKey = f?.code == ApiErrorCodes.missingProjectKey;
        return SystemStateScreen(
            ill: 'tools',
            title: noKey ? 'التطبيق غير مهيّأ' : 'حدث خلل من جهتنا',
            text: noKey ? 'مفتاح المشروع غير موجود في هذه النسخة. ابنِ التطبيق مع SATR_PROJECT_KEY.' : 'نعمل على إصلاحه. لم يُفقد شيء. جرّب بعد قليل.',
            extra: rid == null ? null : Num('رقم الطلب: $rid', style: T.cap(c.tx3)),
            actions: [SBtn('أعد المحاولة', icon: 'refresh', full: true, onTap: ctl.run)]);
      }
      return Scaffold(
        backgroundColor: c.hero,
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SatrLogo(width: 230),
                  const SizedBox(height: 24),
                  Text('مكتبتك الذكية', style: T.d2(c.onHero, size: 24)),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: SizedBox(width: 120, child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(minHeight: 6, backgroundColor: c.sf3, color: c.pri))),
            ),
          ]),
        ),
      );
    });
  }
}

/// شاشة حالة كاملة (sysScr): رسم + عنوان + نص + أزرار.
class SystemStateScreen extends StatelessWidget {
  const SystemStateScreen({super.key, required this.ill, required this.title, required this.text, this.actions = const [], this.extra, this.top});
  final String ill;
  final String title;
  final String text;
  final List<Widget> actions;
  final Widget? extra;
  final Widget? top;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(
      top: top,
      center: true,
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        Ill(ill, width: 200),
        const SizedBox(height: 24),
        Text(title, textAlign: TextAlign.center, style: T.d2(c.tx)),
        const SizedBox(height: 8),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 300), child: Text(text, textAlign: TextAlign.center, style: T.bd(c.tx2))),
        if (extra != null) ...[const SizedBox(height: 8), extra!],
      ]),
      foot: actions.isEmpty
          ? null
          : Foot(child: Column(mainAxisSize: MainAxisSize.min, children: [for (var i = 0; i < actions.length; i++) ...[if (i > 0) const SizedBox(height: 6), actions[i]]])),
    );
  }
}

// --------------------------------------------------------------------- role

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    Widget card(String title, String sub, String ill, VoidCallback onTap) => Material(
          color: c.sf,
          borderRadius: BorderRadius.circular(Rad.m),
          child: InkWell(
            borderRadius: BorderRadius.circular(Rad.m),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(Rad.m), border: Border.all(color: c.ln)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: T.h2(c.tx)), const SizedBox(height: 4), Text(sub, style: T.sm(c.tx2))])),
                const SizedBox(width: 16),
                Ill(ill, width: 92),
              ]),
            ),
          ),
        );
    return Page2(
      top: const TopBar(back: false),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Eyebrow('مرحبًا بك'),
        Text('كيف تريد استخدام سطر؟', style: T.d2(c.tx)),
        const SizedBox(height: 24),
        card('أنا زبون', 'اطلب كتبًا وقرطاسية، واطبع ملفاتك، وتابع طلبك.', 'books', () async {
          await Get.find<SessionStore>().setRole('customer');
          Get.find<RemoteConfigRepository>().app = 'user';
          final seen = Get.find<SharedPreferences>().getBool('onboarding_seen') ?? false;
          Get.toNamed(seen ? '/auth/phone' : '/onboarding');
        }),
        const SizedBox(height: 24),
        card('أنا سائق توصيل', 'استلم المهام القريبة منك وأكّد التسليم.', 'route', () async {
          Get.find<RemoteConfigRepository>().app = 'driver';
          Get.toNamed('/driver/login');
        }),
        const SizedBox(height: 24),
        const Note('plum', text: 'حسابات السائقين يُنشئها مشغّل سطر. إن لم يكن لديك حساب، تواصل مع الإدارة.'),
      ]),
    );
  }
}

// --------------------------------------------------------------- onboarding

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int i = 0;
  static const data = [
    ('books', 'كل ما تكتب به وتقرأ', 'كتب وقرطاسية وهدايا، من مكتبة واحدة إلى باب بيتك.'),
    ('print', 'اطبع ملفاتك بلا تعقيد', 'ارفع PDF أو صورة، اختر الورق واللون والتجليد، وشاهد السعر قبل أن تطلب.'),
    ('assist', 'قُل ما تحتاج', 'اكتب أو تحدّث، ويجهّز المساعد سلتك لتراجعها قبل أي طلب.'),
  ];

  void _done() {
    Get.find<SharedPreferences>().setBool('onboarding_seen', true);
    Get.offAllNamed('/auth/phone');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final d = data[i];
    final bg = [c.hero, c.plumSoft, c.amberSoft][i];
    return Page2(
      top: SizedBox(height: 56, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [if (i < 2) SBtn('تخطَّ', kind: BtnKind.ghost, size: BtnSize.sm, onTap: _done)]))),
      body: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: double.infinity, padding: const EdgeInsets.fromLTRB(12, 28, 12, 16), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Rad.xl)), child: Center(child: Ill(d.$1, width: 250))),
          const SizedBox(height: 24),
          Text(d.$2, style: T.d2(c.tx)),
          const SizedBox(height: 8),
          Text(d.$3, style: T.bd(c.tx2)),
          const SizedBox(height: 24),
          PagerDots(i, 3),
        ]),
      ),
      foot: Foot(child: SBtn(i < 2 ? 'التالي' : 'ابدأ الآن', icon: i < 2 ? 'fwd' : null, full: true, onTap: () => i < 2 ? setState(() => i++) : _done())),
    );
  }
}

// --------------------------------------------------------------------- auth

enum OtpMode { entry, wrong, expired, locked }

class AuthController extends GetxController {
  final _api = Get.find<Backend>();
  final _session = Get.find<SessionStore>();

  final phone = TextEditingController();
  final phoneError = RxnString();
  final sending = false.obs;
  final retryAfter = 0.obs; // ثوانٍ متبقية لزر الإرسال (429)

  final otp = ''.obs;
  final mode = OtpMode.entry.obs;
  final verifying = false.obs;
  final suggestResend = false.obs;
  final resendIn = 0.obs;
  String _sentTo = '';
  int _wrong = 0;
  Timer? _timer;

  static final _phoneRe = RegExp(r'^\+?[0-9]{9,15}$');
  /// صيغة دولية اختيارية: إن مُرّر SATR_DEFAULT_COUNTRY_CODE (مثل 970) يُحوَّل الرقم المحلي الذي يبدأ بـ 0.
  /// الافتراضي فارغ: نرسل الرقم كما كُتب والخادم هو من يطبّعه (قرار للباكند، انظر ملف التسليم).
  static const _cc = String.fromEnvironment('SATR_DEFAULT_COUNTRY_CODE');
  String get cleanPhone {
    var p = phone.text.replaceAll(RegExp(r'[\s\-()]'), '');
    if (p.startsWith('00')) p = '+${p.substring(2)}';
    if (_cc.isNotEmpty && p.startsWith('0') && !p.startsWith('00')) p = '+$_cc${p.substring(1)}';
    return p;
  }
  String get shownPhone => _sentTo;

  void _countdown(RxInt target, int seconds) {
    _timer?.cancel();
    target.value = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (target.value <= 1) {
        target.value = 0;
        t.cancel();
      } else {
        target.value--;
      }
    });
  }

  Future<void> sendOtp({bool resend = false}) async {
    if (sending.value || retryAfter.value > 0) return;
    final p = resend ? _sentTo : cleanPhone;
    // التحقق المحلي أولًا (الصيغة) ثم رسالة الخادم؛ لا نمسح ما كتبه المستخدم.
    if (!_phoneRe.hasMatch(p)) {
      phoneError.value = 'رقم الجوال غير صحيح. أدخل من 9 إلى 15 رقمًا.';
      return;
    }
    phoneError.value = null;
    sending.value = true;
    final r = await _api.sendOtp(p);
    sending.value = false;
    r.fold((f) {
      if (f is ServerFailure && f.code == ApiErrorCodes.tooManyRequests) {
        _countdown(retryAfter, f.retryAfterSeconds ?? 600);
        if (!resend) return;
      }
      if (f is ValidationFailure) {
        phoneError.value = f.fieldErrors['phone'] ?? f.message ?? 'رقم الجوال غير صحيح.';
      } else if (f is! ServerFailure || f.code != ApiErrorCodes.tooManyRequests) {
        phoneError.value = _msg(f);
      }
    }, (_) {
      _sentTo = p;
      _wrong = 0;
      suggestResend.value = false;
      otp.value = '';
      mode.value = OtpMode.entry;
      _countdown(resendIn, 42);
      if (resend) {
        showToast('أرسلنا رمزًا جديدًا');
      } else {
        Get.toNamed('/auth/otp');
      }
    });
  }

  String _msg(Failure f) {
    if (f is NetworkFailure || f is TimeoutFailure) return 'تعذّر الاتصال. تحقق من الإنترنت وحاول مجددًا.';
    return f.message ?? 'حدث خطأ. حاول مجددًا.';
  }

  Future<void> key(String k) async {
    if (verifying.value || mode.value == OtpMode.expired || mode.value == OtpMode.locked) return;
    if (k == '⌫') {
      if (otp.value.isNotEmpty) otp.value = otp.value.substring(0, otp.value.length - 1);
      mode.value = OtpMode.entry;
      return;
    }
    if (otp.value.length >= 4) return;
    mode.value = OtpMode.entry;
    otp.value += k;
    if (otp.value.length == 4) await verify();
  }

  Future<void> verify() async {
    verifying.value = true;
    final r = await _api.verifyOtp(_sentTo, otp.value, deviceName: 'satr-app');
    verifying.value = false;
    await r.fold((f) async {
      if (f.code == ApiErrorCodes.otpExpired) {
        mode.value = OtpMode.expired;
      } else if (f.code == ApiErrorCodes.otpInvalid || f is ValidationFailure) {
        // بعد 5 محاولات خاطئة يقفل الرمز؛ رمز الخطأ بعد القفل غير موثق فنقرأ التفاصيل إن وُجدت.
        // الخادم هو المرجع: القفل يُعرض فقط إذا أعلنه الخادم صراحةً. العدّاد المحلي لا يعطّل الإدخال،
        // يكتفي باقتراح طلب رمز جديد بعد 5 محاولات خاطئة (حد موثّق في العقد).
        _wrong++;
        if (_wrong >= 5) suggestResend.value = true;
        final locked = f.reason == 'otp_locked' || f.reason == 'locked' || f.code == 'otp_locked';
        mode.value = locked ? OtpMode.locked : OtpMode.wrong;
        await Future.delayed(const Duration(milliseconds: 700));
        if (mode.value == OtpMode.wrong) otp.value = '';
      } else {
        mode.value = OtpMode.wrong;
        showToast(_msg(f), icon: 'alertC');
        otp.value = '';
      }
    }, (auth) async {
      await _session.signIn(token: auth.token, userId: auth.user.id);
      await _session.setRole('customer');
      PushService.maybe?.onSessionStarted();
      CartBinding.ensureCart().ensureLoaded();
      if (auth.isNewUser || (auth.user.name ?? '').isEmpty) {
        Get.offAllNamed('/auth/welcome');
      } else {
        Get.offAllNamed('/home');
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    phone.dispose();
    super.onClose();
  }
}

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(AuthController());
    return Page2(
      top: const TopBar(),
      body: Obx(() {
        final rate = ctl.retryAfter.value > 0;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Eyebrow('تسجيل الدخول'),
          Text('أدخل رقم جوالك', style: T.d2(c.tx)),
          const SizedBox(height: 6),
          Text('سنرسل لك رمز تحقق من 4 أرقام برسالة نصية. لا حاجة لكلمة مرور.', style: T.bd(c.tx2)),
          const SizedBox(height: 24),
          Fld(label: 'رقم الجوال', hint: '0599123456', controller: ctl.phone, keyboard: TextInputType.phone, ltr: true, error: ctl.phoneError.value, helper: 'مثال: 0599123456', autofocus: true, onChanged: (_) => ctl.phoneError.value = null, onSubmitted: (_) => ctl.sendOtp()),
          if (rate) ...[
            const SizedBox(height: 24),
            Note('warn', child: Text.rich(TextSpan(children: [
              const TextSpan(text: 'وصلت للحد المسموح.', style: TextStyle(fontWeight: FontWeight.w700)),
              const TextSpan(text: ' يمكن طلب 3 رموز فقط كل 10 دقائق. جرّب مجددًا بعد '),
              WidgetSpan(child: CountdownText(ctl.retryAfter.value, key: ValueKey(ctl.retryAfter.value ~/ 3600), style: TextStyle(fontFamily: Fonts.ui, fontSize: 14, fontWeight: FontWeight.w700, color: c.amberInk))),
            ]))),
          ],
          const SizedBox(height: 24),
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text('بالمتابعة فإنك توافق على ', style: T.sm(c.tx2)),
            InkWell(
              onTap: () async {
                final u = Get.find<RemoteConfigRepository>().current?.termsUrl;
                if (u != null) await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
              },
              child: Text('شروط الاستخدام', style: T.sm(c.plumInk, w: FontWeight.w600).copyWith(decoration: TextDecoration.underline)),
            ),
            Text('.', style: T.sm(c.tx2)),
          ]),
        ]);
      }),
      foot: Foot(child: Obx(() => SBtn(ctl.retryAfter.value > 0 ? 'انتظر قليلًا' : 'أرسل الرمز', full: true, loading: ctl.sending.value, disabled: ctl.retryAfter.value > 0, onTap: ctl.sendOtp))),
    );
  }
}

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.find<AuthController>();
    return Obx(() {
      final bad = ctl.mode.value == OtpMode.wrong;
      final dis = ctl.mode.value == OtpMode.expired || ctl.mode.value == OtpMode.locked;
      final msg = switch (ctl.mode.value) {
        OtpMode.wrong => const Note('err', title: 'الرمز غير صحيح.', text: 'تحقق من الرسالة وأعد المحاولة. بعد 5 محاولات خاطئة يُقفل الرمز.'),
        OtpMode.expired => const Note('warn', title: 'انتهت صلاحية الرمز.', text: 'اطلب رمزًا جديدًا للمتابعة.'),
        OtpMode.locked => const Note('err', title: 'أُقفل الرمز بعد 5 محاولات خاطئة.', text: 'اطلب رمزًا جديدًا.'),
        _ => null,
      };
      return Page2(
        top: const TopBar(),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Eyebrow('التحقق'),
          Text('أدخل الرمز', style: T.d2(c.tx)),
          const SizedBox(height: 6),
          Text.rich(TextSpan(style: T.bd(c.tx2), children: [
            const TextSpan(text: 'أرسلناه إلى '),
            WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic, child: Text(ctl.shownPhone, textDirection: TextDirection.ltr, style: TextStyle(fontFamily: Fonts.ui, fontSize: 16, fontWeight: FontWeight.w600, color: c.tx))),
            const TextSpan(text: '  '),
            WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic, child: SLink('تغيير', onTap: () => Get.back())),
          ])),
          const SizedBox(height: 24),
          OtpBoxes(digits: ctl.otp.value, bad: bad),
          if (msg != null) ...[const SizedBox(height: 24), msg],
          const SizedBox(height: 24),
          Center(
            child: ctl.verifying.value
                ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: c.pri))
                : (dis || ctl.suggestResend.value)
                    ? SBtn('إرسال رمز جديد', kind: BtnKind.sec, size: BtnSize.sm, icon: 'refresh', loading: ctl.sending.value, onTap: () => ctl.sendOtp(resend: true))
                    : (ctl.resendIn.value > 0
                        ? Row(mainAxisSize: MainAxisSize.min, children: [Text('إعادة الإرسال بعد ', style: T.sm(c.tx2)), CountdownText(ctl.resendIn.value, key: ValueKey(ctl.resendIn.value ~/ 1000), style: T.sm(c.tx2))])
                        : SBtn('إعادة إرسال الرمز', kind: BtnKind.ghost, size: BtnSize.sm, onTap: () => ctl.sendOtp(resend: true))),
          ),
        ]),
        foot: Keypad(onKey: ctl.key, disabled: dis || ctl.verifying.value),
      );
    });
  }
}

class WelcomeNameScreen extends StatefulWidget {
  const WelcomeNameScreen({super.key});
  @override
  State<WelcomeNameScreen> createState() => _WelcomeNameScreenState();
}

class _WelcomeNameScreenState extends State<WelcomeNameScreen> {
  final name = TextEditingController();
  bool busy = false;
  String? err;

  Future<void> _save() async {
    final n = name.text.trim();
    if (n.isEmpty) return _skip();
    if (n.length < 2) {
      setState(() => err = 'الاسم من حرفين إلى 120 حرفًا.');
      return;
    }
    setState(() {
      busy = true;
      err = null;
    });
    final r = await Get.find<Backend>().updateMe(name: n);
    if (!mounted) return;
    setState(() => busy = false);
    r.fold((f) => setState(() => err = f is ValidationFailure ? (f.fieldErrors['name'] ?? f.message) : (f.message ?? 'تعذّر الحفظ.')), (_) => _skip());
  }

  void _skip() => Get.offAllNamed('/home');

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(
      top: const TopBar(back: false),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Eyebrow('تشرّفنا'),
        Text('ماذا نناديك؟', style: T.d2(c.tx)),
        const SizedBox(height: 6),
        Text('نستخدم اسمك في الترحيب وعند التسليم.', style: T.bd(c.tx2)),
        const SizedBox(height: 24),
        Fld(label: 'الاسم', hint: 'مثال: هالة', controller: name, optional: true, error: err, autofocus: true, onSubmitted: (_) => _save()),
      ]),
      foot: Foot(child: Column(mainAxisSize: MainAxisSize.min, children: [SBtn('ابدأ التسوّق', full: true, loading: busy, onTap: _save), const SizedBox(height: 8), SBtn('لاحقًا', kind: BtnKind.ghost, full: true, onTap: _skip)])),
    );
  }
}

/// أذونات / حالات النظام الثابتة (١٠ · الحالات والأذونات).
class StateScreens {
  static Future<void> _call() async {
    final p = Get.find<RemoteConfigRepository>().current?.supportPhone;
    if (p != null) await launchUrl(Uri.parse('tel:$p'));
  }

  static Widget callSupport() => SBtn('اتصل بالدعم', icon: 'phone', full: true, onTap: _call);

  static Widget updateRequired() => SystemStateScreen(ill: 'lock', title: 'حدّث التطبيق للمتابعة', text: 'أضفنا تحسينات مهمة، ونسختك الحالية لم تعد مدعومة.', actions: [
        SBtn('تحديث من المتجر', icon: 'download', full: true, onTap: () async {
          // لا يوجد حقل لرابط المتجر في config؛ نفتح صفحة التطبيق بمعرّفه في المتجر.
          const id = String.fromEnvironment('SATR_APP_ID', defaultValue: 'com.example.project');
          final market = Uri.parse('market://details?id=$id');
          if (!await launchUrl(market, mode: LaunchMode.externalApplication)) {
            await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=$id'), mode: LaunchMode.externalApplication);
          }
        })
      ]);
  static Widget maintenance() => SystemStateScreen(ill: 'tools', title: 'نحدّث سطر الآن', text: 'نعود قريبًا. شكرًا لصبرك.', actions: [SBtn('إعادة التحقق', icon: 'refresh', full: true, onTap: () => Get.offAllNamed('/'))]);
  static Widget servicePaused() => SystemStateScreen(ill: 'lock', title: 'الخدمة متوقفة مؤقتًا', text: 'لا يمكن إنشاء طلبات الآن. للاستفسار تواصل مع الدعم.', actions: [callSupport()]);
  static Widget blocked() => SystemStateScreen(ill: 'lock', title: 'تم إيقاف حسابك', text: 'لا يمكنك استخدام التطبيق حاليًا. تواصل مع الدعم لمعرفة المزيد.', actions: [callSupport()]);
  static Widget moduleOff() => SystemStateScreen(ill: 'tools', title: 'هذه الميزة غير متاحة الآن', text: 'تعطّلت مؤقتًا. يمكنك متابعة التسوق.', actions: [SBtn('العودة للرئيسية', full: true, onTap: () => Get.offAllNamed('/home'))]);
  static Widget rateLimited(int seconds) => SystemStateScreen(
      ill: 'wait',
      title: 'أبطئ قليلًا',
      text: 'أرسلنا طلبات كثيرة. حاول بعد قليل.',
      extra: CountdownText(seconds, style: TextStyle(fontFamily: Fonts.ui, fontSize: 16, color: Get.context!.sc.tx2)),
      actions: [SBtn('انتظر', full: true, disabled: true, onTap: () {})]);
}

class SessionExpiredScreen extends StatefulWidget {
  const SessionExpiredScreen({super.key});
  @override
  State<SessionExpiredScreen> createState() => _SessionExpiredScreenState();
}

class _SessionExpiredScreenState extends State<SessionExpiredScreen> {
  late final bool driver = Get.find<SessionStore>().isDriver;
  @override
  void initState() {
    super.initState();
    // نلغي الجلسة المحلية فقط؛ السلة تبقى محفوظة على الجهاز.
    Get.find<SessionStore>().signOut();
  }

  @override
  Widget build(BuildContext context) => SystemStateScreen(
      ill: 'lock',
      title: 'انتهت جلستك',
      text: driver ? 'سجّل الدخول مرة أخرى للمتابعة.' : 'سجّل الدخول مرة أخرى للمتابعة. سلتك محفوظة.',
      actions: [SBtn('تسجيل الدخول', full: true, onTap: () => driver ? Get.offAllNamed('/driver/login') : Get.offAllNamed('/auth/phone'))]);
}

/// إذن (مثل الموقع/الإشعارات/الميكروفون/الملفات) — شرح قبل طلب إذن النظام.
class PermissionExplainScreen extends StatelessWidget {
  const PermissionExplainScreen({super.key, required this.ill, required this.title, required this.text, required this.allowLabel, required this.allowIcon, required this.onAllow, this.laterLabel = 'ليس الآن', this.onLater, this.badge});
  final String ill, title, text, allowLabel, allowIcon, laterLabel;
  final VoidCallback onAllow;
  final VoidCallback? onLater;
  final String? badge;
  @override
  Widget build(BuildContext context) => SystemStateScreen(ill: ill, title: title, text: text, extra: badge == null ? null : SChip(badge!, height: 32), actions: [
        SBtn(allowLabel, icon: allowIcon, full: true, onTap: onAllow),
        SBtn(laterLabel, kind: BtnKind.ghost, full: true, onTap: onLater ?? () => Get.back()),
      ]);
}

RemoteConfig? get appConfig => Get.find<RemoteConfigRepository>().current;
