import 'package:project/core/network/masar_model/masar_models.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';

class SuggestedProductModel extends SuggestedProduct {
  const SuggestedProductModel({
    required super.id,
    required super.name,
    required super.priceAmount,
    required super.priceLabel,
    required super.inStock,
    super.imageUrl,
    super.stock,
    super.categoryId,
    super.selectedOptions,
    super.optionLabels,
  });

  /// كل خيار مطلوب يُختار أول قيمة فيه (نفس منطق الـ Postman).
  factory SuggestedProductModel.fromProduct(Product product) {
    final selected = <String, String>{};
    final labels = <String>[];
    for (final option in product.options) {
      if (option.required && option.choices.isNotEmpty) {
        final choice = option.choices.first;
        selected[option.key] = choice.key;
        labels.add(choice.label);
      }
    }
    return SuggestedProductModel(
      id: product.id,
      name: product.name,
      imageUrl: product.imageUrl,
      priceAmount: product.price.amount,
      priceLabel: product.price.formatted,
      inStock: product.inStock,
      stock: product.stock,
      categoryId: product.categoryId,
      selectedOptions: selected,
      optionLabels: labels,
    );
  }
}