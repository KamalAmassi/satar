import 'package:project/core/errors/failure.dart';

/// المساعد غير متاح (مفتاح مفقود/خاطئ، موديل غير موجود...).
class AiUnavailableFailure extends Failure {
  const AiUnavailableFailure({super.message});
}

/// تجاوز حد الاستخدام المجاني (429).
class AiQuotaFailure extends Failure {
  const AiQuotaFailure() : super(statusCode: 429);
}