import 'package:equatable/equatable.dart';
import 'package:project/core/utils/money.dart';

/// الأجزاء التي يحتاجها مسار الشراء من GET /v1/app/config?app=user.
/// كل الخيارات والحدود والأسعار تأتي من هنا، لا من التصميم.
class RemoteConfig extends Equatable {
  const RemoteConfig({
    required this.configVersion,
    required this.currency,
    required this.paymentMethods,
    required this.printing,
    required this.transfer,
    required this.cartMaxLines,
    required this.cartMaxQty,
    required this.attachmentsMaxFiles,
    required this.substitutionOptions,
    required this.recipientPhonePattern,
    required this.offerTtlMinutes,
  });

  /// يُقرأ من الرد الناجح فقط؛ لا يُرسل كترويسة.
  final int configVersion;
  final CurrencyFormat currency;
  final List<String> paymentMethods;
  final PrintingConfig? printing;
  final TransferConfig? transfer;
  final int cartMaxLines;
  final int cartMaxQty;
  final int attachmentsMaxFiles;
  final List<FieldOption> substitutionOptions;
  final RegExp? recipientPhonePattern;
  final int? offerTtlMinutes;

  bool get supportsCash => paymentMethods.contains('cash_on_delivery');
  bool get supportsTransfer => paymentMethods.contains('bank_transfer');

  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    final modules = _map(json['modules_config']);
    final currency = _map(json['currency']);
    final orderProps = _map(_map(_map(json['fields'])['order'])['properties']);
    final pattern = _map(orderProps['recipient_phone'])['pattern'] as String?;
    final catalogCart = _map(_map(modules['catalog'])['cart']);
    return RemoteConfig(
      configVersion: json['config_version'] as int? ?? 0,
      currency: CurrencyFormat(
        symbol: currency['symbol'] as String? ?? '₪',
        minorUnits: currency['minor_units'] as int? ?? 100,
      ),
      paymentMethods: _strings(json['payment_methods']),
      printing: modules['printing'] is Map
          ? PrintingConfig.fromJson(_map(modules['printing']))
          : null,
      transfer: modules['bank_transfer'] is Map
          ? TransferConfig.fromJson(_map(modules['bank_transfer']))
          : null,
      cartMaxLines: catalogCart['max_lines'] as int? ?? 50,
      cartMaxQty: catalogCart['max_qty'] as int? ?? 99,
      attachmentsMaxFiles:
          _map(modules['attachments'])['max_files'] as int? ?? 10,
      substitutionOptions: FieldOption.listFrom(
        _map(orderProps['substitution_preference'])['x-masar-options'],
      ),
      recipientPhonePattern: pattern == null ? null : RegExp(pattern),
      offerTtlMinutes: _map(modules['approval'])['offer_ttl_minutes'] as int?,
    );
  }

  @override
  List<Object?> get props =>
      [configVersion, paymentMethods, printing, transfer];
}

class PrintingConfig extends Equatable {
  const PrintingConfig({
    required this.paperSizes,
    required this.bindings,
    required this.colors,
    required this.sides,
    required this.maxJobs,
    required this.maxCopies,
    required this.maxPages,
    required this.fileMimes,
    required this.maxFileBytes,
    required this.duplexDiscountPercent,
  });

  final List<PaperSizeOption> paperSizes;
  final List<BindingOption> bindings;

  /// قيم print_color المقبولة في print_items (مثل bw و color).
  final List<String> colors;

  /// قيم print_sides المقبولة في print_items (مثل single و double).
  final List<String> sides;
  final int maxJobs;
  final int maxCopies;
  final int maxPages;
  final List<String> fileMimes;
  final int maxFileBytes;
  final int duplexDiscountPercent;

  PaperSizeOption? paper(String key) =>
      paperSizes.where((p) => p.key == key).firstOrNull;
  BindingOption? binding(String key) =>
      bindings.where((b) => b.key == key).firstOrNull;

  factory PrintingConfig.fromJson(Map<String, dynamic> json) => PrintingConfig(
        paperSizes: [
          for (final p in _list(json['paper_sizes']))
            PaperSizeOption(
              key: p['key'] as String,
              label: p['label'] as String? ?? p['key'] as String,
              bwSidePrice: Money.fromJson(p['bw_page_price']),
              colorSidePrice: Money.fromJson(p['color_page_price']),
            ),
        ],
        bindings: [
          for (final b in _list(json['bindings']))
            BindingOption(
              key: b['key'] as String,
              label: b['label'] as String? ?? b['key'] as String,
              price: Money.fromJson(b['price']),
            ),
        ],
        colors: _strings(json['print_colors']),
        sides: _strings(json['print_sides']),
        maxJobs: json['max_jobs'] as int? ?? 20,
        maxCopies: json['max_copies'] as int? ?? 500,
        maxPages: json['max_pages'] as int? ?? 2000,
        fileMimes: _strings(json['file_mimes']),
        maxFileBytes: (json['max_file_mb'] as int? ?? 10) * 1024 * 1024,
        duplexDiscountPercent: json['duplex_discount_percent'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [paperSizes, bindings, colors, sides, maxJobs];
}

class PaperSizeOption extends Equatable {
  const PaperSizeOption({
    required this.key,
    required this.label,
    required this.bwSidePrice,
    required this.colorSidePrice,
  });

  final String key;
  final String label;

  /// السعر لكل وجه مطبوع (وليس لكل ورقة).
  final Money bwSidePrice;
  final Money colorSidePrice;

  @override
  List<Object?> get props => [key, label, bwSidePrice, colorSidePrice];
}

class BindingOption extends Equatable {
  const BindingOption({
    required this.key,
    required this.label,
    required this.price,
  });

  final String key;
  final String label;

  /// يُحسب لكل نسخة.
  final Money price;

  @override
  List<Object?> get props => [key, label, price];
}

class TransferConfig extends Equatable {
  const TransferConfig({
    required this.accounts,
    required this.instructions,
    required this.receiptMaxBytes,
    required this.receiptMimes,
  });

  final List<TransferAccount> accounts;
  final String? instructions;
  final int receiptMaxBytes;
  final List<String> receiptMimes;

  factory TransferConfig.fromJson(Map<String, dynamic> json) => TransferConfig(
        accounts: [
          for (final a in _list(json['accounts']))
            TransferAccount(
              kind: a['kind'] as String? ?? 'bank',
              provider: a['provider'] as String? ?? '',
              holder: a['holder'] as String? ?? '',
              number: a['number'] as String? ?? '',
              iban: a['iban'] as String?,
            ),
        ],
        instructions: json['instructions'] as String?,
        receiptMaxBytes: (json['receipt_max_mb'] as int? ?? 10) * 1024 * 1024,
        receiptMimes: _strings(json['receipt_mimes']),
      );

  @override
  List<Object?> get props => [accounts, instructions, receiptMaxBytes];
}

class TransferAccount extends Equatable {
  const TransferAccount({
    required this.kind,
    required this.provider,
    required this.holder,
    required this.number,
    this.iban,
  });

  /// bank أو wallet
  final String kind;
  final String provider;
  final String holder;
  final String number;
  final String? iban;

  @override
  List<Object?> get props => [kind, provider, holder, number, iban];
}

class FieldOption extends Equatable {
  const FieldOption(this.value, this.label);

  final String value;
  final String label;

  static List<FieldOption> listFrom(Object? raw) => [
        for (final o in _list(raw))
          FieldOption(o['value'] as String, o['label'] as String? ?? ''),
      ];

  @override
  List<Object?> get props => [value, label];
}

Map<String, dynamic> _map(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : const {};

List<Map<String, dynamic>> _list(Object? v) => v is List
    ? [
        for (final e in v)
          if (e is Map) Map<String, dynamic>.from(e)
      ]
    : const [];

List<String> _strings(Object? v) =>
    v is List ? [for (final e in v) '$e'] : const [];
