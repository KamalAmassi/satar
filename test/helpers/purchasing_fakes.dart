import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/customer/features/cart/domain/entities/product_info.dart';
import 'package:project/customer/features/cart/domain/entities/stored_cart.dart';
import 'package:project/customer/features/cart/domain/repositories/cart_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SessionStore> signedInSession({int userId = 1}) async {
  SharedPreferences.setMockInitialValues({});
  final store = SessionStore(await SharedPreferences.getInstance());
  await store.signIn(token: 'test-token-$userId', userId: userId);
  return store;
}

RemoteConfig testConfig() => RemoteConfig.fromJson({
      'config_version': 8,
      'currency': {'code': 'ILS', 'symbol': '₪', 'minor_units': 100},
      'payment_methods': ['cash_on_delivery', 'bank_transfer'],
      'modules_config': {
        'catalog': {
          'cart': {'max_lines': 50, 'max_qty': 99},
        },
        'printing': {
          'paper_sizes': [
            {
              'key': 'a4',
              'label': 'A4',
              'bw_page_price': {'amount': 25, 'formatted': '0.25 ₪'},
              'color_page_price': {'amount': 50, 'formatted': '0.50 ₪'},
            },
          ],
          'bindings': [
            {
              'key': 'none',
              'label': 'None',
              'price': {'amount': 0, 'formatted': '0.00 ₪'},
            },
          ],
          'print_colors': ['bw', 'color'],
          'print_sides': ['single', 'double'],
          'max_jobs': 20,
          'max_copies': 500,
          'file_mimes': ['application/pdf', 'image/png'],
          'max_file_mb': 10,
        },
        'bank_transfer': {
          'accounts': [
            {
              'kind': 'wallet',
              'provider': 'Test wallet',
              'holder': 'Test holder',
              'number': '0590000000',
              'iban': null,
            },
          ],
          'receipt_max_mb': 10,
          'receipt_mimes': ['image/png', 'application/pdf'],
        },
      },
      'fields': {
        'order': {
          'properties': {
            'recipient_phone': {'pattern': r'^\+?[0-9]{7,15}$'},
          },
        },
      },
    });

class FakeRemoteConfigRepository extends RemoteConfigRepository {
  FakeRemoteConfigRepository(super.api);

  @override
  RemoteConfig? get current => testConfig();

  @override
  Future<Either<Failure, RemoteConfig>> load({bool refresh = false}) async =>
      Right(testConfig());
}

ApiClient offlineApi(SessionStore session) => ApiClient(session, dio: Dio());

class FakeCartRepository implements CartRepository {
  final Map<int, StoredCart> saved = {};
  final Map<int, ProductInfo> products = {};

  @override
  Future<Either<Failure, StoredCart>> load(int userId) async =>
      Right(saved[userId] ?? const StoredCart());

  @override
  Future<Either<Failure, Unit>> save(int userId, StoredCart cart) async {
    saved[userId] = cart;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, ProductInfo>> product(int productId) async {
    final p = products[productId];
    return p == null
        ? const Left(ServerFailure(code: 'not_found', statusCode: 404))
        : Right(p);
  }
}

/// كل رفع ينتظر Completer يتحكم به الاختبار.
class FakeUploadRepository extends UploadRepository {
  FakeUploadRepository(super.api);

  final List<Completer<Either<Failure, UploadedFile>>> pending = [];
  final List<String> purposes = [];

  @override
  Future<Either<Failure, UploadedFile>> upload({
    required Uint8List bytes,
    required String fileName,
    required String mime,
    required String purpose,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) {
    purposes.add(purpose);
    final c = Completer<Either<Failure, UploadedFile>>();
    pending.add(c);
    return c.future;
  }
}
