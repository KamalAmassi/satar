import 'package:equatable/equatable.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';

/// ملخص خطة بكج/هدية: المجموع والميزانية وما حُذف.
class PlanSummary extends Equatable {
  const PlanSummary({
    required this.totalAmount,
    this.budgetAmount,
    this.overBudget = false,
    this.droppedRoles = const [],
    this.replacedRoles = const [],
  });

  /// بالأغورة (نفس وحدة الأسعار).
  final int totalAmount;
  final int? budgetAmount;
  final bool overBudget;
  final List<String> droppedRoles;
  final List<String> replacedRoles;

  @override
  List<Object?> get props => [totalAmount, budgetAmount, overBudget, droppedRoles, replacedRoles];
}

class AssistantResult extends Equatable {
  const AssistantResult({
    required this.transcript,
    required this.unclear,
    required this.items,
    this.clarification,
    this.plan,
  });

  /// الطلب كما فُهم (نص منظّف من الصوت أو النص المكتوب).
  final String transcript;

  /// لم نفهم الطلب أو لا علاقة له بالتسوق.
  final bool unclear;
  final List<SuggestionItem> items;

  /// سؤال توضيحي واحد (إن لزم) بخيارات قصيرة.
  final Clarification? clarification;

  /// بكج/هدية فقط.
  final PlanSummary? plan;

  @override
  List<Object?> get props => [transcript, unclear, items, clarification, plan];
}
