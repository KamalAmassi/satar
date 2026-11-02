import 'package:project/core/network/api_client.dart';
import 'package:project/customer/features/cart/domain/entities/product_info.dart';

/// قراءة فقط من كتالوج محمد، لعرض أسطر السلة.
abstract class ProductRemoteDataSource {
  Future<ProductInfo> product(int productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<ProductInfo> product(int productId) async {
    final res = await _api.dio.get<dynamic>('v1/products/$productId');
    return ProductInfo.fromJson(ApiClient.unwrapMap(res));
  }
}
