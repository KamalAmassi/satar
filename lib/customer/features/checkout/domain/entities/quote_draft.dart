import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/customer/features/checkout/domain/entities/checkout_details.dart';
import 'package:project/customer/features/checkout/domain/entities/pickup_point.dart';
import 'package:project/customer/features/printing/domain/entities/page_range.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';

enum DraftBlocker {
  emptyCart,
  uploadsPending,
  uploadsFailed,
  invalidPageRange,
  missingAddress,
  missingPaymentMethod,
}

/// جسم طلب التسعيرة كما سيُرسل بالضبط، مع بصمته.
///
/// الخادم يربط quote_token بنفس البيانات بالضبط؛ أي اختلاف في البصمة يعني
/// أن التسعيرة لم تعد صالحة لهذا المحتوى.
class QuoteDraft extends Equatable {
  const QuoteDraft._({
    required this.body,
    required this.fingerprint,
    required this.orderType,
    required this.productIndexToLineId,
    required this.printIndexToJobId,
    required this.productRevisions,
    required this.printRevisions,
  });

  final Map<String, dynamic> body;
  final String fingerprint;

  /// products أو printing أو mixed حسب المحتوى الفعلي.
  final String orderType;
  final Map<int, String> productIndexToLineId;
  final Map<int, String> printIndexToJobId;
  final Map<String, int> productRevisions;
  final Map<String, int> printRevisions;

  static String orderTypeFor({required bool products, required bool printing}) {
    if (products && printing) return 'mixed';
    return printing ? 'printing' : 'products';
  }

  /// يعيد قائمة الموانع إن لم يكن الطلب جاهزًا للتسعير.
  static (QuoteDraft?, Set<DraftBlocker>) build({
    required List<CartProductLine> products,
    required List<PrintJob> printJobs,
    required String? substitutionPreference,
    required CheckoutDetails details,
    PickupPoint? pickup,
  }) {
    pickup ??= PickupPoint.library;
    final blockers = <DraftBlocker>{};
    if (products.isEmpty && printJobs.isEmpty) {
      blockers.add(DraftBlocker.emptyCart);
    }
    if (printJobs.any((j) => j.status == UploadStatus.uploading)) {
      blockers.add(DraftBlocker.uploadsPending);
    }
    if (printJobs.any((j) => j.needsAttention)) {
      blockers.add(DraftBlocker.uploadsFailed);
    }
    if (printJobs.any(
      (j) => !PageRange.isValid(j.spec.pageRange, totalPages: j.knownPages),
    )) {
      blockers.add(DraftBlocker.invalidPageRange);
    }
    if (details.addressId == null) blockers.add(DraftBlocker.missingAddress);
    if (details.paymentMethod == null) {
      blockers.add(DraftBlocker.missingPaymentMethod);
    }
    if (blockers.isNotEmpty) return (null, blockers);

    final orderType = orderTypeFor(
      products: products.isNotEmpty,
      printing: printJobs.isNotEmpty,
    );
    final fields = <String, dynamic>{'order_type': orderType};
    if (products.isNotEmpty && substitutionPreference != null) {
      fields['substitution_preference'] = substitutionPreference;
    }
    void putText(String key, String value) {
      final v = value.trim();
      if (v.isNotEmpty) fields[key] = v;
    }

    putText('recipient_name', details.recipientName);
    putText('recipient_phone', details.recipientPhone.replaceAll(' ', ''));
    putText('delivery_notes', details.deliveryNotes);

    final productIndex = <int, String>{};
    final printIndex = <int, String>{};
    final body = <String, dynamic>{
      'pickup': pickup.toJson(),
      'dropoff_address_id': details.addressId,
      'payment_method': details.paymentMethod,
      'fields': fields,
      if (products.isNotEmpty)
        'cart': [
          for (final (i, line) in products.indexed)
            () {
              productIndex[i] = line.id;
              return {
                'product_id': line.productId,
                'qty': line.quantity,
                if (line.options.isNotEmpty)
                  'options': {
                    for (final e in line.options.entries)
                      e.key: e.value.length == 1 ? e.value.single : e.value,
                  },
                if (line.note.trim().isNotEmpty) 'note': line.note.trim(),
              };
            }(),
        ],
      if (printJobs.isNotEmpty)
        'print_items': [
          for (final (i, job) in printJobs.indexed)
            () {
              printIndex[i] = job.id;
              final range = PageRange.toRequest(job.spec.pageRange);
              final notes = job.spec.notes.trim();
              return {
                'print_file': job.uploadId,
                'paper_size': job.spec.paperSize,
                'print_color': job.spec.color,
                'print_sides': job.spec.sides,
                'print_copies': job.spec.copies,
                'binding_type': job.spec.binding,
                if (range != null) 'print_page_range': range,
                if (notes.isNotEmpty) 'print_specifications': notes,
              };
            }(),
        ],
    };

    return (
      QuoteDraft._(
        body: body,
        fingerprint: canonicalJson(body),
        orderType: orderType,
        productIndexToLineId: productIndex,
        printIndexToJobId: printIndex,
        productRevisions: {for (final l in products) l.id: l.revision},
        printRevisions: {for (final j in printJobs) j.id: j.revision},
      ),
      const <DraftBlocker>{},
    );
  }

  /// JSON بمفاتيح مرتبة حتى تكون البصمة ثابتة.
  static String canonicalJson(Object? value) {
    Object? sort(Object? v) {
      if (v is Map) {
        final keys = v.keys.map((k) => '$k').toList()..sort();
        return {for (final k in keys) k: sort(v[k])};
      }
      if (v is List) return [for (final e in v) sort(e)];
      return v;
    }

    return jsonEncode(sort(value));
  }

  @override
  List<Object?> get props => [fingerprint];
}
