import 'package:equatable/equatable.dart';

/// مبلغ بالوحدة الصغرى (أغورة) كما يرسله الخادم. لا أعداد عشرية.
class Money extends Equatable {
  const Money({required this.amount, this.formatted});

  /// المبلغ بالوحدة الصغرى.
  final int amount;

  /// النص المنسّق من الخادم (مثل "8.90 ₪") إن وُجد.
  final String? formatted;

  static const zero = Money(amount: 0);

  factory Money.fromJson(Object? json) {
    if (json is Map) {
      final raw = json['amount'];
      return Money(
        amount: raw is int ? raw : int.tryParse('$raw') ?? 0,
        formatted: json['formatted'] as String?,
      );
    }
    return zero;
  }

  Money operator +(Money other) => Money(amount: amount + other.amount);
  Money operator -(Money other) => Money(amount: amount - other.amount);
  Money times(int factor) => Money(amount: amount * factor);

  bool get isNegative => amount < 0;

  /// يفضّل نص الخادم، وإلا يحسب من الوحدات الصغرى بعمليات صحيحة فقط.
  String display(CurrencyFormat currency) =>
      formatted ?? currency.format(amount);

  @override
  List<Object?> get props => [amount, formatted];
}

/// تنسيق محلي احتياطي من إعدادات العملة في /app/config.
class CurrencyFormat extends Equatable {
  const CurrencyFormat({this.symbol = '₪', this.minorUnits = 100});

  final String symbol;
  final int minorUnits;

  String format(int amount) {
    final negative = amount < 0;
    final abs = amount.abs();
    final digits = minorUnits <= 1 ? 0 : '${minorUnits - 1}'.length;
    if (digits == 0) return '${negative ? '-' : ''}$abs $symbol';
    final major = abs ~/ minorUnits;
    final minor = (abs % minorUnits).toString().padLeft(digits, '0');
    return '${negative ? '-' : ''}$major.$minor $symbol';
  }

  @override
  List<Object?> get props => [symbol, minorUnits];
}
