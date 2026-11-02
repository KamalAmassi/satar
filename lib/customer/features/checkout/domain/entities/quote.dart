import 'package:equatable/equatable.dart';
import 'package:project/core/utils/money.dart';

class PriceLine extends Equatable {
  const PriceLine({
    required this.key,
    required this.kind,
    required this.label,
    required this.amount,
  });

  final String key;
  final String kind;
  final String label;
  final Money amount;

  @override
  List<Object?> get props => [key, kind, label, amount];
}

/// تسعيرة الخادم: صالحة لمرة واحدة ولمدة محدودة، ومرتبطة ببصمة المدخلات.
class Quote extends Equatable {
  const Quote({
    required this.token,
    required this.expiresIn,
    required this.receivedAt,
    required this.breakdown,
    required this.itemsTotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.configVersion,
    required this.fingerprint,
    this.expiresAt,
    this.distanceKm,
  });

  final String token;

  /// ثوانٍ من لحظة الاستلام؛ يعتمد عليها التطبيق بدل ساعة الجهاز.
  final int expiresIn;
  final DateTime receivedAt;
  final DateTime? expiresAt;
  final List<PriceLine> breakdown;
  final Money itemsTotal;
  final Money deliveryFee;
  final Money discount;
  final Money total;

  /// كما أعاده الخادم (cash أو bank_transfer).
  final String paymentMethod;
  final int configVersion;
  final double? distanceKm;

  /// بصمة المدخلات التي سُعّرت.
  final String fingerprint;

  /// هامش أمان قبل الانتهاء الفعلي لتجنب إرسال تسعيرة على وشك الانتهاء.
  static const safetyMargin = Duration(seconds: 15);

  DateTime get localExpiry =>
      receivedAt.add(Duration(seconds: expiresIn)).subtract(safetyMargin);

  bool isExpiredAt(DateTime now) => !now.isBefore(localExpiry);

  Duration remainingAt(DateTime now) {
    final d = localExpiry.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  /// تغيّر أي مبلغ يراه الزبون (الإجماليات أو بنود التفصيل).
  /// الرمز والصلاحية والبصمة لا تدخل: تتغيّر مع كل تسعيرة جديدة.
  bool pricesDifferFrom(Quote other) =>
      total.amount != other.total.amount ||
      itemsTotal.amount != other.itemsTotal.amount ||
      deliveryFee.amount != other.deliveryFee.amount ||
      discount.amount != other.discount.amount ||
      !_sameAmounts(breakdown, other.breakdown);

  static bool _sameAmounts(List<PriceLine> a, List<PriceLine> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].key != b[i].key || a[i].amount.amount != b[i].amount.amount) {
        return false;
      }
    }
    return true;
  }

  @override
  List<Object?> get props => [token, fingerprint, total];
}
