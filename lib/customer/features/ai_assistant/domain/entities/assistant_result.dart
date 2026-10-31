import 'package:equatable/equatable.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';

class AssistantResult extends Equatable {
  const AssistantResult({
    required this.transcript,
    required this.unclear,
    required this.items,
  });

  /// الطلب كما فُهم (نص منظّف من الصوت أو النص المكتوب).
  final String transcript;

  /// لم نفهم الطلب أو لا علاقة له بالتسوق.
  final bool unclear;
  final List<SuggestionItem> items;

  @override
  List<Object?> get props => [transcript, unclear, items];
}