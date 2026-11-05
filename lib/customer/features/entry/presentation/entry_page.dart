import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/core/config/app_env.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/customer/features/orders/presentation/orders_page.dart' show callUrl;
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/services/push/push_service.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/customer/features/account/presentation/account_page.dart';
import 'package:project/core/data/models.dart';
import 'package:project/core/widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final s = Get.find<SessionStore>();
    final p = Get.find<SharedPreferences>();
    await Get.find<RemoteConfigRepository>().load();
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    if (s.isSignedIn) {
      Get.offAllNamed(s.isDriver ? '/driver/home' : '/home');
      return;
    }
    if (!(p.getBool('onboarded') ?? false)) {
      Get.offAllNamed('/onboarding');
      return;
    }
    Get.offAllNamed('/role');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(
      center: true,
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(Rad.xl)),
          child: Center(child: Text('سطر', style: T.d1(c.onHero))),
        ),
        const SizedBox(height: 16),
        Text('سطر', style: T.d1(c.tx)),
        const SizedBox(height: 6),
        Text('مكتبتك في جيبك', style: T.bd(c.tx2)),
      ]),
    );
  }
}

class SystemStateScreen extends StatelessWidget {
  const SystemStateScreen({super.key, required this.ill, required this.title, required this.text, this.actions, this.extra});
  final String ill;
  final String title;
  final String text;
  final List<Widget>? actions;
  final Widget? extra;
  @override
  Widget build(BuildContext context) => Page2(
        center: true,
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          Ill(ill, width: 210),
          const SizedBox(height: 24),
          Text(title, textAlign: TextAlign.center, style: T.d2(context.sc.tx)),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center, style: T.bd(context.sc.tx2)),
          if (extra != null) ...[const SizedBox(height: 16), extra!],
        ]),
        foot: actions == null ? null : Foot(child: Column(mainAxisSize: MainAxisSize.min, children: actions!)),
      );
}

class GateCheckScreen extends StatefulWidget {
  const GateCheckScreen({super.key});
  @override
  State<GateCheckScreen> createState() => _GateCheckScreenState();
}

class _GateCheckScreenState extends State<GateCheckScreen> {
  late final ctl = Get.put(GateController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final st = ctl.state.value;
      if (st == GateState.updateRequired) {
        return SystemStateScreen(ill: 'tools', title: 'تحديث جديد متاح', text: 'تطوّرت سطر. حُدّث التطبيق للاستمرار بجميع الميزات.', actions: [SBtn('تحديث من المتجر', icon: 'download', full: true, onTap: ctl.openStore)]);
      }
      if (st == GateState.maintenance) {
        return SystemStateScreen(ill: 'tools', title: 'نحدّث سطر الآن', text: ctl.message.value ?? 'نعود خلال وقت قصير. طلباتك الجارية تجدها فور العودة.');
      }
      if (st == GateState.rateLimited) {
        return SystemStateScreen(ill: 'clock', title: 'انتظر قليلًا', text: 'أرسلت عدة طلبات في وقت قصير. يرجى الانتظار دقيقة قبل المحاولة.', actions: [SBtn('أعد المحاولة', icon: 'refresh', full: true, onTap: ctl.run)]);
      }
      if (st == GateState.blocked) {
        return SystemStateScreen(ill: 'offline', title: 'الحساب موقوف', text: ctl.message.value ?? 'تواصل مع الدعم للاستفسار.');
      }
      if (st == GateState.servicePaused) {
        return SystemStateScreen(ill: 'tools', title: 'الخدمة متوقفة مؤقتًا في منطقتك', text: ctl.message.value ?? 'نعود قريبًا.');
      }
      if (st == GateState.error) {
        return SystemStateScreen(ill: 'offline', title: 'تعذّر الاتصال', text: failureText(ctl.failure.value!), actions: [SBtn('أعد المحاولة', icon: 'refresh', full: true, onTap: ctl.run)]);
      }
      return const SplashScreen();
    });
  }
}

enum GateState { checking, ok, updateRequired, maintenance, rateLimited, blocked, servicePaused, error }

class GateController extends GetxController {
  final state = GateState.checking.obs;
  final failure = Rxn<Failure>();
  final message = RxnString();

  @override
  void onInit() {
    super.onInit();
    run();
  }

  Future<void> run() async {
    state.value = GateState.checking;
    final r = await Get.find<RemoteConfigRepository>().load(refresh: true);
    r.fold((f) {
      failure.value = f;
      state.value = GateState.error;
    }, (cfg) {
      if (cfg.maintenance) {
        message.value = cfg.maintenanceNotice;
        state.value = GateState.maintenance;
        return;
      }
      final cur = AppEnv.versionCode;
      if (cfg.minVersionCode > cur) {
        state.value = GateState.updateRequired;
        return;
      }
      state.value = GateState.ok;
    });
  }

  void openStore() {
    final u = Get.find<RemoteConfigRepository>().current?.storeUrl;
    if (u != null) launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
  }
}

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(
      center: true,
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        const Ill('welcome', width: 220),
        const SizedBox(height: 24),
        Text('مرحبًا بك في سطر', style: T.d2(c.tx)),
        const SizedBox(height: 8),
        Text('اختر كيف تريد استخدام التطبيق', style: T.bd(c.tx2)),
        const SizedBox(height: 32),
        OptCard(on: true, icon: 'bag', title: 'أنا زبون', sub: 'أتسوق، أطلب طباعة، أتابع التوصيل', onTap: () => Get.toNamed('/home')),
        const SizedBox(height: 12),
        OptCard(on: false, icon: 'truck', title: 'أنا سائق', sub: 'أستلم الطلبات وأوصلها للزبائن', onTap: () => Get.toNamed('/driver/login')),
      ]),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int i = 0;
  final pages = const [
    ('assist', 'كل احتياجاتك الدراسية', 'كتب، قرطاسية، ألعاب هدايا بلمسة واحدة.'),
    ('print', 'طباعة ملفاتك بسهولة', 'ارفع ملفك، اختر المواصفات، ونطبع ونوصّل.'),
    ('route', 'توصيل سريع حتى بابك', 'تابع سائقك على الخريطة أولًا بأول.'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final p = pages[i];
    return Page2(
      top: SizedBox(height: 56, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${i + 1} / ${pages.length}', style: T.cap(c.tx3)), SBtn('تخطي', kind: BtnKind.ghost, size: BtnSize.sm, onTap: _done)]))),
      center: true,
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        Ill(p.$1, width: 230),
        const SizedBox(height: 32),
        Text(p.$2, textAlign: TextAlign.center, style: T.d2(c.tx)),
        const SizedBox(height: 10),
        Text(p.$3, textAlign: TextAlign.center, style: T.bd(c.tx2)),
      ]),
      foot: Foot(child: SBtn(i < 2 ? 'التالي' : 'ابدأ الآن', icon: i < 2 ? 'fwd' : null, full: true, onTap: () {
        if (i < 2) {
          setState(() => i++);
        } else {
          _done();
        }
      })),
    );
  }

  void _done() {
    Get.find<SharedPreferences>().setBool('onboarded', true);
    Get.offAllNamed('/role');
  }
}

class PhoneController extends GetxController {
  final phone = TextEditingController();
  final sending = false.obs;
  final failure = Rxn<Failure>();

  Future<void> send() async {
    final p = phone.text.trim();
    if (p.length < 8) {
      showToast('أدخل رقم جوال صحيح', icon: 'alertC');
      return;
    }
    sending.value = true;
    failure.value = null;
    final r = await backend.sendOtp(p);
    sending.value = false;
    r.fold((f) => failure.value = f, (_) {
      Get.toNamed('/auth/otp', arguments: {'phone': p});
    });
  }

  @override
  void onClose() {
    phone.dispose();
    super.onClose();
  }
}

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(PhoneController());
    return Page2(
      top: const TopBar(title: 'تسجيل الدخول'),
      body: Obx(() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Ill('pin', width: 170),
            const SizedBox(height: 24),
            Text('أدخل رقم جوالك', style: T.d2(c.tx)),
            const SizedBox(height: 8),
            Text('سنرسل لك رمز تحقق عبر واتساب أو SMS لتأكيد حسابك.', style: T.bd(c.tx2)),
            const SizedBox(height: 24),
            Fld(label: 'رقم الجوال', hint: '0599000000', controller: ctl.phone, keyboard: TextInputType.phone, ltr: true, error: ctl.failure.value == null ? null : failureText(ctl.failure.value!)),
          ])),
      foot: Foot(child: Obx(() => SBtn('أرسل الرمز', full: true, loading: ctl.sending.value, onTap: ctl.send))),
    );
  }
}

enum _OtpUi { entry, wrong, expired, locked }

/// تحقق الزبون برمز SMS عبر الخادم (sendOtp/verifyOtp ثم signIn). منقول من
/// d1d6084:lib/features/entry/entry.dart. التحقق الثنائي للسائق يبقى في core/otp.
class OtpController extends GetxController {
  late final String phone;
  final sending = false.obs;
  final verifying = false.obs;
  final otp = ''.obs;
  final mode = _OtpUi.entry.obs;
  final resendIn = 0.obs;
  final suggestResend = false.obs;
  Timer? _timer;
  int _wrong = 0;

  @override
  void onInit() {
    super.onInit();
    final a = Get.arguments;
    phone = a is Map ? (a['phone'] as String? ?? '') : '';
    _countdown(42);
  }

  void _countdown(int seconds) {
    _timer?.cancel();
    resendIn.value = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendIn.value <= 1) {
        resendIn.value = 0;
        t.cancel();
      } else {
        resendIn.value--;
      }
    });
  }

  Future<void> sendOtp({bool resend = false}) async {
    if (sending.value) return;
    sending.value = true;
    final r = await backend.sendOtp(phone);
    sending.value = false;
    r.fold((f) => showToast(failureText(f), icon: 'alertC'), (_) {
      _wrong = 0;
      suggestResend.value = false;
      otp.value = '';
      mode.value = _OtpUi.entry;
      _countdown(42);
      if (resend) showToast('أرسلنا رمزًا جديدًا');
    });
  }

  Future<void> key(String k) async {
    if (verifying.value || mode.value == _OtpUi.expired || mode.value == _OtpUi.locked) return;
    if (k == '⌫') {
      if (otp.value.isNotEmpty) otp.value = otp.value.substring(0, otp.value.length - 1);
      mode.value = _OtpUi.entry;
      return;
    }
    if (otp.value.length >= 4) return;
    mode.value = _OtpUi.entry;
    otp.value += k;
    if (otp.value.length == 4) await verify();
  }

  Future<void> verify() async {
    verifying.value = true;
    final r = await backend.verifyOtp(phone, otp.value, deviceName: 'satr-app');
    verifying.value = false;
    await r.fold((f) async {
      if (f.code == ApiErrorCodes.otpExpired) {
        mode.value = _OtpUi.expired;
      } else if (f.code == ApiErrorCodes.otpInvalid || f is ValidationFailure) {
        // الخادم هو المرجع في القفل؛ العدّاد المحلي يقترح رمزًا جديدًا بعد 5 محاولات فقط.
        _wrong++;
        if (_wrong >= 5) suggestResend.value = true;
        final locked = f.reason == 'otp_locked' || f.reason == 'locked' || f.code == 'otp_locked';
        mode.value = locked ? _OtpUi.locked : _OtpUi.wrong;
        await Future.delayed(const Duration(milliseconds: 700));
        if (mode.value == _OtpUi.wrong) otp.value = '';
      } else {
        mode.value = _OtpUi.wrong;
        showToast(failureText(f), icon: 'alertC');
        otp.value = '';
      }
    }, (auth) async {
      final session = Get.find<SessionStore>();
      await session.signIn(token: auth.token, userId: auth.user.id);
      await session.setRole('customer');
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
    super.onClose();
  }
}

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(OtpController());
    return Obx(() {
      final bad = ctl.mode.value == _OtpUi.wrong;
      final dis = ctl.mode.value == _OtpUi.expired || ctl.mode.value == _OtpUi.locked;
      final msg = switch (ctl.mode.value) {
        _OtpUi.wrong => const Note('err', title: 'الرمز غير صحيح.', text: 'تحقق من الرسالة وأعد المحاولة. بعد 5 محاولات خاطئة يُقفل الرمز.'),
        _OtpUi.expired => const Note('warn', title: 'انتهت صلاحية الرمز.', text: 'اطلب رمزًا جديدًا للمتابعة.'),
        _OtpUi.locked => const Note('err', title: 'أُقفل الرمز بعد 5 محاولات خاطئة.', text: 'اطلب رمزًا جديدًا.'),
        _OtpUi.entry => null,
      };
      return Page2(
        top: const TopBar(),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Eyebrow('التحقق'),
          Text('أدخل الرمز', style: T.d2(c.tx)),
          const SizedBox(height: 6),
          Text.rich(TextSpan(style: T.bd(c.tx2), children: [
            const TextSpan(text: 'أرسلناه إلى '),
            WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic, child: Text(ctl.phone, textDirection: TextDirection.ltr, style: TextStyle(fontFamily: Fonts.ui, fontSize: 16, fontWeight: FontWeight.w600, color: c.tx))),
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

class WelcomeNameController extends GetxController {
  final name = TextEditingController();
  final saving = false.obs;
  final failure = Rxn<Failure>();

  Future<void> save() async {
    final n = name.text.trim();
    if (n.isEmpty) return;
    saving.value = true;
    failure.value = null;
    final r = await backend.updateMe(name: n);
    saving.value = false;
    r.fold((f) => failure.value = f, (_) {
      Get.offAllNamed('/home');
    });
  }

  @override
  void onClose() {
    name.dispose();
    super.onClose();
  }
}

class WelcomeNameScreen extends StatelessWidget {
  const WelcomeNameScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(WelcomeNameController());
    return Page2(
      top: const TopBar(title: 'أهلاً بك'),
      body: Obx(() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Ill('welcome', width: 200),
            const SizedBox(height: 24),
            Text('ما اسمك؟', style: T.d2(c.tx)),
            const SizedBox(height: 8),
            Text('نحب أن نناديك باسمك عند التوصيل وتجهيز الطلب.', style: T.bd(c.tx2)),
            const SizedBox(height: 24),
            Fld(label: 'الاسم الأول والأخير', hint: 'أحمد صالح', controller: ctl.name, error: ctl.failure.value == null ? null : failureText(ctl.failure.value!)),
          ])),
      foot: Foot(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Obx(() => SBtn('ابدأ التسوّق', full: true, loading: ctl.saving.value, onTap: ctl.save)),
        const SizedBox(height: 8),
        SBtn('تخطي الآن', kind: BtnKind.ghost, full: true, onTap: () => Get.offAllNamed('/home')),
      ])),
    );
  }
}

class StateScreens {
  static Widget updateRequired() => SystemStateScreen(ill: 'tools', title: 'تحديث جديد متاح', text: 'تطوّرت سطر. حُدّث التطبيق للاستمرار بجميع الميزات.', actions: [SBtn('تحديث من المتجر', icon: 'download', full: true, onTap: () async => callUrl(Get.find<RemoteConfigRepository>().current?.storeUrl ?? ''))]);
  static Widget maintenance() => SystemStateScreen(ill: 'tools', title: 'نحدّث سطر الآن', text: Get.find<RemoteConfigRepository>().current?.maintenanceNotice ?? 'نعود خلال وقت قصير.');
  static Widget moduleOff() => SystemStateScreen(ill: 'tools', title: 'هذه الميزة غير متاحة الآن', text: 'نعمل على تجهيزها وستُفتح قريبًا.');
  static Widget servicePaused() => SystemStateScreen(ill: 'tools', title: 'الخدمة متوقفة مؤقتًا', text: 'نعود قريبًا لحسابك.');
  static Widget blocked() => SystemStateScreen(ill: 'offline', title: 'الحساب موقوف', text: 'تواصل مع الدعم للاستفسار.');
  static Widget rateLimited(int seconds) => SystemStateScreen(ill: 'clock', title: 'انتظر قليلًا', text: 'أرسلت عدة طلبات في وقت قصير. انتظر $seconds ثانية ثم حاول.', actions: [SBtn('انتظر', full: true, disabled: true, onTap: () {})]);
}

class PermissionExplainScreen extends StatelessWidget {
  const PermissionExplainScreen({super.key, required this.ill, required this.title, required this.text, required this.allowLabel, required this.allowIcon, this.badge, required this.onAllow, this.laterLabel = 'ليس الآن', this.onLater});
  final String ill;
  final String title;
  final String text;
  final String allowLabel;
  final String allowIcon;
  final String? badge;
  final VoidCallback onAllow;
  final String laterLabel;
  final VoidCallback? onLater;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(
      center: true,
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        if (badge != null) ...[STag(badge!, kind: 'soft'), const SizedBox(height: 16)],
        Ill(ill, width: 200),
        const SizedBox(height: 24),
        Text(title, textAlign: TextAlign.center, style: T.d2(c.tx)),
        const SizedBox(height: 8),
        Text(text, textAlign: TextAlign.center, style: T.bd(c.tx2)),
      ]),
      foot: Foot(child: Column(mainAxisSize: MainAxisSize.min, children: [
        SBtn(allowLabel, icon: allowIcon, full: true, onTap: onAllow),
        const SizedBox(height: 8),
        SBtn(laterLabel, kind: BtnKind.ghost, full: true, onTap: onLater ?? () => Get.back()),
      ])),
    );
  }
}
