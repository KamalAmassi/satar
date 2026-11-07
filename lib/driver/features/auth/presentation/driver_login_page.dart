import 'package:flutter/material.dart';
import 'package:project/core/widgets/change_role_link.dart';
import 'package:project/core/services/push/push_service.dart';
import 'package:get/get.dart';
import 'package:project/core/config/app_env.dart';
import 'package:project/core/config/otp_config.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
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
import 'package:project/core/data/models.dart';
import 'package:project/core/widgets/auth_header.dart';
import 'package:project/core/widgets/auth_shell.dart';
import 'package:project/core/widgets/common_widgets.dart';

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
      (String, DriverModel)? pending = res;
      await Get.toNamed('/otp', arguments: OtpArgs(
        phone: e164,
        alreadySent: true,
        title: l.driverOtpTitle,
        onVerified: () async {
          final p = pending;
          if (p != null) await _complete(p);
        },
      ));
      pending = null;
    });
  }

  Future<void> _complete((String, DriverModel) res) async {
    final s = Get.find<SessionStore>();
    await s.signIn(token: res.$1, userId: res.$2.id, role: 'driver');
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
    return AuthShell(
      role: AuthRole.driver,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Entrance(index: 0, child: AuthTitle(title: l.driverLoginHeadline, subtitle: Text(l.driverLoginSubtitle))),
        const SizedBox(height: 20),
        Entrance(
          index: 1,
          child: ShakeOnChange(
            trigger: _shake,
            child: AutofillGroup(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (_generalErr != null) ...[
                  Semantics(liveRegion: true, child: Note('err', text: _generalErr!)),
                  const SizedBox(height: 16),
                ],
                Fld(
                  label: l.driverLoginPhone,
                  hint: '05XX XXX XXX',
                  pre: OtpConfig.defaultCountryCode,
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
                const SizedBox(height: 16),
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
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: _TextLink(l.driverLoginForgot, onTap: () => _help(title: l.driverLoginForgot, text: l.driverLoginForgotText)),
        ),
        const SizedBox(height: 8),
        const ChangeRoleLink(),
      ]),
      foot: Foot(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SBtn(l.driverLoginSubmit, full: true, loading: busy, disabled: !_valid, onTap: _login),
          const SizedBox(height: 4),
          Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
            _TextLink(l.driverLoginSupport, onTap: () => _help(title: l.driverLoginSupport, text: l.driverLoginSupportText)),
            Text('·', style: T.cap(c.tx3)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(l.driverLoginVersion(AppEnv.appVersion), style: T.cap(c.tx2))),
          ]),
        ]),
      ),
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
