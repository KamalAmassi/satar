import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/services/stt_service.dart';
import 'package:project/core/services/tts_service.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_voice_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/repositories/voice_repository_impl.dart';
import 'package:project/customer/features/ai_assistant/domain/usecases/run_voice_turn_usecase.dart';
import 'package:project/customer/features/ai_assistant/data/models/suggested_product_model.dart';
import 'package:project/customer/features/ai_assistant/presentation/controllers/voice_controller.dart';
import 'package:project/customer/features/ai_assistant/presentation/assistant_page.dart' show AssistantController, Phase;

/// ربط الوضع الصوتي. الكتالوج يُبنى بنفس طريقة المساعد النصي (غير مسجّل في GetX).
class VoiceBinding extends Bindings {
  @override
  void dependencies() {
    final catalog = CatalogRemoteDataSourceImpl(Get.find<ApiClient>().dio);
    Get.lazyPut<SttService>(SttService.new);
    Get.lazyPut<TtsService>(TtsService.new);
    Get.lazyPut<VoiceController>(
      () => VoiceController(
        stt: Get.find<SttService>(),
        tts: Get.find<TtsService>(),
        runTurn: RunVoiceTurnUseCase(VoiceRepositoryImpl(GeminiVoiceDataSource(GeminiVoiceDataSource.buildDio()))),
        searchCatalog: (q) async => [for (final p in await catalog.search(q)) SuggestedProductModel.fromProduct(p)],
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
