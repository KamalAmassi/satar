import 'package:flutter/material.dart';
import 'package:project/core/services/push/push_service.dart';
import 'package:get/get.dart';
import 'package:project/core/config/app_env.dart';
import 'package:project/core/config/otp_config.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/api_error_codes.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/motion/entrance.dart';
import 'package:project/core/otp/domain/otp_gateway.dart';
import 'package:project/core/otp/presentation/otp_args.dart';
import 'package:project/core/otp/presentation/otp_messages.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/core/utils/phone_normalizer.dart';
import 'package:project/data/models.dart';
import 'package:project/features/common.dart';

/// دخول السائق: أداة عمل هادئة عالية التباين، بيد واحدة، RTL أولًا.
///
/// التدفق: دخول الخادم ← (إن كان OtpConfig.enabled) إرسال رمز وفتح /otp مع إبقاء الرمز المميّز
/// في الذاكرة فقط ← بعد التحقق نحفظ الجلسة (المسار نفسه السابق) وننتقل للرئيسية.
/// الرجوع من شاشة التحقق يُسقط الرمز المميّز ولا يُحفظ شيء.
class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});
  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final phone = TextEditingController();
  final pass = TextEditingController();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();
  bool show = false, busy = false, _tried = false;
  String? _phoneErr, _passErr, _generalErr;
  int _shake = 0;

  bool get _phoneOk => PhoneNormalizer.isValid(phone.text, defaultCountryCode: OtpConfig.defaultCountryCode);
  bool get _valid => _phoneOk && pass.text.isNotEmpty;

  @override
  void dispose() {
    phone.dispose();
    pass.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _validate() {
    final l = context.l10n;
    _phoneErr = _tried && !_phoneOk ? l.driverLoginPhoneInvalid : null;
    _passErr = _tried && pass.text.isEmpty ? l.driverLoginPasswordRequired : null;
  }

  void _fail(String? phoneErr, String? passErr, String? general) {
    Haptics.error();
    setState(() {
      busy = false;
      _phoneErr = phoneErr;
      _passErr = passErr;
      _generalErr = general;
      _shake++;
    });
  }

  Future<void> _login() async {
    if (busy) return;
    final l = context.l10n;
    _tried = true;
    if (!_valid) {
      setState(_validate);
      Haptics.error();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      _phoneErr = _passErr = _generalErr = null;
    });
    // نفس صيغة الطلب السابقة للخادم (بلا تغيير في العقد).
    final r = await backend.driverLogin(phone.text.replaceAll(RegExp(r'[\s\-()]'), ''), pass.text, deviceName: 'satr-driver');
    if (!mounted) return;
    await r.fold((f) async {
      final bad = f is ValidationFailure || f.code == ApiErrorCodes.validationFailed || f.statusCode == 401 || f.statusCode == 422;
      _fail(null, bad ? l.driverLoginBadCredentials : null, bad ? null : failureText(f));
    }, (res) async {
      if (!OtpConfig.enabled) {
        await _complete(res);
        return;
      }
      await _otpGate(res);
    });
  }

  /// بوابة OTP: لا حفظ قبل التحقق.
  Future<void> _otpGate((String, DriverModel) res) async {
    final l = context.l10n;
    final e164 = PhoneNormalizer.toE164(phone.text, defaultCountryCode: OtpConfig.defaultCountryCode);
    if (e164 == null) {
      _fail(l.driverLoginPhoneInvalid, null, null);
      return;
    }
    final sent = await Get.find<OtpGateway>().send(e164);
    if (!mounted) return;
    await sent.fold((f) async => _fail(null, null, otpFailureText(l, f)), (_) async {
      setState(() => busy = false);
      (String, DriverModel)? pending = res; // في الذاكرة فقط
      await Get.toNamed('/otp', arguments: OtpArgs(
        phone: e164,
        alreadySent: true,
        title: l.driverOtpTitle,
        onVerified: () async {
          final p = pending;
          if (p != null) await _complete(p);
        },
      ));
      pending = null; // رجوع بلا تحقق ⇒ يُسقط الرمز المميّز
    });
  }

  /// مسار الحفظ السابق كما هو.
  Future<void> _complete((String, DriverModel) res) async {
    final s = Get.find<SessionStore>();
    await s.signIn(token: res.$1, userId: res.$2.id);
    await s.setRole('driver');
    PushService.maybe?.onSessionStarted();
    Get.find<RemoteConfigRepository>().app = 'driver';
    Get.find<RemoteConfigRepository>().load(refresh: true);
    Get.offAllNamed('/driver/home');
  }

  void _help({required String title, required String text}) {
    showDlg(context, icon: 'info', title: title, text: text, foot: [SBtn(context.l10n.commonOk, full: true, onTap: () => Get.back())]);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    if (_tried) _validate();
    return Page2(
      flush: true,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Entrance(index: 0, child: _Header(brand: l.driverLoginBrand, headline: l.driverLoginHeadline, subtitle: l.driverLoginSubtitle)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Entrance(
              index: 1,
              child: ShakeOnChange(
                trigger: _shake,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(Rad.l), border: Border.all(color: c.ln), boxShadow: c.cardShadow),
                  child: AutofillGroup(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      if (_generalErr != null) ...[
                        Semantics(liveRegion: true, child: Note('err', text: _generalErr!)),
                        const SizedBox(height: 16),
                      ],
                      Fld(
                        label: l.driverLoginPhone,
                        hint: '0599123456',
                        pre: '${OtpConfig.defaultCountryCode} 🇵🇸',
                        controller: phone,
                        focusNode: _phoneFocus,
                        keyboard: TextInputType.phone,
                        ltr: true,
                        error: _phoneErr,
                        ok: _tried && _phoneOk,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        onChanged: (_) => setState(() => _generalErr = null),
                        onSubmitted: (_) => _passFocus.requestFocus(),
                      ),
                      const SizedBox(height: 18),
                      Fld(
                        label: l.driverLoginPassword,
                        controller: pass,
                        focusNode: _passFocus,
                        obscure: !show,
                        error: _passErr,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onChanged: (_) => setState(() => _generalErr = null),
                        onSubmitted: (_) => _login(),
                        suffix: Semantics(
                          button: true,
                          label: show ? l.driverLoginHidePassword : l.driverLoginShowPassword,
                          child: InkResponse(
                            onTap: () => setState(() => show = !show),
                            radius: 24,
                            child: SizedBox.square(dimension: 48, child: Center(child: SIcon('eye', size: 20, color: show ? c.pri : c.tx2))),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Entrance(
              index: 2,
              child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, children: [
                _TextLink(l.driverLoginForgot, onTap: () => _help(title: l.driverLoginForgot, text: l.driverLoginForgotText)),
                _TextLink(l.driverLoginSupport, onTap: () => _help(title: l.driverLoginSupport, text: l.driverLoginSupportText)),
              ]),
            ),
            const SizedBox(height: 16),
            Entrance(index: 3, child: Text(l.driverLoginVersion(AppEnv.appVersion), textAlign: TextAlign.center, style: T.cap(c.tx3))),
          ]),
        ),
      ]),
      foot: Foot(child: SBtn(l.driverLoginSubmit, full: true, loading: busy, disabled: !_valid, onTap: _login)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.brand, required this.headline, required this.subtitle});
  final String brand;
  final String headline;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Rad.xl)),
        gradient: LinearGradient(begin: AlignmentDirectional.topStart, end: AlignmentDirectional.bottomEnd, colors: [c.hero, c.hero2]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const SatrLogo(width: 72),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: c.onHero.withValues(alpha: .12), borderRadius: BorderRadius.circular(999), border: Border.all(color: c.onHero.withValues(alpha: .25))),
            child: Text(brand, style: T.sm(c.onHero).copyWith(fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 22),
        Semantics(header: true, child: Text(headline, style: T.d2(c.onHero))),
        const SizedBox(height: 6),
        Text(subtitle, style: T.bd(c.onHero.withValues(alpha: .85))),
      ]),
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink(this.label, {required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Rad.s),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(widthFactor: 1, child: Text(label, style: T.sm(c.pri).copyWith(fontWeight: FontWeight.w700))),
          ),
        ),
      ),
    );
  }
}
