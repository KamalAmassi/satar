import 'package:dartz/dartz.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/cart/domain/entities/cart_item.dart';

abstract class CartRepository {
  /// يضيف العناصر (ويدمج المكرر) ويعيد عدد أسطر السلة.
  Future<Either<Failure, int>> addItems(List<CartItem> items);

  /// عدد أسطر السلة.
  Future<Either<Failure, int>> getCount();
}