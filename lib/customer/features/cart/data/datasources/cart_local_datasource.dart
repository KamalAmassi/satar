import 'dart:convert';

import 'package:project/customer/features/cart/data/models/cart_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CartLocalDataSource {
  List<CartItemModel> getItems();
  Future<void> saveItems(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  CartLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'cart_items';

  @override
  List<CartItemModel> getItems() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> saveItems(List<CartItemModel> items) async {
    await _prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}