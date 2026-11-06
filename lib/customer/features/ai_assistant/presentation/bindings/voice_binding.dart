import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/services/stt_service.dart';
import 'package:project/core/services/tts_service.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_voice_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/repositories/voice_repository_impl.dart';
import 'package:project/customer/features/ai_assistant/domain/usecases/run_voice_turn_usecase.dart';
import 'package:project/customer/features/ai_assistant/data/catalog/catalog_index.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_matcher.dart';
import 'package:project/customer/features/ai_assistant/data/models/suggested_product_model.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/voice_repository.dart';
import 'package:project/customer/features/ai_assistant/presentation/controllers/voice_controller.dart';
import 'package:project/customer/features/ai_assistant/presentation/assistant_page.dart' show AssistantController, Phase;

/// ربط الوضع الصوتي. الكتالوج يُبنى بنفس طريقة المساعد النصي (غير مسجّل في GetX).
class VoiceBinding extends Bindings {
  @override
  void dependencies() {
    final catalog = CatalogRemoteDataSourceImpl(Get.find<ApiClient>().dio);
    final provider = CatalogProvider(catalog);
    Get.lazyPut<SttService>(SttService.new);
    Get.lazyPut<TtsService>(TtsService.new);
    Get.lazyPut<VoiceController>(
      () => VoiceController(
        stt: Get.find<SttService>(),
        tts: Get.find<TtsService>(),
        runTurn: RunVoiceTurnUseCase(VoiceRepositoryImpl(GeminiVoiceDataSource(GeminiVoiceDataSource.buildDio()))),
        searchCatalog: (args) async => verifiedCatalogSearch(provider, args),
        requestMic: () async => (await Permission.microphone.request()).isGranted,
        stopOtherRecorder: () {
          if (Get.isRegistered<AssistantController>()) {
            final a = Get.find<AssistantController>();
            if (a.phase.value == Phase.recording) a.reset();
          }
        },
      ),
    );
  }
}

/// أداة search_catalog الصوتية: نفس المحرك (فهرس محلي + مسجِّل حتمي)، بلا نداء نموذج إضافي.
/// exact حتى 3، ثم close حتى 2؛ والبدائل فقط إن لم يوجد غيرها.
Future<List<MatchedProduct>> verifiedCatalogSearch(CatalogProvider provider, VoiceSearchArgs args) async {
  final index = await provider.load();
  final spec = ItemSpec(
    productType: args.productType,
    pack: args.pack,
    attributes: args.attributes,
    mustNot: args.mustNot,
    originalText: args.productType,
  );
  final ranked = const ProductMatcher().scorer.resolve(spec, index);
  MatchedProduct conv(m) => MatchedProduct(product: SuggestedProductModel.fromProduct(m.entry.product), level: m.level, note: m.note);
  return [
    for (final m in ranked.exact.take(3)) conv(m),
    for (final m in ranked.close.take(2)) conv(m),
    if (ranked.exact.isEmpty && ranked.close.isEmpty)
      for (final m in ranked.alternatives.take(2)) conv(m),
  ];
}
