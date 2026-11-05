import 'package:project/core/utils/money.dart';

/// أول حرف من النص (للأفاتار) أو «س».
String firstCh(String? s) {
  final t = (s ?? '').trim();
  return t.isEmpty ? 'س' : String.fromCharCode(t.runes.first);
}

/// نماذج الاستجابات (OpenAPI · components.schemas). لا أسعار تُحسب هنا.

Map<String, dynamic> jm(Object? v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
List<Map<String, dynamic>> jl(Object? v) =>
    v is List ? [for (final e in v) if (e is Map) Map<String, dynamic>.from(e)] : <Map<String, dynamic>>[];
DateTime? jd(Object? v) => v == null ? null : DateTime.tryParse('$v')?.toLocal();
double? jn(Object? v) => v is num ? v.toDouble() : double.tryParse('$v');

class UserModel {
  const UserModel({required this.id, this.name, required this.phone, this.avatarUrl, this.locale = 'ar', this.hasFcmToken});
  final bool? hasFcmToken;
  final int id;
  final String? name;
  final String phone;
  final String? avatarUrl;
  final String locale;
  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
      hasFcmToken: j['has_fcm_token'] as bool?,
      id: j['id'] as int,
      name: j['name'] as String?,
      phone: j['phone'] as String? ?? '',
      avatarUrl: j['avatar_url'] as String?,
      locale: j['locale'] as String? ?? 'ar');
  String get initial => firstCh(name);
}

class AuthResult {
  const AuthResult({required this.token, required this.isNewUser, required this.user});
  final String token;
  final bool isNewUser;
  final UserModel user;
}

class CategoryModel {
  const CategoryModel({required this.id, required this.name, this.icon, this.productsCount = 0});
  final int id;
  final String name;
  final String? icon;
  final int productsCount;
  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
      id: j['id'] as int,
      name: j['name'] as String? ?? '',
      icon: j['icon'] as String?,
      productsCount: j['products_count'] as int? ?? 0);
}

class ChoiceModel {
  const ChoiceModel(this.key, this.label, this.price);
  final String key;
  final String label;
  final Money price;
}

class OptionModel {
  const OptionModel({required this.key, required this.label, required this.multi, required this.required, required this.choices});
  final String key;
  final String label;
  final bool multi;
  final bool required;
  final List<ChoiceModel> choices;
}

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
    this.comparePrice,
    required this.inStock,
    this.stock,
    this.categoryId,
    this.kind = 'product',
    this.priceMode = 'fixed',
    this.options = const [],
  });
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final Money price;
  final Money? comparePrice;
  final bool inStock;
  final int? stock;
  final int? categoryId;
  final String kind;
  final String priceMode;
  final List<OptionModel> options;

  bool get isService => kind == 'service';
  bool get isInspection => priceMode == 'inspection';
  bool get hasRequiredOptions => options.any((o) => o.required);
  int get maxQty => stock == null ? 99 : (stock! < 1 ? 1 : (stock! > 99 ? 99 : stock!));
  int? get discountPct {
    final was = comparePrice?.amount;
    if (was == null || was <= price.amount || was == 0) return null;
    return ((1 - price.amount / was) * 100).round();
  }

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        description: j['description'] as String?,
        imageUrl: j['image_url'] as String?,
        price: Money.fromJson(j['price']),
        comparePrice: j['compare_at_price'] == null ? null : Money.fromJson(j['compare_at_price']),
        inStock: j['in_stock'] as bool? ?? true,
        stock: j['stock'] as int?,
        categoryId: j['category_id'] as int?,
        kind: j['kind'] as String? ?? 'product',
        priceMode: j['price_mode'] as String? ?? 'fixed',
        options: [
          for (final o in jl(j['options']))
            OptionModel(
              key: o['key'] as String,
              label: o['label'] as String? ?? '${o['key']}',
              multi: o['type'] == 'multi',
              required: o['required'] as bool? ?? false,
              choices: [
                for (final c in jl(o['choices']))
                  ChoiceModel(c['key'] as String, c['label'] as String? ?? '${c['key']}', Money.fromJson(c['price'])),
              ],
            ),
        ],
      );
}

class ProductsPage {
  const ProductsPage(this.items, this.page, this.lastPage);
  final List<ProductModel> items;
  final int page;
  final int lastPage;
  bool get hasMore => page < lastPage;
}

class AddressModel {
  const AddressModel({required this.id, this.label, required this.lat, required this.lng, this.details, this.isDefault = false});
  final int id;
  final String? label;
  final double lat;
  final double lng;
  final String? details;
  final bool isDefault;
  factory AddressModel.fromJson(Map<String, dynamic> j) => AddressModel(
      id: j['id'] as int,
      label: j['label'] as String?,
      lat: jn(j['lat']) ?? 0,
      lng: jn(j['lng']) ?? 0,
      details: j['details'] as String?,
      isDefault: j['is_default'] as bool? ?? false);
  String get title => (label ?? '').isEmpty ? 'عنوان' : label!;
}

class StatusModel {
  const StatusModel({required this.key, required this.label, this.step = 0, this.isTerminal = false});
  final String key;
  final String label;
  final int step;
  final bool isTerminal;
  factory StatusModel.fromJson(Object? v) {
    final j = jm(v);
    return StatusModel(
        key: j['key'] as String? ?? '',
        label: j['label'] as String? ?? '',
        step: j['step'] as int? ?? 0,
        isTerminal: j['is_terminal'] as bool? ?? false);
  }
}

class PlaceModel {
  const PlaceModel({this.label, this.details, this.lat, this.lng, this.addressId});
  final String? label;
  final String? details;
  final double? lat;
  final double? lng;
  final int? addressId;
  factory PlaceModel.fromJson(Object? v) {
    final j = jm(v);
    return PlaceModel(label: j['label'] as String?, details: j['details'] as String?, lat: jn(j['lat']), lng: jn(j['lng']), addressId: j['address_id'] as int?);
  }
  String get line => [label, details].where((e) => e != null && e.isNotEmpty).join('، ');
}

class OrderSummaryModel {
  const OrderSummaryModel({required this.id, required this.code, required this.status, required this.createdAt, this.dropoff = const PlaceModel(), this.itemsCount, required this.total, this.driverName, this.rated, this.summary = ''});
  final int id;
  final String code;
  final StatusModel status;
  final DateTime? createdAt;
  final PlaceModel dropoff;
  final int? itemsCount;

  /// ملخص نصي قصير للطلب إن أرسله الخادم.
  final String summary;
  final Money total;
  final String? driverName;
  final bool? rated;
  factory OrderSummaryModel.fromJson(Map<String, dynamic> j) => OrderSummaryModel(
      id: j['id'] as int,
      code: j['code'] as String? ?? '',
      status: StatusModel.fromJson(j['status']),
      createdAt: jd(j['created_at']),
      dropoff: PlaceModel.fromJson(j['dropoff']),
      itemsCount: j['items_count'] as int?,
      total: Money.fromJson(j['total']),
      driverName: j['driver_name'] as String?,
      rated: j['rated'] as bool?,
      summary: j['summary'] as String? ?? '');
}

class PrintSpecModel {
  const PrintSpecModel({this.fileName, this.pages = 0, this.paperSize = '', this.color = 'bw', this.sides = 'single', this.copies = 1, this.binding = '', this.range, this.notes});
  final String? fileName;
  final int pages;
  final String paperSize;
  final String color;
  final String sides;
  final int copies;
  final String binding;
  final String? range;
  final String? notes;
  factory PrintSpecModel.fromJson(Map<String, dynamic> j) => PrintSpecModel(
      fileName: j['file_name'] as String?,
      pages: j['pages'] as int? ?? 0,
      paperSize: j['paper_size'] as String? ?? '',
      color: j['print_color'] as String? ?? 'bw',
      sides: j['print_sides'] as String? ?? 'single',
      copies: j['print_copies'] as int? ?? 1,
      binding: j['binding_type'] as String? ?? '',
      range: j['print_page_range'] as String?,
      notes: j['print_specifications'] as String?);
}

class OrderItemModel {
  const OrderItemModel({required this.id, required this.name, required this.qty, this.note, this.unitPrice, this.lineTotal, this.print, this.imageUrl, this.productId});
  final int id;
  final String name;
  final int qty;
  final String? imageUrl;
  final int? productId;

  /// أسماء بديلة تستخدمها الصفحات.
  int get quantity => qty;
  Money? get totalPrice => lineTotal;
  final String? note;
  final Money? unitPrice;
  final Money? lineTotal;
  final PrintSpecModel? print;
  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
      id: j['id'] as int? ?? 0,
      name: j['name'] as String? ?? '',
      qty: j['qty'] as int? ?? 1,
      note: j['note'] as String?,
      unitPrice: j['unit_price'] == null ? null : Money.fromJson(j['unit_price']),
      lineTotal: j['line_total'] == null ? null : Money.fromJson(j['line_total']),
      print: j['print'] is Map ? PrintSpecModel.fromJson(jm(j['print'])) : null,
      imageUrl: j['image_url'] as String?,
      productId: (j['product_id'] as num?)?.toInt());
}

class PriceLineModel {
  const PriceLineModel(this.key, this.kind, this.label, this.amount);
  final String key;
  final String kind;
  final String label;
  final Money amount;
}

class GatewayModel {
  const GatewayModel({required this.name, this.holder, this.accountNumber, this.qrUrl});
  final String name;
  final String? holder;
  final String? accountNumber;
  final String? qrUrl;
}

class TimelineModel {
  const TimelineModel(this.status, this.at);
  final StatusModel status;
  final DateTime? at;
}

class OrderActionModel {
  const OrderActionModel({required this.action, this.label = '', this.confirm});
  final String action;
  final String label;
  final String? confirm;
}

class DriverPublicModel {
  const DriverPublicModel({required this.id, required this.name, this.phone, this.vehicleType, this.rating = 0, this.ratingCount = 0});
  final int id;
  final String name;
  final String? phone;
  final String? vehicleType;
  final double rating;
  final int ratingCount;
  factory DriverPublicModel.fromJson(Map<String, dynamic> j) => DriverPublicModel(
      id: j['id'] as int? ?? 0,
      name: j['name'] as String? ?? '',
      phone: j['phone'] as String?,
      vehicleType: j['vehicle_type'] as String?,
      rating: jn(jm(j['rating'])['average']) ?? 0,
      ratingCount: jm(j['rating'])['count'] as int? ?? 0);
}

const kVehicleLabels = {
  'motorcycle': 'دراجة نارية',
  'car': 'سيارة',
  'bicycle': 'دراجة هوائية',
  'van': 'فان',
  'tuk_tuk': 'توك توك',
  'on_foot': 'مشيًا',
};

class FileRefModel {
  const FileRefModel({required this.uploadId, required this.url, required this.mime});
  final int uploadId;
  final String url;
  final String mime;
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.code,
    required this.status,
    this.createdAt,
    this.statusChangedAt,
    this.scheduledFor,
    this.paymentMethod = '',
    this.paymentStatus = '',
    this.reviewNote,
    this.gateway,
    this.pickup = const PlaceModel(),
    this.dropoff = const PlaceModel(),
    this.distanceKm = 0,
    this.items = const [],
    this.orderType,
    this.recipientName,
    this.recipientPhone,
    this.shoppingRequest,
    this.substitutionPreference,
    this.failureReason,
    this.receipt,
    this.priceLines = const [],
    this.itemsTotal = Money.zero,
    this.deliveryFee = Money.zero,
    this.discount = Money.zero,
    this.total = Money.zero,
    this.note,
    this.deliveryCode,
    this.driver,
    this.timeline = const [],
    this.actions = const [],
    this.vendorName,
    this.ratingStars = 0,
    this.cancelReason,
    this.cancelledBy,
  });

  /// تفصيل السعر (اسم بديل لـ priceLines).
  List<PriceLineModel> get breakdown => priceLines;

  /// الإيصال متاح للطلبات المنتهية (التسليم/الإكمال)؛ الشاشة تجلبه بالمعرّف.
  String? get receiptUrl => const {'delivered', 'completed'}.contains(status.key) ? '/receipt' : null;

  final int id;
  final String code;
  final StatusModel status;
  final DateTime? createdAt;
  final DateTime? statusChangedAt;
  final DateTime? scheduledFor;
  final String paymentMethod;
  final String paymentStatus;
  final String? reviewNote;
  final GatewayModel? gateway;
  final PlaceModel pickup;
  final PlaceModel dropoff;
  final double distanceKm;
  final List<OrderItemModel> items;
  final String? orderType;
  final String? recipientName;
  final String? recipientPhone;
  final String? shoppingRequest;
  final String? substitutionPreference;
  final String? failureReason;
  final FileRefModel? receipt;
  final List<PriceLineModel> priceLines;
  final Money itemsTotal;
  final Money deliveryFee;
  final Money discount;
  final Money total;
  final String? note;
  final String? deliveryCode;
  final DriverPublicModel? driver;
  final List<TimelineModel> timeline;
  final List<OrderActionModel> actions;
  final String? vendorName;
  final int ratingStars;
  final String? cancelReason;
  final String? cancelledBy;

  String get statusKey => status.key;
  bool get isTransfer => paymentMethod == 'bank_transfer';
  bool get isCash => paymentMethod == 'cash_on_delivery' || paymentMethod == 'cash';
  bool can(String action) => actions.any((a) => a.action == action);

  factory OrderModel.fromJson(Map<String, dynamic> j) {
    final pay = jm(j['payment']);
    final gw = jm(pay['gateway']);
    final f = jm(j['fields']);
    final price = jm(j['price']);
    final drv = j['driver'];
    final rec = f['payment_receipt'];
    return OrderModel(
      id: j['id'] as int,
      code: j['code'] as String? ?? '',
      status: StatusModel.fromJson(j['status']),
      createdAt: jd(j['created_at']),
      statusChangedAt: jd(j['status_changed_at']),
      scheduledFor: jd(j['scheduled_for']),
      paymentMethod: pay['method'] as String? ?? '',
      paymentStatus: pay['status'] as String? ?? '',
      reviewNote: (pay['review_note'] as String?) ?? (f['payment_review_note'] as String?),
      gateway: gw.isEmpty
          ? null
          : GatewayModel(
              name: gw['name'] as String? ?? '',
              holder: gw['holder'] as String?,
              accountNumber: gw['account_number'] as String?,
              qrUrl: gw['qr_url'] as String?),
      pickup: PlaceModel.fromJson(j['pickup']),
      dropoff: PlaceModel.fromJson(j['dropoff']),
      distanceKm: jn(j['distance_km']) ?? 0,
      items: [for (final i in jl(j['items'])) OrderItemModel.fromJson(i)],
      orderType: f['order_type'] as String?,
      recipientName: f['recipient_name'] as String?,
      recipientPhone: f['recipient_phone'] as String?,
      shoppingRequest: f['shopping_request'] as String?,
      substitutionPreference: f['substitution_preference'] as String?,
      failureReason: f['delivery_failure_reason'] as String?,
      receipt: rec is Map ? FileRefModel(uploadId: rec['upload_id'] as int, url: rec['url'] as String? ?? '', mime: rec['mime'] as String? ?? '') : null,
      priceLines: [
        for (final l in jl(price['breakdown']))
          PriceLineModel(l['key'] as String? ?? '', l['kind'] as String? ?? '', l['label'] as String? ?? '', Money.fromJson(l)),
      ],
      itemsTotal: Money.fromJson(price['items_total']),
      deliveryFee: Money.fromJson(price['delivery_fee']),
      discount: Money.fromJson(price['discount']),
      total: Money.fromJson(price['total']),
      note: j['note'] as String?,
      deliveryCode: j['delivery_code'] as String?,
      driver: drv is Map ? DriverPublicModel.fromJson(Map<String, dynamic>.from(drv)) : null,
      timeline: [for (final t in jl(j['timeline'])) TimelineModel(StatusModel.fromJson(t['status']), jd(t['at']))],
      actions: [for (final a in jl(j['available_actions'])) OrderActionModel(action: a['action'] as String? ?? '', label: a['label'] as String? ?? '', confirm: a['confirm'] as String?)],
      vendorName: jm(j['vendor'])['name'] as String?,
      ratingStars: jm(j['rating'])['stars'] as int? ?? 0,
      cancelReason: j['cancel_reason'] as String?,
      cancelledBy: j['cancelled_by'] as String?,
    );
  }
}

class TrackingModel {
  const TrackingModel({required this.status, this.driverName, this.driverPhone, this.vehicleType, this.rating = 0, this.ratingCount = 0, this.driverLat, this.driverLng, this.lastSeenAt, this.pickupLat, this.pickupLng, this.dropLat, this.dropLng, this.etaMinutes, this.nextPollSeconds = 10, this.tail = const []});
  final StatusModel status;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleType;
  final double rating;
  final int ratingCount;
  final double? driverLat;
  final double? driverLng;
  final DateTime? lastSeenAt;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;
  final int? etaMinutes;
  final int nextPollSeconds;
  final List<(double, double)> tail;

  bool get hasLocation => driverLat != null && driverLng != null;
  bool isStale([int minutes = 2]) => lastSeenAt == null || DateTime.now().difference(lastSeenAt!).inMinutes >= minutes;

  factory TrackingModel.fromJson(Map<String, dynamic> j) {
    final d = jm(j['driver']);
    final loc = jm(d['location']);
    final pk = jm(j['pickup']);
    final dr = jm(j['dropoff']);
    return TrackingModel(
      status: StatusModel.fromJson(j['status']),
      driverName: d['name'] as String?,
      driverPhone: d['phone'] as String?,
      vehicleType: d['vehicle_type'] as String?,
      rating: jn(jm(d['rating'])['average']) ?? 0,
      ratingCount: jm(d['rating'])['count'] as int? ?? 0,
      driverLat: jn(loc['lat']),
      driverLng: jn(loc['lng']),
      lastSeenAt: jd(d['last_seen_at']),
      pickupLat: jn(pk['lat']),
      pickupLng: jn(pk['lng']),
      dropLat: jn(dr['lat']),
      dropLng: jn(dr['lng']),
      etaMinutes: j['eta_minutes'] as int?,
      nextPollSeconds: ((j['next_poll_seconds'] as int?) ?? 10).clamp(5, 120),
      tail: [for (final p in jl(j['path_tail'])) (jn(p['lat']) ?? 0, jn(p['lng']) ?? 0)],
    );
  }
}

class PublicTrackingModel {
  const PublicTrackingModel({required this.code, required this.status, this.etaMinutes, this.timeline = const [], this.driverFirstName, this.driverLat, this.driverLng, this.dropLat, this.dropLng, this.pollSeconds = 15, this.projectName = 'سطر'});
  final String code;
  final StatusModel status;
  final int? etaMinutes;
  final List<(String, DateTime?)> timeline;
  final String? driverFirstName;
  final double? driverLat;
  final double? driverLng;
  final double? dropLat;
  final double? dropLng;
  final int pollSeconds;
  final String projectName;
  factory PublicTrackingModel.fromJson(Map<String, dynamic> j) {
    final o = jm(j['order']);
    final d = jm(j['driver']);
    final loc = jm(d['location']);
    final dz = jm(o['dropoff_area']);
    return PublicTrackingModel(
      code: o['code'] as String? ?? '',
      status: StatusModel.fromJson(o['status']),
      etaMinutes: o['eta_minutes'] as int?,
      timeline: [for (final t in jl(o['timeline'])) (t['label'] as String? ?? '', jd(t['at']))],
      driverFirstName: d['first_name'] as String?,
      driverLat: jn(loc['lat']),
      driverLng: jn(loc['lng']),
      dropLat: jn(dz['lat']),
      dropLng: jn(dz['lng']),
      pollSeconds: ((j['poll_seconds'] as int?) ?? 15).clamp(5, 120),
      projectName: jm(j['project'])['name'] as String? ?? 'سطر',
    );
  }
}

class ShareLinkModel {
  const ShareLinkModel({required this.url, required this.token, this.expiresAt});
  final String url;
  final String token;
  final DateTime? expiresAt;
}

class NotificationModel {
  const NotificationModel({required this.id, required this.event, required this.title, required this.body, this.data = const {}, this.readAt, this.createdAt});
  final int id;
  final String event;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? createdAt;
  bool get unread => readAt == null;
  int? get orderId {
    final v = data['order_id'] ?? data['order'];
    return v is int ? v : int.tryParse('$v');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'event': event,
        'title': title,
        'body': body,
        'data': data,
        'read_at': readAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
      id: j['id'] as int,
      event: j['event'] as String? ?? '',
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
      data: jm(j['data']),
      readAt: jd(j['read_at']),
      createdAt: jd(j['created_at']));
}

class ReceiptModel {
  const ReceiptModel({required this.code, required this.statusAr, required this.statusEn, this.createdAt, this.completedAt, this.driver, this.paymentMethod = '', this.paymentStatus = '', this.items = const [], this.lines = const [], required this.total, this.projectAr = '', this.projectEn = ''});
  final String code;
  final String statusAr;
  final String statusEn;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final String? driver;
  final String paymentMethod;
  final String paymentStatus;
  final List<(String, int)> items;
  final List<(String, String, Money)> lines; // ar, en, amount
  final Money total;
  final String projectAr;
  final String projectEn;
  factory ReceiptModel.fromJson(Map<String, dynamic> j) => ReceiptModel(
      code: j['code'] as String? ?? '',
      statusAr: jm(j['status'])['ar'] as String? ?? '',
      statusEn: jm(j['status'])['en'] as String? ?? '',
      createdAt: jd(j['created_at']),
      completedAt: jd(j['completed_at']),
      driver: j['driver'] as String?,
      paymentMethod: jm(j['payment'])['method'] as String? ?? '',
      paymentStatus: jm(j['payment'])['status'] as String? ?? '',
      items: [for (final i in jl(j['items'])) (i['name'] as String? ?? '', i['qty'] as int? ?? 1)],
      lines: [for (final l in jl(j['lines'])) (jm(l['label'])['ar'] as String? ?? '', jm(l['label'])['en'] as String? ?? '', Money.fromJson(l['amount']))],
      total: Money.fromJson(j['total']),
      projectAr: jm(j['project'])['ar'] as String? ?? '',
      projectEn: jm(j['project'])['en'] as String? ?? '');
}

class CancelReason {
  const CancelReason(this.key, this.label);
  final String key;
  final String label;
}

// ------------------------------------------------------------------- driver

class DriverModel {
  const DriverModel({required this.id, required this.name, required this.phone, this.vehicleType = 'motorcycle', this.locale = 'ar', this.isOnline = false, this.rating = 0, this.ratingCount = 0, required this.cashOnHand, required this.maxCash, this.avatarUrl, this.zoneId, this.zoneName, this.hasFcmToken});
  final bool? hasFcmToken;
  final int id;
  final String name;
  final String phone;
  final String vehicleType;
  final int? zoneId;
  final String? zoneName;
  final String locale;
  final bool isOnline;
  final double rating;
  final int ratingCount;
  final Money cashOnHand;
  final Money maxCash;
  final String? avatarUrl;
  String get initial => firstCh(name);
  factory DriverModel.fromJson(Map<String, dynamic> j) => DriverModel(
      id: j['id'] as int? ?? 0,
      name: j['name'] as String? ?? '',
      phone: j['phone'] as String? ?? '',
      vehicleType: j['vehicle_type'] as String? ?? 'motorcycle',
      locale: j['locale'] as String? ?? 'ar',
      isOnline: j['is_online'] as bool? ?? false,
      rating: jn(jm(j['rating'])['average']) ?? 0,
      ratingCount: jm(j['rating'])['count'] as int? ?? 0,
      cashOnHand: Money.fromJson(j['cash_on_hand']),
      maxCash: Money.fromJson(j['max_cash']),
      avatarUrl: j['avatar_url'] as String?,
      zoneId: j['zone_id'] as int?,
      hasFcmToken: j['has_fcm_token'] as bool?,
      zoneName: j['zone'] is Map ? jm(j['zone'])['name'] as String? : null);
}

class NextActionModel {
  const NextActionModel({required this.action, required this.to, required this.label, this.style = 'primary', this.requires = const [], this.geofenceMeters, this.confirm, this.fields = const []});
  final String action; // accept | transition | deliver
  final String to;
  final String label;
  final String style;
  final List<String> requires;
  final int? geofenceMeters;
  final String? confirm;
  final List<String> fields;
  factory NextActionModel.fromJson(Map<String, dynamic> j) => NextActionModel(
      action: j['action'] as String? ?? 'transition',
      to: j['to'] as String? ?? '',
      label: j['label'] as String? ?? '',
      style: j['style'] as String? ?? 'primary',
      requires: [for (final r in (j['requires'] as List? ?? const [])) '$r'],
      geofenceMeters: j['geofence_meters'] as int?,
      confirm: j['confirm'] as String?,
      fields: [for (final r in (j['fields'] as List? ?? const [])) '$r']);
}

class DriverOrderModel {
  const DriverOrderModel({
    required this.id,
    required this.code,
    required this.status,
    this.isMine = false,
    this.distanceKm = 0,
    this.distanceToPickupKm,
    this.pickup = const PlaceModel(),
    this.dropoff = const PlaceModel(),
    this.paymentMethod = '',
    this.paymentStatus = '',
    this.collect = Money.zero,
    this.deliveryFee = Money.zero,
    this.earning = Money.zero,
    this.itemsCount,
    this.items = const [],
    this.customerName,
    this.customerPhone,
    this.note,
    this.nextAction,
    this.actions = const [],
    this.vendorName,
    this.createdAt,
    this.failureReason,
  });
  final int id;
  final String code;
  final StatusModel status;
  final bool isMine;
  final double distanceKm;
  final double? distanceToPickupKm;
  final PlaceModel pickup;
  final PlaceModel dropoff;
  final String paymentMethod;
  final String paymentStatus;
  final Money collect;
  final Money deliveryFee;
  final Money earning;
  final int? itemsCount;
  final List<(String, int)> items;
  final String? customerName;
  final String? customerPhone;
  final String? note;
  final NextActionModel? nextAction;

  /// كل الإجراءات المتاحة من الخادم (actions[]) — nextAction هو الأساسي منها.
  final List<NextActionModel> actions;
  final String? vendorName;
  final DateTime? createdAt;
  final String? failureReason;
  bool get isCash => collect.amount > 0;
  factory DriverOrderModel.fromJson(Map<String, dynamic> j) {
    final pay = jm(j['payment']);
    final cust = jm(j['customer']);
    final na = j['next_action'];
    return DriverOrderModel(
      id: jn(j['id'])?.toInt() ?? 0,
      code: j['code'] as String? ?? '',
      status: StatusModel.fromJson(j['status']),
      isMine: j['is_mine'] as bool? ?? false,
      distanceKm: jn(j['distance_km']) ?? 0,
      distanceToPickupKm: jn(j['distance_to_pickup_km']),
      pickup: PlaceModel.fromJson(j['pickup']),
      dropoff: PlaceModel.fromJson(j['dropoff']),
      paymentMethod: pay['method'] as String? ?? '',
      paymentStatus: pay['status'] as String? ?? '',
      collect: Money.fromJson(pay['collect']),
      deliveryFee: Money.fromJson(j['delivery_fee']),
      earning: Money.fromJson(j['earning']),
      itemsCount: jn(j['items_count'])?.toInt(),
      items: [for (final i in jl(j['items'])) (i['name'] as String? ?? '', jn(i['qty'])?.toInt() ?? 1)],
      customerName: cust['name'] as String?,
      customerPhone: cust['phone'] as String?,
      note: j['note'] as String?,
      nextAction: na is Map ? NextActionModel.fromJson(Map<String, dynamic>.from(na)) : null,
      actions: [for (final a in (j['actions'] is List ? j['actions'] as List : const [])) if (a is Map) NextActionModel.fromJson(Map<String, dynamic>.from(a))],
      vendorName: jm(j['vendor'])['name'] as String?,
      createdAt: jd(j['created_at']),
      failureReason: jm(j['fields'])['delivery_failure_reason'] as String?,
    );
  }
}

class AvailableOrders {
  const AvailableOrders(this.orders, {this.reason});
  final List<DriverOrderModel> orders;
  final String? reason; // meta.reason: offline | ...
}

class EarningsModel {
  const EarningsModel({required this.period, required this.orders, required this.earnings, required this.cashCollected, this.series = const []});
  final String period;
  final int orders;
  final Money earnings;
  final Money cashCollected;
  final List<(DateTime?, int, Money)> series;
  factory EarningsModel.fromJson(Map<String, dynamic> j) => EarningsModel(
      period: j['period'] as String? ?? 'day',
      orders: j['orders'] as int? ?? 0,
      earnings: Money.fromJson(j['earnings']),
      cashCollected: Money.fromJson(j['cash_collected']),
      series: [for (final s in jl(j['series'])) (DateTime.tryParse('${s['date']}'), s['orders'] as int? ?? 0, Money.fromJson(s['earnings']))]);
}

class CashModel {
  const CashModel({required this.onHand, required this.max, this.remaining, this.unsettled = 0, this.settlements = const []});
  final Money onHand;
  final Money max;
  final Money? remaining;
  final int unsettled;
  final List<(DateTime?, Money, String?)> settlements;
  factory CashModel.fromJson(Map<String, dynamic> j) => CashModel(
      onHand: Money.fromJson(j['cash_on_hand']),
      max: Money.fromJson(j['max_cash']),
      remaining: j['remaining'] == null ? null : Money.fromJson(j['remaining']),
      unsettled: j['unsettled_orders'] as int? ?? 0,
      settlements: [for (final s in jl(j['settlements'])) (jd(s['at']), Money.fromJson(s['amount']), s['note'] as String?)]);
}
