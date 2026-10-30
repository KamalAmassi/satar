import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/cart/domain/entities/product_info.dart';
import 'package:project/customer/features/cart/domain/entities/stored_cart.dart';

abstract class CartRepository {
  /// سلة المستخدم الحالي فقط.
  Future<Either<Failure, StoredCart>> load(int userId);
  Future<Either<Failure, Unit>> save(int userId, StoredCart cart);

  /// للعرض فقط: الاسم والسعر الحالي والمخزون والخيارات.
  Future<Either<Failure, ProductInfo>> product(int productId);
}
