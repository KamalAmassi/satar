import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/core/l10n/app_localizations_ar.dart';
import 'package:project/core/services/stt_service.dart';
import 'package:project/core/services/tts_service.dart';
import 'package:project/core/utils/arabic_text.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/proposed_item.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';
import 'package:project/customer/features/ai_assistant/domain/failures/ai_failures.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/voice_repository.dart';
import 'package:project/customer/features/ai_assistant/domain/usecases/run_voice_turn_usecase.dart';

enum VoiceState { idle, listening, thinking, speaking, error }

/// حلقة المحادثة الصوتية بلا لمس: استماع ← تفكير ← نطق ← استماع.
/// STT لا يعمل أبدًا أثناء TTS. لا ينفّذ طلبات؛ الإضافة للسلة فقط بعد تأكيد المستخدم.
class VoiceController extends GetxController with WidgetsBindingObserver implements VoiceTools {
  VoiceController({
    required this.stt,
    required this.tts,
    required this.runTurn,
    required this.searchCatalog,
    required this.requestMic,
    this.stopOtherRecorder,
    this.echoGuard = const Duration(milliseconds: 250),
  });

  final SttService stt;
  final TtsService tts;
  final RunVoiceTurnUseCase runTurn;
  final Future<List<SuggestedProduct>> Function(String query) searchCatalog;

  /// يطلب إذن الميكروفون؛ true إن مُنح.
  final Future<bool> Function() requestMic;

  /// يوقف مسجّل المساعد النصي إن كان يعمل (لا يستخدم الميكروفون اثنان معًا).
  final void Function()? stopOtherRecorder;
  final Duration echoGuard;

  static const maxEmptyRounds = 3;
  static const _finishPhrases = ['خلصت', 'خلاص', 'انهاء', 'كفايه', 'تمام خلصت'];

  final state = VoiceState.idle.obs;
  final micDenied = false.obs;
  final unsupported = false.obs;
  final arabicVoiceMissing = false.obs;

  /// بعد 3 جولات صامتة: الحلقة متوقفة وينتظر المستخدم الضغط.
  final paused = true.obs;
  final userCaption = ''.obs;
  final assistantCaption = ''.obs;
  final foundItems = <SuggestedProduct>[].obs;
  final proposals = <ProposedItem>[].obs;

  /// يزداد عند طلب فتح ورقة المراجعة.
  final finishTick = 0.obs;

  final _known = <int, SuggestedProduct>{};
  final _ar = AppLocalizationsAr();
  int _turn = 0;
  int _empty = 0;
  bool _active = false;
  bool _closed = false;

  double get micLevel => stt.level.value;
  bool get speakingNow => state.value == VoiceState.speaking;

  /// تطبيع عربي ثم مطابقة عبارات الإنهاء (جملة قصيرة فقط لتجنب إيقاف عرضي).
  static bool isFinishPhrase(String text) {
    final n = ArabicText.normalize(text);
    if (n.isEmpty || n.split(' ').length > 4) return false;
    for (final p in _finishPhrases) {
      if (n == p || n.contains(p)) return true;
    }
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> start() async {
    if (_active) return;
    stopOtherRecorder?.call();
    micDenied.value = false;
    unsupported.value = false;
    if (!await requestMic()) {
      micDenied.value = true;
      return;
    }
    if (!await stt.initialize()) {
      unsupported.value = true;
      return;
    }
    await tts.init();
    arabicVoiceMissing.value = tts.arabicVoiceMissing;
    _active = true;
    paused.value = false;
    _empty = 0;
    final id = ++_turn;
    await _speak(_ar.voiceGreeting, id);
    if (id == _turn) await _listen();
  }

  Future<void> _speak(String text, int id) async {
    if (_closed) return;
    state.value = VoiceState.speaking;
    assistantCaption.value = text;
    await stt.cancel(); // STT يتوقف قبل النطق دائمًا.
    await tts.speak(text);
    if (_closed || id != _turn) return;
    await Future<void>.delayed(echoGuard); // منع الصدى قبل إعادة الاستماع.
  }

  Future<void> _listen() async {
    if (_closed || !_active || paused.value) return;
    final id = _turn;
    state.value = VoiceState.listening;
    await stt.listen(
      onPartial: (t) {
        if (id == _turn) userCaption.value = t;
      },
      onFinal: (t) {
        if (id == _turn) _onFinal(t);
      },
      onEmpty: () {
        if (id == _turn) _onEmpty();
      },
    );
  }

  void _onEmpty() {
    if (state.value != VoiceState.listening) return;
    if (++_empty >= maxEmptyRounds) {
      pauseLoop();
      return;
    }
    Future<void>.delayed(const Duration(milliseconds: 200), _listen);
  }

  Future<void> _onFinal(String text) async {
    _empty = 0;
    userCaption.value = text;
    if (isFinishPhrase(text)) {
      finish();
      return;
    }
    final id = ++_turn;
    state.value = VoiceState.thinking;
    Haptics.tap();
    final res = await runTurn(VoiceTurnParams(text, this));
    if (_closed || id != _turn) return;
    final reply = res.fold<String>(
      (f) => f is AiQuotaFailure ? _ar.voiceQuotaMessage : _ar.voiceNetworkMessage,
      (t) => t.reply.isEmpty ? _ar.voiceNoItems : t.reply,
    );
    if (res.isLeft()) Haptics.error();
    await _speak(reply, id);
    if (id == _turn) await _listen();
  }

  /// نقر القلم: أثناء النطق يقاطع، وفي الإيقاف يستأنف.
  Future<void> onPenTap() async {
    if (state.value == VoiceState.speaking) {
      final id = ++_turn;
      await tts.stop();
      if (id == _turn) await _listen();
    } else if (paused.value) {
      await resume();
    }
  }

  /// زر الميكروفون: إيقاف/استئناف.
  Future<void> toggleMic() async {
    if (paused.value) {
      await resume();
    } else {
      pauseLoop();
    }
  }

  Future<void> resume() async {
    if (!_active) {
      await start();
      return;
    }
    _empty = 0;
    paused.value = false;
    ++_turn;
    await _listen();
  }

  void pauseLoop() {
    ++_turn;
    paused.value = true;
    stt.cancel();
    tts.stop();
    state.value = VoiceState.idle;
  }

  /// إنهاء المحادثة: كل شيء يتوقف ثم تُفتح ورقة المراجعة.
  void finish() {
    pauseLoop();
    finishTick.value++;
  }

  // ---- أدوات النموذج ----

  @override
  Future<List<SuggestedProduct>> search(String query) async {
    var found = await searchCatalog(query);
    if (found.isEmpty) {
      // احتياط: أطول كلمة في الاستعلام.
      final words = query.split(RegExp(r'\s+'))..sort((a, b) => b.length.compareTo(a.length));
      if (words.length > 1 && words.first.length > 2) found = await searchCatalog(words.first);
    }
    found = found.take(5).toList();
    for (final p in found) {
      _known[p.id] = p;
    }
    foundItems.assignAll(found);
    return found;
  }

  @override
  bool propose(int productId, int quantity) {
    final p = _known[productId];
    if (p == null || !p.isAvailable) return false;
    _setProposal(p, quantity.clamp(ProposedItem.minQty, ProposedItem.maxQty));
    return true;
  }

  /// إضافة يدوية من بطاقة المنتج (+1).
  void proposeManual(SuggestedProduct p) {
    if (!p.isAvailable) return;
    _known[p.id] = p;
    final i = proposals.indexWhere((e) => e.productId == p.id);
    _setProposal(p, i >= 0 ? proposals[i].quantity + 1 : 1);
    Haptics.select();
  }

  void _setProposal(SuggestedProduct p, int qty) {
    final i = proposals.indexWhere((e) => e.productId == p.id);
    final item = ProposedItem(product: p, quantity: qty.clamp(ProposedItem.minQty, ProposedItem.maxQty), selected: i < 0 ? true : proposals[i].selected);
    if (i >= 0) {
      proposals[i] = item;
    } else {
      proposals.add(item);
    }
  }

  void setQuantity(int productId, int qty) {
    final i = proposals.indexWhere((e) => e.productId == productId);
    if (i >= 0) proposals[i] = proposals[i].copyWith(quantity: qty);
  }

  void toggleSelected(int productId) {
    final i = proposals.indexWhere((e) => e.productId == productId);
    if (i >= 0) proposals[i] = proposals[i].copyWith(selected: !proposals[i].selected);
  }

  // ---- دورة الحياة ----

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused || state == AppLifecycleState.inactive) && _active && !paused.value) pauseLoop();
  }

  @override
  void onClose() {
    _closed = true;
    _turn++;
    WidgetsBinding.instance.removeObserver(this);
    stt.cancel();
    tts.stop();
    runTurn.reset();
    super.onClose();
  }
}
