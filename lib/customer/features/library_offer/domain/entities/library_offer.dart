import 'package:equatable/equatable.dart';
import 'package:project/core/utils/money.dart';

/// عرض المكتبة (المشغّل) — يختلف عن تسعيرة الخادم قبل الطلب.
abstract final class OfferStatus {
  static const sent = 'sent';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const expired = 'expired';
  static const superseded = 'superseded';
}

class OfferSubstitute extends Equatable {
  const OfferSubstitute({required this.name, required this.unitPrice});

  final String name;
  final Money unitPrice;

  @override
  List<Object?> get props => [name, unitPrice];
}

class LibraryOfferItem extends Equatable {
  const LibraryOfferItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.available,
    required this.lineTotal,
    this.substitute,
    this.note,
  });

  final int id;
  final String name;
  final int qty;
  final Money unitPrice;
  final bool available;
  final OfferSubstitute? substitute;
  final Money lineTotal;
  final String? note;

  /// فرق سعر الوحدة للبديل (موجب = أغلى).
  Money? get substituteDifference => substitute == null
      ? null
      : Money(amount: substitute!.unitPrice.amount - unitPrice.amount);

  @override
  List<Object?> get props =>
      [id, name, qty, unitPrice, available, substitute, lineTotal, note];
}

class LibraryOffer extends Equatable {
  const LibraryOffer({
    required this.id,
    required this.orderId,
    required this.status,
    required this.items,
    required this.itemsTotal,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
    this.note,
    this.expiresAt,
  });

  final int id;
  final int orderId;
  final String status;
  final List<LibraryOfferItem> items;
  final Money itemsTotal;
  final Money deliveryFee;
  final Money total;
  final String? note;
  final DateTime? expiresAt;
  final DateTime createdAt;

  bool get hasSubstitutions =>
      items.any((i) => !i.available || i.substitute != null);

  bool isOpenAt(DateTime now) =>
      status == OfferStatus.sent &&
      (expiresAt == null || now.isBefore(expiresAt!));

  factory LibraryOffer.fromJson(Map<String, dynamic> json) => LibraryOffer(
        id: json['id'] as int,
        orderId: json['order_id'] as int,
        status: json['status'] as String? ?? '',
        items: [
          for (final raw in json['items'] as List? ?? const [])
            () {
              final i = Map<String, dynamic>.from(raw as Map);
              final sub = i['substitute'];
              return LibraryOfferItem(
                id: i['id'] as int,
                name: i['name'] as String? ?? '',
                qty: i['qty'] as int? ?? 1,
                unitPrice: Money.fromJson(i['unit_price']),
                available: i['available'] as bool? ?? true,
                lineTotal: Money.fromJson(i['line_total']),
                note: i['note'] as String?,
                substitute: sub is Map
                    ? OfferSubstitute(
                        name: sub['name'] as String? ?? '',
                        unitPrice: Money.fromJson(sub['unit_price']),
                      )
                    : null,
              );
            }(),
        ],
        itemsTotal: Money.fromJson(json['items_total']),
        deliveryFee: Money.fromJson(json['delivery_fee']),
        total: Money.fromJson(json['total']),
        note: json['note'] as String?,
        expiresAt: DateTime.tryParse('${json['expires_at']}')?.toLocal(),
        createdAt: DateTime.tryParse('${json['created_at']}')?.toLocal() ??
            DateTime.now(),
      );

  @override
  List<Object?> get props => [id, status, total, items, expiresAt];
}
