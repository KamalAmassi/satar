import 'package:equatable/equatable.dart';

abstract final class PaymentMethod {
  static const cash = 'cash_on_delivery';
  static const transfer = 'bank_transfer';
}

/// مدخلات صفحة التوصيل والدفع.
class CheckoutDetails extends Equatable {
  const CheckoutDetails({
    this.addressId,
    this.recipientName = '',
    this.recipientPhone = '',
    this.deliveryNotes = '',
    this.paymentMethod,
    this.scheduledFor,
    this.coupon = '',
  });

  /// عقد العناوين → الدفع: معرّف عنوان محفوظ فقط.
  final int? addressId;
  final String recipientName;
  final String recipientPhone;
  final String deliveryNotes;
  final String? paymentMethod;

  /// scheduled_for (اختياري): null = في أقرب وقت.
  final DateTime? scheduledFor;
  final String coupon;

  CheckoutDetails copyWith({
    int? addressId,
    String? recipientName,
    String? recipientPhone,
    String? deliveryNotes,
    String? paymentMethod,
    DateTime? scheduledFor,
    bool clearSchedule = false,
    String? coupon,
  }) =>
      CheckoutDetails(
        addressId: addressId ?? this.addressId,
        recipientName: recipientName ?? this.recipientName,
        recipientPhone: recipientPhone ?? this.recipientPhone,
        deliveryNotes: deliveryNotes ?? this.deliveryNotes,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        scheduledFor: clearSchedule ? null : (scheduledFor ?? this.scheduledFor),
        coupon: coupon ?? this.coupon,
      );

  @override
  List<Object?> get props =>
      [addressId, recipientName, recipientPhone, deliveryNotes, paymentMethod, scheduledFor, coupon];
}
