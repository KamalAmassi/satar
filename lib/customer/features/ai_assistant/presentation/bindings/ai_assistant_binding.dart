import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:project/core/config/ai_config.dart';
import 'package:project/core/services/audio_recorder_service.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_extractor.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_matcher.dart';
import 'package:project/customer/features/ai_assistant/data/matching/request_parser.dart';
import 'package:project/customer/features/ai_assistant/data/repositories/ai_assistant_repository_impl.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/ai_assistant_repository.dart';
import 'package:project/customer/features/ai_assistant/domain/usecases/suggest_from_audio_usecase.dart';
import 'package:project/customer/features/ai_assistant/domain/usecases/suggest_products_usecase.dart';
import 'package:project/customer/features/ai_assistant/presentation/controllers/ai_assistant_controller.dart';
import 'package:project/customer/features/cart/domain/repositories/cart_repository.dart';
import 'package:project/customer/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:project/customer/features/cart/domain/usecases/get_cart_count_usecase.dart';
import 'package:project/customer/features/cart/presentation/bindings/cart_binding.dart';

class AiAssistantBinding extends Bindings {
  @override
  void dependencies() {
    CartBinding().dependencies();

    Get.lazyPut(() => AddToCartUseCase(Get.find<CartRepository>()));
    Get.lazyPut(() => GetCartCountUseCase(Get.find<CartRepository>()));

    Get.lazyPut<CatalogRemoteDataSource>(
          () => CatalogRemoteDataSourceImpl(Get.find<Dio>()),
    );
    Get.lazyPut<GeminiExtractor>(() => GeminiRestExtractor(_geminiDio()));
    Get.lazyPut<AiAssistantRepository>(
          () => AiAssistantRepositoryImpl(
        Get.find(),
        Get.find(),
        const RequestParser(),
        const ProductMatcher(),
      ),
    );
    Get.lazyPut(() => SuggestProductsUseCase(Get.find()));
    Get.lazyPut(() => SuggestFromAudioUseCase(Get.find()));
    Get.lazyPut(() => AudioRecorderService());
    Get.lazyPut(
          () => AiAssistantController(
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
      ),
    );
  }

  /// Dio خاص بـ Gemini (المفتاح بالهيدر وليس بالـ URL).
  Dio _geminiDio() => Dio(
    BaseOptions(
      baseUrl: AiConfig.geminiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': AiConfig.geminiApiKey,
      },
    ),
  );
}