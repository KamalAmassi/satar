import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:project/customer/features/cart/data/datasources/product_remote_datasource.dart';
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
}
