import 'package:equatable/equatable.dart';
import 'package:project/core/utils/money.dart';

/// حالات الطلب التي يتعامل معها مسار الشراء.
abstract final class OrderStatusKey {
  static const awaitingPricing = 'awaiting_pricing';
  static const priced = 'priced';
  static const pending = 'pending';
  static const awaitingPayment = 'awaiting_payment';
  static const paymentReview = 'payment_review';
  static const cancelled = 'cancelled';
}

class FileRef extends Equatable {
  const FileRef({required this.uploadId, required this.mime, this.url});

  final int uploadId;
  final String mime;

  /// رابط موقّع مؤقت (10 دقائق).
  final String? url;

  static FileRef? fromJson(Object? json) {
    if (json is! Map || json['upload_id'] == null) return null;
    return FileRef(
      uploadId: json['upload_id'] as int,
      mime: json['mime'] as String? ?? '',
      url: json['url'] as String?,
    );
  }

  @override
  List<Object?> get props => [uploadId, mime, url];
}

class OrderAction extends Equatable {
  const OrderAction({required this.action, required this.label, this.confirm});

  final String action;
  final String label;
  final String? confirm;

  @override
  List<Object?> get props => [action, label, confirm];
}

/// ما يحتاجه مسار الشراء من GET /v1/orders/{id}.
/// تفاصيل الطلب الكاملة والتتبع ضمن ميزة إيمان.
class PlacedOrder extends Equatable {
  const PlacedOrder({
    required this.id,
    required this.code,
    required this.statusKey,
    required this.statusLabel,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.total,
    this.reviewNote,
    this.receipt,
    this.actions = const [],
  });

  final int id;
  final String code;
  final String statusKey;
  final String statusLabel;

  /// cash أو bank_transfer
  final String paymentMethod;

  /// cash_on_delivery أو transfer_pending أو transfer_review أو paid…
  final String paymentStatus;
  final Money total;

  /// ملاحظة مراجعة المكتبة (طلب تصحيح الإشعار).
  final String? reviewNote;
  final FileRef? receipt;
  final List<OrderAction> actions;

  bool get isTransfer => paymentMethod == 'bank_transfer';

  /// الإرسال مسموح فقط في awaiting_payment لطلب تحويل.
  bool get canSubmitReceipt =>
      isTransfer && statusKey == OrderStatusKey.awaitingPayment;

  bool get isReceiptUnderReview => statusKey == OrderStatusKey.paymentReview;

  bool get needsCorrection =>
      canSubmitReceipt && (reviewNote?.trim().isNotEmpty ?? false);

  factory PlacedOrder.fromJson(Map<String, dynamic> json) {
    final status =
        Map<String, dynamic>.from(json['status'] as Map? ?? const {});
    final payment =
        Map<String, dynamic>.from(json['payment'] as Map? ?? const {});
    final fields =
        Map<String, dynamic>.from(json['fields'] as Map? ?? const {});
    final price = Map<String, dynamic>.from(json['price'] as Map? ?? const {});
    return PlacedOrder(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      statusKey: status['key'] as String? ?? '',
      statusLabel: status['label'] as String? ?? '',
      paymentMethod: payment['method'] as String? ?? '',
      paymentStatus: payment['status'] as String? ?? '',
      total: Money.fromJson(price['total']),
      reviewNote: (payment['review_note'] as String?) ??
          (fields['payment_review_note'] as String?),
      receipt: FileRef.fromJson(fields['payment_receipt']),
      actions: [
        for (final a in json['available_actions'] as List? ?? const [])
          OrderAction(
            action: (a as Map)['action'] as String? ?? '',
            label: a['label'] as String? ?? '',
            confirm: a['confirm'] as String?,
          ),
      ],
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        statusKey,
        paymentMethod,
        paymentStatus,
        total,
        reviewNote,
        receipt
      ];
}
