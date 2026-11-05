import 'package:equatable/equatable.dart';

/// نتيجة جولة صوتية واحدة: النص المنطوق الذي سيُقرأ للمستخدم.
class VoiceTurn extends Equatable {
  const VoiceTurn({required this.userText, required this.reply});

  final String userText;
  final String reply;

  @override
  List<Object?> get props => [userText, reply];
}
