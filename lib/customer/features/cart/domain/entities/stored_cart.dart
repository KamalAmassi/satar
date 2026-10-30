import 'package:equatable/equatable.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';

/// محتوى السلة المحفوظ لمستخدم واحد.
class StoredCart extends Equatable {
  const StoredCart({
    this.products = const [],
    this.printJobs = const [],
    this.substitutionPreference,
    this.note = '',
  });

  final List<CartProductLine> products;
  final List<PrintJob> printJobs;
  final String? substitutionPreference;

  /// ملاحظة للمكتبة؛ تُرسل مع إنشاء الطلب (note) لا مع التسعيرة.
  final String note;

  Map<String, dynamic> toJson() => {
        'products': [for (final p in products) p.toJson()],
        'print_jobs': [for (final j in printJobs) j.toJson()],
        'substitution_preference': substitutionPreference,
        'note': note,
      };

  factory StoredCart.fromJson(Map<String, dynamic> json) => StoredCart(
        products: [
          for (final p in json['products'] as List? ?? const [])
            CartProductLine.fromJson(Map<String, dynamic>.from(p as Map)),
        ],
        printJobs: [
          for (final j in json['print_jobs'] as List? ?? const [])
            PrintJob.fromJson(Map<String, dynamic>.from(j as Map)),
        ],
        substitutionPreference: json['substitution_preference'] as String?,
        note: json['note'] as String? ?? '',
      );

  @override
  List<Object?> get props =>
      [products, printJobs, substitutionPreference, note];
}
