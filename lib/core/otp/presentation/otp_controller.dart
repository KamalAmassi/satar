import 'dart:async';

import 'package:get/get.dart';
import 'package:project/core/config/otp_config.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/otp/domain/otp_gateway.dart';
import 'package:project/core/otp/presentation/otp_args.dart';
import 'package:project/core/utils/haptics.dart';

/// متحكم شاشة التحقق المشتركة. لا يعرف شيئًا عن الأدوار؛ النجاح يُسلَّم لـ [OtpArgs.onVerified].
class OtpController extends GetxController {
  OtpController(this.args, {OtpGateway? gateway, int? codeLength})
      : _gateway = gateway ?? Get.find<OtpGateway>(),
        codeLength = codeLength ?? OtpConfig.codeLength;

  final OtpArgs args;
  final OtpGateway _gateway;
  final int codeLength;

  final code = ''.obs;
  final verifying = false.obs;
  final sending = false.obs;
  final error = Rxn<Failure>();
  final resendIn = 0.obs;

  /// يزداد مع كل رمز خاطئ (يشغّل الاهتزاز في الواجهة).
  final shakeTick = 0.obs;

  /// يُرسَل للواجهة لمسح الحقل بعد الخطأ.
  final clearTick = 0.obs;

  /// معلومة عابرة بعد إعادة الإرسال.
  final resent = false.obs;

  Timer? _timer;
  bool _done = false;

  @override
  void onInit() {
    super.onInit();
    if (args.alreadySent) {
      _startCooldown();
    } else {
      resend(initial: true);
    }
  }

  void setCode(String v) {
    final digits = v.replaceAll(RegExp(r'\D'), '');
    code.value = digits.length > codeLength ? digits.substring(0, codeLength) : digits;
    if (error.value != null) error.value = null;
    if (code.value.length == codeLength) submit();
  }

  Future<void> submit() async {
    if (_done || verifying.value || code.value.length != codeLength) return;
    verifying.value = true;
    final r = await _gateway.verify(args.phone, code.value);
    if (isClosed) return;
    await r.fold((f) async {
      verifying.value = false;
      error.value = f;
      shakeTick.value++;
      Haptics.error();
      code.value = '';
      clearTick.value++;
    }, (_) async {
      _done = true;
      Haptics.success();
      await args.onVerified();
      if (!isClosed) verifying.value = false;
    });
  }

  Future<void> resend({bool initial = false}) async {
    if (sending.value || resendIn.value > 0 || _done) return;
    sending.value = true;
    error.value = null;
    final r = await _gateway.send(args.phone);
    if (isClosed) return;
    sending.value = false;
    r.fold((f) {
      error.value = f;
      Haptics.error();
    }, (_) {
      resent.value = !initial;
      _startCooldown();
    });
  }

  void _startCooldown() {
    _timer?.cancel();
    resendIn.value = OtpConfig.resendCooldown.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendIn.value <= 1) {
        resendIn.value = 0;
        t.cancel();
      } else {
        resendIn.value--;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
