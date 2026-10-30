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
  });

  /// عقد العناوين → الدفع: معرّف عنوان محفوظ فقط.
  final int? addressId;
  final String recipientName;
  final String recipientPhone;
  final String deliveryNotes;
  final String? paymentMethod;

  CheckoutDetails copyWith({
    int? addressId,
    String? recipientName,
    String? recipientPhone,
    String? deliveryNotes,
    String? paymentMethod,
  }) =>
      CheckoutDetails(
        addressId: addressId ?? this.addressId,
        recipientName: recipientName ?? this.recipientName,
        recipientPhone: recipientPhone ?? this.recipientPhone,
        deliveryNotes: deliveryNotes ?? this.deliveryNotes,
        paymentMethod: paymentMethod ?? this.paymentMethod,
      );

  @override
  List<Object?> get props =>
      [addressId, recipientName, recipientPhone, deliveryNotes, paymentMethod];
}
