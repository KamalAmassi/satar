import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class AudioClip extends Equatable {
  const AudioClip({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;

  @override
  List<Object?> get props => [bytes.length, mimeType];
}