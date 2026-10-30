import 'package:equatable/equatable.dart';

/// عنوان كما تحتاجه صفحة الدفع (قراءة فقط من ميزة العناوين).
class CheckoutAddress extends Equatable {
  const CheckoutAddress({
    required this.id,
    required this.isDefault,
    this.label,
    this.details,
  });

  final int id;
  final String? label;
  final String? details;
  final bool isDefault;

  factory CheckoutAddress.fromJson(Map<String, dynamic> json) =>
      CheckoutAddress(
        id: json['id'] as int,
        label: json['label'] as String?,
        details: json['details'] as String?,
        isDefault: json['is_default'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, label, details, isDefault];
}
