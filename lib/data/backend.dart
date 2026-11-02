import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/data/models.dart';

/// واجهة الباكند الموحّدة (satr-openapi.json). كل نقطة نهاية هنا موجودة في العقد؛
/// لا نقاط مخترعة ولا استجابات نجاح مصطنعة.
class Backend {
  Backend(this._api);
  final ApiClient _api;
  Dio get _d => _api.dio;

  Future<Either<Failure, T>> _run<T>(Future<T> Function() f) => ErrorHandler.guard(f);

  static Map<String, dynamic> _meta(Response<dynamic> r) {
    final b = r.data;
    return b is Map && b['meta'] is Map ? Map<String, dynamic>.from(b['meta'] as Map) : {};
  }

  static List<Map<String, dynamic>> _list(Response<dynamic> r) => jl(ApiClient.unwrap<dynamic>(r));

  // ---------------------------------------------------------------- customer auth

  Future<Either<Failure, void>> sendOtp(String phone) => _run(() async {
        await _d.post<dynamic>('v1/auth/send-otp', data: {'phone': phone}, options: Options(extra: {'auth': false}));
      });

  Future<Either<Failure, AuthResult>> verifyOtp(String phone, String code, {String? deviceName}) => _run(() async {
        final r = await _d.post<dynamic>('v1/auth/verify-otp',
            data: {'phone': phone, 'code': code, if (deviceName != null) 'device_name': deviceName}, options: Options(extra: {'auth': false}));
        final m = ApiClient.unwrapMap(r);
        return AuthResult(token: m['token'] as String, isNewUser: m['is_new_user'] as bool? ?? false, user: UserModel.fromJson(jm(m['user'])));
      });

  Future<Either<Failure, void>> logout() => _run(() async {
        await _d.post<dynamic>('v1/auth/logout');
      });

  Future<Either<Failure, UserModel>> me() => _run(() async => UserModel.fromJson(ApiClient.unwrapMap(await _d.get<dynamic>('v1/me'))));

  Future<Either<Failure, UserModel>> updateMe({String? name, String? locale, int? avatarUploadId}) => _run(() async {
        final r = await _d.put<dynamic>('v1/me', data: {
          if (name != null) 'name': name,
          if (locale != null) 'locale': locale,
          if (avatarUploadId != null) 'avatar_upload_id': avatarUploadId,
        });
        return UserModel.fromJson(ApiClient.unwrapMap(r));
      });

  Future<Either<Failure, void>> deleteMe() => _run(() async {
        await _d.delete<dynamic>('v1/me');
      });

  Future<Either<Failure, void>> setFcmToken(String? token, {bool driver = false}) => _run(() async {
        await _d.put<dynamic>(driver ? 'v1/driver/me/fcm-token' : 'v1/me/fcm-token', data: {'token': token});
      });

  // ---------------------------------------------------------------- addresses

  Future<Either<Failure, List<AddressModel>>> addresses() => _run(() async => [for (final a in _list(await _d.get<dynamic>('v1/addresses'))) AddressModel.fromJson(a)]);

  Future<Either<Failure, AddressModel>> saveAddress({int? id, required String label, required double lat, required double lng, String? details, bool isDefault = false}) => _run(() async {
        final body = {'label': label, 'lat': lat, 'lng': lng, 'details': details, 'is_default': isDefault};
        final r = id == null ? await _d.post<dynamic>('v1/addresses', data: body) : await _d.put<dynamic>('v1/addresses/$id', data: body);
        return AddressModel.fromJson(ApiClient.unwrapMap(r));
      });

  Future<Either<Failure, void>> deleteAddress(int id) => _run(() async {
        await _d.delete<dynamic>('v1/addresses/$id');
      });

  // ---------------------------------------------------------------- catalog

  Future<Either<Failure, List<CategoryModel>>> categories({String? kind}) => _run(() async => [
        for (final c in _list(await _d.get<dynamic>('v1/categories', queryParameters: {if (kind != null) 'kind': kind}))) CategoryModel.fromJson(c),
      ]);

  Future<Either<Failure, ProductsPage>> products({int? category, String? kind, String? q, int perPage = 24, int page = 1}) => _run(() async {
        final r = await _d.get<dynamic>('v1/products', queryParameters: {
          if (category != null) 'category': category,
          if (kind != null) 'kind': kind,
          if (q != null && q.isNotEmpty) 'q': q.length > 60 ? q.substring(0, 60) : q,
          'per_page': perPage,
          if (page > 1) 'page': page,
        });
        final items = [for (final p in _list(r)) ProductModel.fromJson(p)];
        // العقد لا يوثّق معامل page: نطلب صفحة تالية فقط إذا أكّد meta وجودها.
        final meta = _meta(r);
        final cur = meta['current_page'] as int?;
        final last = meta['last_page'] as int?;
        if (cur != null && last != null) return ProductsPage(items, cur, last);
        return ProductsPage(items, page, page);
      });

  Future<Either<Failure, ProductModel>> product(int id) => _run(() async => ProductModel.fromJson(ApiClient.unwrapMap(await _d.get<dynamic>('v1/products/$id'))));

  // ---------------------------------------------------------------- orders

  Future<Either<Failure, List<OrderSummaryModel>>> orders({String scope = 'active', int perPage = 30}) => _run(() async => [
        for (final o in _list(await _d.get<dynamic>('v1/orders', queryParameters: {'scope': scope, 'per_page': perPage}))) OrderSummaryModel.fromJson(o),
      ]);

  Future<Either<Failure, OrderModel>> order(int id) => _run(() async => OrderModel.fromJson(ApiClient.unwrapMap(await _d.get<dynamic>('v1/orders/$id'))));

  /// أحداث خفيفة: يعيد (عدد الأحداث الجديدة، next_since).
  Future<Either<Failure, (int, int)>> events(int id, int since) => _run(() async {
        final r = await _d.get<dynamic>('v1/orders/$id/events', queryParameters: {'since': since});
        final list = _list(r);
        final next = _meta(r)['next_since'] as int? ?? (list.isEmpty ? since : (list.last['id'] as int? ?? since));
        return (list.length, next);
      });

  Future<Either<Failure, List<CancelReason>>> cancelReasons() => _run(() async {
        final raw = ApiClient.unwrap<dynamic>(await _d.get<dynamic>('v1/cancel-reasons'));
        final out = <CancelReason>[];
        if (raw is List) {
          for (final e in raw) {
            if (e is Map) {
              final k = e['key'] ?? e['value'] ?? e['reason'] ?? e['code'];
              out.add(CancelReason('$k', '${e['label'] ?? e['name'] ?? k}'));
            } else {
              out.add(CancelReason('$e', '$e'));
            }
          }
        } else if (raw is Map) {
          raw.forEach((k, v) => out.add(CancelReason('$k', '$v')));
        }
        return out;
      });

  Future<Either<Failure, OrderModel>> cancel(int id, String reason, {String? note}) => _run(() async {
        final r = await _d.post<dynamic>('v1/orders/$id/cancel', data: {'reason': reason, if (note != null && note.trim().isNotEmpty) 'note': note.trim()});
        return OrderModel.fromJson(ApiClient.unwrapMap(r));
      });

  Future<Either<Failure, void>> rate(int id, {required int stars, String? comment, int? vendorStars, String? vendorComment}) => _run(() async {
        await _d.post<dynamic>('v1/orders/$id/rate', data: {
          'stars': stars,
          if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
          if (vendorStars != null && vendorStars > 0) 'vendor_stars': vendorStars,
          if (vendorComment != null && vendorComment.trim().isNotEmpty) 'vendor_comment': vendorComment.trim(),
        });
      });

  Future<Either<Failure, ReceiptModel>> receipt(int id) => _run(() async => ReceiptModel.fromJson(ApiClient.unwrapMap(await _d.get<dynamic>('v1/orders/$id/receipt'))));

  Future<Either<Failure, ShareLinkModel>> createShareLink(int id) => _run(() async {
        final m = ApiClient.unwrapMap(await _d.post<dynamic>('v1/orders/$id/share-link'));
        return ShareLinkModel(url: m['url'] as String? ?? '', token: m['token'] as String? ?? '', expiresAt: jd(m['expires_at']));
      });

  Future<Either<Failure, void>> stopShareLinks(int id) => _run(() async {
        await _d.delete<dynamic>('v1/orders/$id/share-link');
      });

  Future<Either<Failure, TrackingModel>> tracking(int id) => _run(() async => TrackingModel.fromJson(ApiClient.unwrapMap(await _d.get<dynamic>('v1/orders/$id/tracking'))));

  Future<Either<Failure, PublicTrackingModel>> publicTracking(String token) =>
      _run(() async => PublicTrackingModel.fromJson(ApiClient.unwrapMap(await _d.get<dynamic>('v1/track/$token', options: Options(extra: {'auth': false})))));

  // ---------------------------------------------------------------- notifications

  Future<Either<Failure, List<NotificationModel>>> notifications({bool driver = false, bool unread = false, int perPage = 30}) => _run(() async => [
        for (final n in _list(await _d.get<dynamic>(driver ? 'v1/driver/notifications' : 'v1/notifications', queryParameters: {if (unread) 'unread': 1, 'per_page': perPage})))
          NotificationModel.fromJson(n),
      ]);

  Future<Either<Failure, void>> readAllNotifications({bool driver = false}) => _run(() async {
        await _d.post<dynamic>(driver ? 'v1/driver/notifications/read-all' : 'v1/notifications/read-all');
      });

  Future<Either<Failure, void>> notificationOpened(int id, {bool driver = false}) => _run(() async {
        await _d.post<dynamic>(driver ? 'v1/driver/notifications/$id/opened' : 'v1/notifications/$id/opened');
      });

  // ---------------------------------------------------------------- driver

  Future<Either<Failure, (String, DriverModel)>> driverLogin(String phone, String password, {String? deviceName}) => _run(() async {
        final r = await _d.post<dynamic>('v1/driver/auth/login', data: {'phone': phone, 'password': password, if (deviceName != null) 'device_name': deviceName}, options: Options(extra: {'auth': false}));
        final m = ApiClient.unwrapMap(r);
        final drv = jm(m['driver'] ?? m['user']);
        return (m['token'] as String, DriverModel.fromJson(drv));
      });

  Future<Either<Failure, void>> driverLogout() => _run(() async {
        await _d.post<dynamic>('v1/driver/auth/logout');
      });

  Future<Either<Failure, DriverModel>> driverMe() => _run(() async => DriverModel.fromJson(ApiClient.unwrapMap(await _d.get<dynamic>('v1/driver/me'))));

  Future<Either<Failure, DriverModel>> updateDriver({String? locale, String? vehicleType, int? avatarUploadId}) => _run(() async {
        final r = await _d.put<dynamic>('v1/driver/me', data: {
          if (locale != null) 'locale': locale,
          if (vehicleType != null) 'vehicle_type': vehicleType,
          if (avatarUploadId != null) 'avatar_upload_id': avatarUploadId,
        });
        return DriverModel.fromJson(ApiClient.unwrapMap(r));
      });

  Future<Either<Failure, void>> driverStatus(bool online) => _run(() async {
        await _d.put<dynamic>('v1/driver/status', data: {'is_online': online});
      });

  /// نقطة واحدة أو points[] (حتى 100) لإعادة إرسال ما جُمع بلا إنترنت.
  Future<Either<Failure, void>> driverLocation(List<({double lat, double lng, double? accuracy, double? speed, double? heading, DateTime at})> pts) => _run(() async {
        Map<String, dynamic> one(({double lat, double lng, double? accuracy, double? speed, double? heading, DateTime at}) p) => {
              'lat': p.lat,
              'lng': p.lng,
              if (p.accuracy != null) 'accuracy': p.accuracy!.round().clamp(0, 10000),
              if (p.speed != null) 'speed': p.speed!.clamp(0, 300),
              if (p.heading != null && p.heading! >= 0) 'heading': p.heading!.round().clamp(0, 360),
              'recorded_at': p.at.toUtc().toIso8601String(),
            };
        final body = pts.length == 1 ? one(pts.first) : {'points': [for (final p in pts.take(100)) one(p)]};
        await _d.post<dynamic>('v1/driver/location', data: body);
      });

  Future<Either<Failure, AvailableOrders>> driverAvailable() => _run(() async {
        final r = await _d.get<dynamic>('v1/driver/orders/available');
        return AvailableOrders([for (final o in _list(r)) DriverOrderModel.fromJson(o)], reason: _meta(r)['reason'] as String?);
      });

  Future<Either<Failure, DriverOrderModel?>> driverCurrent() => _run(() async {
        final raw = ApiClient.unwrap<dynamic>(await _d.get<dynamic>('v1/driver/orders/current'));
        return raw is Map ? DriverOrderModel.fromJson(Map<String, dynamic>.from(raw)) : null;
      });

  Future<Either<Failure, List<DriverOrderModel>>> driverHistory({int perPage = 30}) =>
      _run(() async => [for (final o in _list(await _d.get<dynamic>('v1/driver/orders/history', queryParameters: {'per_page': perPage}))) DriverOrderModel.fromJson(o)]);

  Future<Either<Failure, DriverOrderModel>> driverOrder(int id) => _run(() async => DriverOrderModel.fromJson(ApiClient.unwrapMap(await _d.get<dynamic>('v1/driver/orders/$id'))));

  Future<Either<Failure, DriverOrderModel>> driverAccept(int id, String key) => _run(() async {
        final r = await _d.post<dynamic>('v1/driver/orders/$id/accept', options: Options(headers: {'Idempotency-Key': key}));
        return DriverOrderModel.fromJson(ApiClient.unwrapMap(r));
      });

  Future<Either<Failure, void>> driverReject(int id) => _run(() async {
        await _d.post<dynamic>('v1/driver/orders/$id/reject');
      });

  Future<Either<Failure, DriverOrderModel>> driverTransition(int id, String to, {Map<String, dynamic>? fields, List<int>? uploadIds, String? otp, String? note, required String key}) => _run(() async {
        final r = await _d.post<dynamic>('v1/driver/orders/$id/transition',
            data: {
              'to': to,
              if (fields != null && fields.isNotEmpty) 'fields': fields,
              if (uploadIds != null && uploadIds.isNotEmpty) 'upload_ids': uploadIds,
              if (otp != null) 'otp': otp,
              if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
            },
            options: Options(headers: {'Idempotency-Key': key}));
        return DriverOrderModel.fromJson(ApiClient.unwrapMap(r));
      });

  Future<Either<Failure, DriverOrderModel>> driverDeliver(int id, {String? otp, List<int>? uploadIds, String? note, Map<String, dynamic>? fields, required String key}) => _run(() async {
        final r = await _d.post<dynamic>('v1/driver/orders/$id/deliver',
            data: {
              if (otp != null) 'otp': otp,
              if (uploadIds != null && uploadIds.isNotEmpty) 'upload_ids': uploadIds,
              if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
              if (fields != null && fields.isNotEmpty) 'fields': fields,
            },
            options: Options(headers: {'Idempotency-Key': key}));
        return DriverOrderModel.fromJson(ApiClient.unwrapMap(r));
      });

  Future<Either<Failure, EarningsModel>> driverEarnings(String period) =>
      _run(() async => EarningsModel.fromJson(ApiClient.unwrapMap(await _d.get<dynamic>('v1/driver/earnings', queryParameters: {'period': period}))));

  Future<Either<Failure, CashModel>> driverCash() => _run(() async => CashModel.fromJson(ApiClient.unwrapMap(await _d.get<dynamic>('v1/driver/cash'))));
}
