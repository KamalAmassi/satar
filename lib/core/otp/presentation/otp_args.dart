/// وسائط شاشة التحقق المشتركة (/otp). لا شيء خاص بدور العميل أو السائق هنا.
class OtpArgs {
  const OtpArgs({
    required this.phone,
    required this.onVerified,
    this.title,
    this.alreadySent = false,
  });

  /// رقم بصيغة E.164.
  final String phone;

  /// يُستدعى مرة واحدة بعد نجاح التحقق (حفظ الجلسة والتنقل مسؤولية المستدعي).
  final Future<void> Function() onVerified;
  final String? title;

  /// true إن أرسل المستدعي الرمز قبل فتح الشاشة (تبدأ العدّاد مباشرة).
  final bool alreadySent;
}
