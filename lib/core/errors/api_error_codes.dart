/// أكواد الأخطاء القادمة من السيرفر (error.code) — مطابقة لملفات الـ ARB.
abstract final class ApiErrorCodes {
  static const missingProjectKey = 'missing_project_key';
  static const invalidProjectKey = 'invalid_project_key';
  static const unauthenticated = 'unauthenticated';
  static const otpInvalid = 'otp_invalid';
  static const otpExpired = 'otp_expired';
  static const forbidden = 'forbidden';
  static const moduleDisabled = 'module_disabled';
  static const projectFrozen = 'project_frozen';
  static const projectInactive = 'project_inactive';
  static const userBlocked = 'user_blocked';
  static const notFound = 'not_found';
  static const methodNotAllowed = 'method_not_allowed';
  static const alreadyTaken = 'already_taken';
  static const conflict = 'conflict';
  static const bidClosed = 'bid_closed';
  static const idempotencyMismatch = 'idempotency_mismatch';
  static const quoteExpired = 'quote_expired';
  static const quoteUsed = 'quote_used';
  static const validationFailed = 'validation_failed';
  static const invalidTransition = 'invalid_transition';
  static const outOfZone = 'out_of_zone';
  static const outOfStock = 'out_of_stock';
  static const slotFull = 'slot_full';
  static const cashLimitReached = 'cash_limit_reached';
  static const vendorClosed = 'vendor_closed';
  static const appUpdateRequired = 'app_update_required';
  static const tooManyRequests = 'too_many_requests';
  static const serverError = 'server_error';
  static const maintenance = 'maintenance';
  static const chaosInjected = 'chaos_injected';

  /// أخطاء تمنع استخدام التطبيق كله (شاشة حجب عامة وليس رسالة عابرة).
  static const blocking = {
    invalidProjectKey,
    projectFrozen,
    projectInactive,
    userBlocked,
    appUpdateRequired,
    maintenance,
  };
}