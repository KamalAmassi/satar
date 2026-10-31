import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

class RecordedAudio {
  const RecordedAudio(this.wavBytes, this.duration);

  final Uint8List wavBytes;
  final Duration duration;
}

/// تسجيل PCM16 (16kHz mono) بالذاكرة وتغليفه كـ WAV. لا ملفات مؤقتة.
class AudioRecorderService {
  static const _sampleRate = 16000;

  final AudioRecorder _recorder = AudioRecorder();
  final BytesBuilder _pcm = BytesBuilder(copy: false);
  final StreamController<double> _levels = StreamController<double>.broadcast();
  StreamSubscription<Uint8List>? _streamSub;
  StreamSubscription<Amplitude>? _ampSub;

  /// مستوى الصوت من 0 إلى 1 (لحركة الواجهة).
  Stream<double> get levels => _levels.stream;

  Future<bool> requestPermission() => _recorder.hasPermission();

  Future<void> start() async {
    _pcm.clear();
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
      ),
    );
    _streamSub = stream.listen(_pcm.add);
    _ampSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen((a) => _levels.add(((a.current + 45) / 45).clamp(0.0, 1.0)));
  }

  Future<RecordedAudio?> stop() async {
    await _recorder.stop();
    await _streamSub?.cancel();
    await _ampSub?.cancel();
    _streamSub = null;
    _ampSub = null;

    final pcm = _pcm.takeBytes();
    if (pcm.isEmpty) return null;
    final millis = (pcm.length / (_sampleRate * 2) * 1000).round();
    return RecordedAudio(_toWav(pcm), Duration(milliseconds: millis));
  }

  Future<void> cancel() async {
    await _recorder.stop();
    await _streamSub?.cancel();
    await _ampSub?.cancel();
    _streamSub = null;
    _ampSub = null;
    _pcm.clear();
  }

  Future<void> dispose() async {
    await cancel();
    await _levels.close();
    await _recorder.dispose();
  }

  Uint8List _toWav(Uint8List pcm) {
    final h = ByteData(44);
    void ascii(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        h.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    h.setUint32(4, 36 + pcm.length, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    h.setUint32(16, 16, Endian.little);
    h.setUint16(20, 1, Endian.little); // PCM
    h.setUint16(22, 1, Endian.little); // mono
    h.setUint32(24, _sampleRate, Endian.little);
    h.setUint32(28, _sampleRate * 2, Endian.little);
    h.setUint16(32, 2, Endian.little);
    h.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    h.setUint32(40, pcm.length, Endian.little);

    final out = BytesBuilder(copy: false)
      ..add(h.buffer.asUint8List())
      ..add(pcm);
    return out.takeBytes();
  }
}