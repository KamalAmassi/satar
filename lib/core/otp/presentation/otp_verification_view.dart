import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project/core/config/otp_config.dart';
import 'package:project/core/design/motion.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/motion/entrance.dart';
import 'package:project/core/motion/motion_settings.dart';
import 'package:project/core/otp/presentation/otp_args.dart';
import 'package:project/core/otp/presentation/otp_controller.dart';
import 'package:project/core/otp/presentation/otp_messages.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/utils/phone_normalizer.dart';
import 'package:project/core/widgets/auth_header.dart' show AuthRole;
import 'package:project/core/widgets/auth_shell.dart';

/// شاشة التحقق المشتركة (/otp) للعميل والسائق. الوسائط: [OtpArgs].
class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final OtpArgs? _args = Get.arguments is OtpArgs ? Get.arguments as OtpArgs : null;
  late final String _tag = 'otp-${identityHashCode(this)}';
  final _text = TextEditingController();
  final _focus = FocusNode();
  OtpController? _ctl;
  Worker? _clear;

  @override
  void initState() {
    super.initState();
    final a = _args;
    if (a == null) return;
    final ctl = Get.put(OtpController(a), tag: _tag);
    _ctl = ctl;
    _clear = ever<int>(ctl.clearTick, (_) {
      _text.clear();
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _clear?.dispose();
    if (_ctl != null) Get.delete<OtpController>(tag: _tag);
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    final ctl = _ctl;
    final a = _args;
    if (ctl == null || a == null) {
      return Page2(
        top: TopBar(title: l.otpTitle),
        center: true,
        body: EmptyState(ill: 'offline', title: l.otpErrUnavailable, text: '', cta: SBtn(l.commonClose, full: true, onTap: () => Get.back())),
      );
    }
    // عزل اتجاه الرقم داخل النص العربي.
    final masked = '${String.fromCharCode(0x2066)}${PhoneNormalizer.mask(a.phone)}${String.fromCharCode(0x2069)}'; // عزل LTR

    final chosen = Get.isRegistered<SessionStore>() ? Get.find<SessionStore>().chosenRole : null;
    return AuthShell(
      role: chosen == 'driver' ? AuthRole.driver : chosen == 'customer' ? AuthRole.customer : null,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Entrance(index: 0, child: AuthTitle(title: a.title ?? l.otpHeadline, subtitle: Text(l.otpSubtitle(masked)))),
        if (kDebugMode && OtpConfig.usingDevFallback) ...[
          const SizedBox(height: 16),
          Note('warn', text: l.otpDevMockNotice),
        ],
        const SizedBox(height: 28),
        Entrance(
          index: 2,
          child: Obx(() => ShakeOnChange(
                trigger: ctl.shakeTick.value,
                child: _CodeBoxes(
                  controller: _text,
                  focus: _focus,
                  length: ctl.codeLength,
                  value: ctl.code.value,
                  hasError: ctl.error.value != null,
                  enabled: !ctl.verifying.value,
                  semanticsLabel: l.otpCodeSemantics(ctl.codeLength),
                  onChanged: ctl.setCode,
                  onSubmitted: ctl.submit,
                ),
              )),
        ),
        Obx(() {
          final e = ctl.error.value;
          return Semantics(
            liveRegion: true,
            child: AnimatedSize(
              duration: MotionSettings.of(context).reduceMotion ? Duration.zero : Motion.short,
              child: e == null
                  ? (ctl.resent.value ? Padding(padding: const EdgeInsets.only(top: 12), child: Text(l.otpResent, style: T.sm(c.tx2))) : const SizedBox(width: double.infinity))
                  : Padding(padding: const EdgeInsets.only(top: 12), child: Text(otpFailureText(l, e), style: T.sm(c.err))),
            ),
          );
        }),
        const SizedBox(height: 20),
        Entrance(
          index: 3,
          child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, children: [
            Obx(() => ctl.resendIn.value > 0
                ? ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Align(widthFactor: 1, child: Text(l.otpResendIn(ctl.resendIn.value), style: T.sm(c.tx3))),
                  )
                : _LinkButton(label: l.otpResend, busy: ctl.sending.value, onTap: ctl.resend)),
            _LinkButton(label: l.otpChangeNumber, onTap: () => Get.back()),
          ]),
        ),
      ]),
      foot: Foot(
        child: Obx(() => SBtn(
              l.otpVerify,
              full: true,
              loading: ctl.verifying.value,
              disabled: ctl.code.value.length != ctl.codeLength,
              onTap: ctl.submit,
            )),
      ),
    );
  }
}

/// مربعات الرمز: حقل واحد شفاف فوقها (لصق، إكمال تلقائي من SMS على iOS، ولوحة أرقام).
class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({
    required this.controller,
    required this.focus,
    required this.length,
    required this.value,
    required this.hasError,
    required this.enabled,
    required this.semanticsLabel,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final int length;
  final String value;
  final bool hasError;
  final bool enabled;
  final String semanticsLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final reduce = MotionSettings.of(context).reduceMotion;
    // الأرقام دائمًا من اليسار لليمين حتى في صفحة عربية.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Stack(children: [
            ExcludeSemantics(
              child: Row(children: [
                for (var i = 0; i < length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedContainer(
                        duration: reduce ? Duration.zero : Motion.short,
                        height: 58,
                        decoration: BoxDecoration(
                          color: i == value.length && focus.hasFocus ? c.sf : c.sf2,
                          borderRadius: BorderRadius.circular(Rad.m),
                          border: Border.all(
                            width: 2,
                            color: hasError ? c.err : (i == value.length ? c.pri : (i < value.length ? c.ln : Colors.transparent)),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(child: Text(i < value.length ? value[i] : '', style: T.h1(c.tx))),
                      ),
                    ),
                  ),
              ]),
            ),
            Positioned.fill(
              child: TextField(
                controller: controller,
                focusNode: focus,
                enabled: enabled,
                autofocus: true,
                showCursor: false,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(length)],
                onChanged: onChanged,
                onSubmitted: (_) => onSubmitted(),
                style: const TextStyle(color: Colors.transparent),
                cursorColor: Colors.transparent,
                decoration: InputDecoration.collapsed(hintText: semanticsLabel, hintStyle: const TextStyle(color: Colors.transparent)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// رابط نصي بهدف لمس 48dp.
class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.label, required this.onTap, this.busy = false});

  final String label;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Semantics(
      button: true,
      enabled: !busy,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(Rad.s),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(widthFactor: 1, child: Text(label, style: T.sm(busy ? c.tx3 : c.pri).copyWith(fontWeight: FontWeight.w700))),
          ),
        ),
      ),
    );
  }
}
