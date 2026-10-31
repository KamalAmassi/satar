import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:project/customer/features/cart/data/models/cart_item_model.dart';
import 'package:project/customer/features/cart/domain/entities/cart_item.dart';
import 'package:project/customer/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._local);

  final CartLocalDataSource _local;

  @override
  Future<Either<Failure, int>> addItems(List<CartItem> items) async {
    try {
      final current = <String, CartItem>{
        for (final i in _local.getItems()) i.lineKey: i,
      };
      for (final item in items) {
        final existing = current[item.lineKey];
        current[item.lineKey] = existing == null
            ? item
            : existing.copyWith(quantity: existing.quantity + item.quantity);
      }
      final models = current.values.map(CartItemModel.fromEntity).toList();
      await _local.saveItems(models);
      return Right(models.length);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getCount() async {
    try {
      return Right(_local.getItems().length);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}