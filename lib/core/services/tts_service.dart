import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

/// نطق عربي (TTS). يتدهور بصمت على الأجهزة/المنصات غير المدعومة (لا يرمي أبدًا).
class TtsService extends GetxService {
  FlutterTts? _tts;

  /// true حين لا يتوفر صوت عربي على الجهاز.
  bool arabicVoiceMissing = false;
  bool available = false;
  final RxBool isSpeaking = false.obs;

  static final _markdown = RegExp(r'[*#_`~>|\[\]{}\\]|^\s*[-•]\s+', multiLine: true);
  static final _emoji = RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]', unicode: true);
  static final _spaces = RegExp(r'\s+');

  /// يزيل Markdown والإيموجي والرموز التي يقرؤها المحرّك حرفيًا.
  @visibleForTesting
  static String clean(String s) => s.replaceAll(_markdown, ' ').replaceAll(_emoji, '').replaceAll(_spaces, ' ').trim();

  Future<bool> init() async {
    if (available) return true;
    try {
      final t = _tts ??= FlutterTts();
      final ok = await t.isLanguageAvailable('ar');
      arabicVoiceMissing = ok != true;
      await t.setLanguage('ar');
      await t.setSpeechRate(0.48);
      await t.setPitch(1.0);
      await t.awaitSpeakCompletion(true);
      t.setStartHandler(() => isSpeaking.value = true);
      t.setCompletionHandler(() => isSpeaking.value = false);
      t.setCancelHandler(() => isSpeaking.value = false);
      t.setErrorHandler((_) => isSpeaking.value = false);
      available = true;
    } catch (_) {
      available = false;
    }
    return available;
  }

  /// يكتمل عند انتهاء النطق (أو فورًا إن لم يكن مدعومًا).
  Future<void> speak(String text) async {
    final t = _tts;
    final s = clean(text);
    if (!available || t == null || s.isEmpty) return;
    try {
      isSpeaking.value = true;
      await t.speak(s);
    } catch (_) {
      // تجاهل: لا نكسر الجلسة بسبب النطق.
    } finally {
      isSpeaking.value = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
    isSpeaking.value = false;
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }
}
