import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/extensions/failure_extensions.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/services/audio_recorder_service.dart';
import 'package:project/core/utils/usecase.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/assistant_result.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/audio_clip.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';
import 'package:project/customer/features/ai_assistant/domain/failures/ai_failures.dart';
import 'package:project/customer/features/ai_assistant/domain/usecases/suggest_from_audio_usecase.dart';
import 'package:project/customer/features/ai_assistant/domain/usecases/suggest_products_usecase.dart';
import 'package:project/customer/features/ai_assistant/presentation/controllers/assistant_state.dart';
import 'package:project/customer/features/ai_assistant/presentation/widgets/suggestions_sheet.dart';
import 'package:project/customer/features/cart/domain/entities/cart_item.dart';
import 'package:project/customer/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:project/customer/features/cart/domain/usecases/get_cart_count_usecase.dart';

enum ChatMessageType { userText, userAudio, assistantThinking, assistantResult, assistantError }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.type,
    this.text,
    this.audioDuration,
    this.items,
    this.errorMessage,
    required this.timestamp,
  });

  final String id;
  final ChatMessageType type;
  final String? text;
  final Duration? audioDuration;
  final List<SuggestionItem>? items;
  final String? errorMessage;
  final DateTime timestamp;
}

class AiAssistantController extends GetxController with WidgetsBindingObserver {
  AiAssistantController(
      this._suggestFromText,
      this._suggestFromAudio,
      this._addToCart,
      this._getCartCount,
      this._recorder,
      );

  final SuggestProductsUseCase _suggestFromText;
  final SuggestFromAudioUseCase _suggestFromAudio;
  final AddToCartUseCase _addToCart;
  final GetCartCountUseCase _getCartCount;
  final AudioRecorderService _recorder;

  static const maxSeconds = 60;
  static const _minRecording = Duration(seconds: 1);

  final textController = TextEditingController();
  final scrollController = ScrollController();

  final state = AssistantState.idle.obs;
  final elapsed = 0.obs;
  final level = 0.0.obs;
  final analyzingStep = 0.obs; // 0: listening/sending, 1: understanding, 2: searching
  final cartCount = 0.obs;
  final isAdding = false.obs;
  final items = <SuggestionItem>[].obs;
  final transcript = ''.obs;
  final lastError = RxnString();
  final messages = <ChatMessage>[].obs;

  AudioClip? _lastClip;
  Timer? _tick;
  StreamSubscription<double>? _levelSub;
  bool _starting = false;

  AppLocalizations get _l10n => Get.context!.l10n;

  bool get isRecording => state.value == AssistantState.recording;
  bool get isAnalyzing => state.value == AssistantState.analyzing;
  bool get canRetry => _lastClip != null || textController.text.trim().isNotEmpty;
  bool get _canStart =>
      state.value == AssistantState.idle || state.value == AssistantState.error;

  int get includedCount => items.where((i) => i.isIncluded).length;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _refreshCartCount();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && isRecording) {
      cancelRecording();
    }
  }

  Future<void> _refreshCartCount() async {
    final result = await _getCartCount(const NoParams());
    result.fold((_) {}, (count) => cartCount.value = count);
  }

  // ───────── التسجيل ─────────

  Future<void> toggleRecording() async {
    if (isRecording) return stopRecording();
    if (!_canStart || _starting) return;

    _starting = true;
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      final granted = await _recorder.requestPermission();
      if (!granted) {
        _notifyPermission();
        return;
      }
      await _recorder.start();
    } catch (_) {
      _notify(_l10n.aiMicError, error: true);
      return;
    } finally {
      _starting = false;
    }

    elapsed.value = 0;
    level.value = 0;
    lastError.value = null;
    _lastClip = null;
    state.value = AssistantState.recording;
    HapticFeedback.mediumImpact();

    _levelSub = _recorder.levels.listen((v) => level.value = v);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed.value++;
      if (elapsed.value >= maxSeconds) stopRecording();
    });
  }

  Future<void> stopRecording() async {
    if (!isRecording) return;
    _stopRecordingTimers();

    final audio = await _recorder.stop();
    if (audio == null || audio.duration < _minRecording) {
      state.value = AssistantState.idle;
      _notify(_l10n.aiTooShort, error: true);
      return;
    }
    _lastClip = AudioClip(bytes: audio.wavBytes, mimeType: 'audio/wav');
    HapticFeedback.lightImpact();

    messages.add(ChatMessage(
      id: DateTime.now().toIso8601String(),
      type: ChatMessageType.userAudio,
      audioDuration: audio.duration,
      timestamp: DateTime.now(),
    ));
    scrollToBottom();

    await _analyze(() => _suggestFromAudio(_lastClip!));
  }

  Future<void> cancelRecording() async {
    if (!isRecording) return;
    _stopRecordingTimers();
    await _recorder.cancel();
    state.value = AssistantState.idle;
  }

  void _stopRecordingTimers() {
    _tick?.cancel();
    _levelSub?.cancel();
    _tick = null;
    _levelSub = null;
    level.value = 0;
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ───────── التحليل ─────────

  Future<void> submitText({String? quickText}) async {
    final text = (quickText ?? textController.text).trim();
    if (text.isEmpty) {
      _notify(_l10n.aiEmptyInput, error: true);
      return;
    }
    if (!_canStart) return;
    FocusManager.instance.primaryFocus?.unfocus();
    _lastClip = null;
    textController.clear();

    messages.add(ChatMessage(
      id: DateTime.now().toIso8601String(),
      type: ChatMessageType.userText,
      text: text,
      timestamp: DateTime.now(),
    ));
    scrollToBottom();

    await _analyze(() => _suggestFromText(text), fallbackTranscript: text);
  }

  Future<void> retry() async {
    final clip = _lastClip;
    if (clip != null) {
      await _analyze(() => _suggestFromAudio(clip));
    } else {
      final lastUserMsg = messages.lastWhereOrNull((m) => m.type == ChatMessageType.userText);
      if (lastUserMsg?.text != null) {
        final text = lastUserMsg!.text!;
        await _analyze(() => _suggestFromText(text), fallbackTranscript: text);
      } else {
        await submitText();
      }
    }
  }

  Future<void> _analyze(
      Future<Either<Failure, AssistantResult>> Function() run, {
        String fallbackTranscript = '',
      }) async {
    lastError.value = null;
    state.value = AssistantState.analyzing;
    analyzingStep.value = 0;

    final thinkingId = DateTime.now().toIso8601String();
    messages.add(ChatMessage(
      id: thinkingId,
      type: ChatMessageType.assistantThinking,
      timestamp: DateTime.now(),
    ));
    scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 600));
    if (state.value == AssistantState.analyzing) analyzingStep.value = 1;
    await Future.delayed(const Duration(milliseconds: 800));
    if (state.value == AssistantState.analyzing) analyzingStep.value = 2;

    final result = await run();

    messages.removeWhere((m) => m.id == thinkingId);

    result.fold(
          (failure) {
        final errMessage = _messageOf(failure);
        lastError.value = errMessage;
        state.value = AssistantState.error;
        messages.add(ChatMessage(
          id: DateTime.now().toIso8601String(),
          type: ChatMessageType.assistantError,
          errorMessage: errMessage,
          timestamp: DateTime.now(),
        ));
        scrollToBottom();
      },
          (data) {
        if (data.unclear || data.items.isEmpty) {
          _lastClip = null;
          final errMessage = _l10n.aiNotUnderstood;
          lastError.value = errMessage;
          state.value = AssistantState.error;
          messages.add(ChatMessage(
            id: DateTime.now().toIso8601String(),
            type: ChatMessageType.assistantError,
            errorMessage: errMessage,
            timestamp: DateTime.now(),
          ));
          scrollToBottom();
          return;
        }
        transcript.value =
        data.transcript.isEmpty ? fallbackTranscript : data.transcript;
        items.assignAll(data.items);
        state.value = AssistantState.results;

        messages.add(ChatMessage(
          id: DateTime.now().toIso8601String(),
          type: ChatMessageType.assistantResult,
          items: List.from(data.items),
          timestamp: DateTime.now(),
        ));
        scrollToBottom();
        _showSheet();
      },
    );
  }

  String _messageOf(Failure failure) {
    if (failure.message != null && failure.message!.isNotEmpty) {
      return failure.message!;
    }
    if (failure is AiQuotaFailure) return _l10n.aiQuota;
    if (failure is AiUnavailableFailure) return _l10n.aiServiceUnavailable;
    return failure.localized(_l10n);
  }

  void dismissError() {
    lastError.value = null;
    state.value = AssistantState.idle;
  }

  void _showSheet() {
    Get.bottomSheet(
      const SuggestionsSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).whenComplete(() {
      if (state.value == AssistantState.results) {
        state.value = AssistantState.idle;
      }
    });
  }

  void changeQuantity(int index, int value) {
    HapticFeedback.selectionClick();
    items[index] = items[index].withQuantity(value);
  }

  void useAlternative(int index, SuggestedProduct alternative) {
    HapticFeedback.lightImpact();
    items[index] = items[index].substitutedWith(alternative);
  }

  void editRequest() {
    final text = transcript.value;
    if (text.isNotEmpty) {
      textController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    Get.back();
    state.value = AssistantState.idle;
  }

  void openPrinting() {
    Get.back();
    Get.toNamed(CustomerRoutes.printing);
  }

  Future<void> addToCart() async {
    final cartItems = [
      for (final item in items.where((i) => i.isIncluded))
        CartItem(
          productId: item.product!.id,
          name: item.product!.name,
          quantity: item.quantity,
          priceLabel: item.product!.priceLabel,
          imageUrl: item.product!.imageUrl,
          options: item.product!.selectedOptions,
        ),
    ];
    if (cartItems.isEmpty || isAdding.value) return;

    isAdding.value = true;
    final result = await _addToCart(cartItems);
    isAdding.value = false;

    result.fold(
          (failure) => _notify(failure.localized(_l10n), error: true),
          (count) {
        cartCount.value = count;
        HapticFeedback.mediumImpact();
        Get.back();
        textController.clear();
        items.clear();
        transcript.value = '';
        state.value = AssistantState.idle;
        _notify(_l10n.aiAddedToCart(cartItems.length));
      },
    );
  }

  void _notify(String message, {bool error = false}) {
    Get.rawSnackbar(
      message: message,
      backgroundColor: error ? AppColors.error : AppColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  void _notifyPermission() {
    Get.rawSnackbar(
      message: _l10n.aiMicPermission,
      backgroundColor: AppColors.error,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: openAppSettings,
        child: Text(
          _l10n.aiOpenSettings,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _levelSub?.cancel();
    _recorder.dispose();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
