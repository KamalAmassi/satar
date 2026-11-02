import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:project/customer/features/cart/data/datasources/product_remote_datasource.dart';
import 'package:project/customer/features/cart/domain/entities/cart_item.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/customer/features/cart/domain/entities/product_info.dart';
import 'package:project/customer/features/cart/domain/entities/stored_cart.dart';
import 'package:project/customer/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._local, this._remote);

  final CartLocalDataSource _local;
  final ProductRemoteDataSource _remote;

  @override
  Future<Either<Failure, StoredCart>> load(int userId) async {
    try {
      final json = _local.read(userId);
      return Right(
          json == null ? const StoredCart() : StoredCart.fromJson(json));
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> save(int userId, StoredCart cart) async {
    try {
      await _local.write(userId, cart.toJson());
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, ProductInfo>> product(int productId) =>
      ErrorHandler.guard(() => _remote.product(productId));

  @override
  Future<Either<Failure, int>> addItems(List<CartItem> items) async {
    try {
      const userId = 1;
      final json = _local.read(userId);
      final storedCart = json == null ? const StoredCart() : StoredCart.fromJson(json);

      final lines = List<CartProductLine>.from(storedCart.products);
      for (final item in items) {
        final optionsList = item.options.map((k, v) => MapEntry(k, [v]));
        final identity = CartProductLine.identityOf(item.productId, optionsList);
        final index = lines.indexWhere((l) => l.identity == identity);
        if (index >= 0) {
          final current = lines[index];
          lines[index] = current.copyWith(
            quantity: current.quantity + item.quantity,
            bumpRevision: true,
          );
        } else {
          lines.add(CartProductLine(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            productId: item.productId,
            quantity: item.quantity,
            options: optionsList,
            note: '',
          ));
        }
      }
      final updatedCart = StoredCart(
        products: lines,
        printJobs: storedCart.printJobs,
        substitutionPreference: storedCart.substitutionPreference,
        note: storedCart.note,
      );
      await _local.write(userId, updatedCart.toJson());
      return Right(updatedCart.products.fold(0, (sum, p) => sum + p.quantity));
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getCount() async {
    try {
      const userId = 1;
      final json = _local.read(userId);
      if (json == null) return const Right(0);
      final storedCart = StoredCart.fromJson(json);
      return Right(storedCart.products.fold(0, (sum, p) => sum + p.quantity));
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
