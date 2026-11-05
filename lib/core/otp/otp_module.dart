import 'package:project/core/config/otp_config.dart';
import 'package:project/core/otp/data/mock_otp_gateway.dart';
import 'package:project/core/otp/data/twilio_verify_gateway.dart';
import 'package:project/core/otp/domain/otp_gateway.dart';

/// يختار تنفيذ OtpGateway حسب OtpConfig.mode (يُستدعى من AppBinding).
OtpGateway createOtpGateway() => switch (OtpConfig.mode) {
      OtpMode.twilio => TwilioVerifyGateway(
          accountSid: OtpConfig.accountSid,
          authToken: OtpConfig.authToken,
          serviceSid: OtpConfig.serviceSid,
        ),
      OtpMode.mock => const MockOtpGateway(),
      OtpMode.unavailable => const UnavailableOtpGateway(),
    };
