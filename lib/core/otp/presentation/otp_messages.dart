import 'package:project/core/errors/failure.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/otp/domain/otp_failures.dart';

/// رسالة مميزة لكل إخفاق تحقق (عربي/إنجليزي عبر ARB).
String otpFailureText(AppLocalizations l, Failure f) => switch (f) {
      OtpInvalidCode() => l.otpErrInvalid,
      OtpExpired() => l.otpErrExpired,
      OtpTooManyAttempts() => l.otpErrTooMany,
      OtpPhoneNotAllowed() => l.otpErrPhone,
      OtpNetwork() => l.otpErrNetwork,
      _ => l.otpErrUnavailable,
    };
