import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// تعرّف على الكلام العربي (STT). يتدهور بصمت: `initialize()` ترجع false ولا ترمي.
class SttService extends GetxService {
  SpeechToText? _stt;
  bool available = false;
  String? _locale;

  /// مستوى الصوت المطبّع 0..1 (مُنعَّم).
  final RxDouble level = 0.0.obs;
  bool listening = false;

  double _lo = 0, _hi = 1;
  int _session = 0;
  bool _delivered = false;
  String _lastWords = '';
  void Function(String)? _onFinal;
  void Function()? _onEmpty;

  Future<bool> initialize() async {
    if (available) return true;
    try {
      final s = _stt ??= SpeechToText();
      available = await s.initialize(onStatus: _onStatus, onError: (_) => _ended());
      if (available) {
        final locales = await s.locales();
        String? pick(bool Function(String id) test) {
          for (final l in locales) {
            if (test(l.localeId.replaceAll('-', '_'))) return l.localeId;
          }
          return null;
        }

        _locale = pick((id) => id == 'ar_PS') ?? pick((id) => id == 'ar_SA') ?? pick((id) => id.startsWith('ar_'));
        if (_locale == null) available = false; // لا تعرّف عربي على الجهاز.
      }
    } catch (_) {
      available = false;
    }
    return available;
  }

  Future<void> listen({
    void Function(String)? onPartial,
    required void Function(String) onFinal,
    void Function(double)? onSoundLevel,
    required void Function() onEmpty,
  }) async {
    final s = _stt;
    if (!available || s == null) {
      onEmpty();
      return;
    }
    final id = ++_session;
    _delivered = false;
    _lastWords = '';
    _onFinal = onFinal;
    _onEmpty = onEmpty;
    listening = true;
    try {
      await s.listen(
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          localeId: _locale,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
        onSoundLevelChange: (db) {
          // المدى يختلف بين المنصات (أندرويد ~ -2..10، iOS ~ -160..0): نطبّعه بالمدى المرصود.
          _lo = db < _lo ? db : _lo;
          _hi = db > _hi ? db : _hi;
          final n = _hi - _lo > 1 ? ((db - _lo) / (_hi - _lo)).clamp(0.0, 1.0) : 0.0;
          level.value = level.value + (n - level.value) * 0.35;
          onSoundLevel?.call(level.value);
        },
        onResult: (SpeechRecognitionResult r) {
          if (id != _session) return;
          _lastWords = r.recognizedWords;
          if (r.finalResult) {
            _deliver();
          } else {
            onPartial?.call(_lastWords);
          }
        },
      );
    } catch (_) {
      listening = false;
      if (id == _session) onEmpty();
    }
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') _ended();
  }

  /// انتهى الاستماع: نسلّم آخر نص إن وُجد، وإلا جولة فارغة.
  void _ended() {
    if (!listening) return;
    _deliver();
  }

  void _deliver() {
    if (_delivered) return;
    _delivered = true;
    listening = false;
    level.value = 0;
    final text = _lastWords.trim();
    final fin = _onFinal, empty = _onEmpty;
    if (text.isEmpty) {
      empty?.call();
    } else {
      fin?.call(text);
    }
  }

  Future<void> stop() async {
    try {
      await _stt?.stop();
    } catch (_) {}
  }

  /// إلغاء بلا تسليم نتيجة.
  Future<void> cancel() async {
    _session++;
    _delivered = true;
    listening = false;
    level.value = 0;
    try {
      await _stt?.cancel();
    } catch (_) {}
  }

  @override
  void onClose() {
    cancel();
    super.onClose();
  }
}
