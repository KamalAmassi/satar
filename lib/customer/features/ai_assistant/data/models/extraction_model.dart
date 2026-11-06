import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';

/// ما أرجعه Gemini بعد الفهم: طلبات مهيكلة + سؤال توضيحي اختياري.
class ExtractionModel {
  const ExtractionModel({
    required this.transcript,
    required this.unclear,
    required this.requests,
    this.clarification,
  });

  const ExtractionModel.unclear()
      : transcript = '',
        unclear = true,
        requests = const [],
        clarification = null;

  factory ExtractionModel.fromJson(Map<String, dynamic> json) {
    final requests = [
      for (final e in (json['requests'] as List<dynamic>? ?? const []).take(6))
        if (e is Map) _request(Map<String, dynamic>.from(e)),
    ].whereType<IntentRequest>().toList();
    return ExtractionModel(
      transcript: _s(json['transcript']),
      unclear: json['unclear'] == true,
      requests: requests,
      clarification: _clarification(json['clarification_needed']),
    );
  }

  final String transcript;
  final bool unclear;
  final List<IntentRequest> requests;
  final Clarification? clarification;

  /// الطلبات التي يمكن البحث عنها فعلاً.
  bool get hasSearchable => requests.any((r) => r.kind != IntentKind.unclear && r.kind != IntentKind.question);

  static String _s(Object? v) => (v as String? ?? '').trim();

  static List<String> _list(Object? v) => [
        for (final t in (v as List<dynamic>? ?? const []))
          if (t.toString().trim().isNotEmpty) t.toString().trim(),
      ];

  static Clarification? _clarification(Object? v) {
    if (v is! Map) return null;
    final question = _s(v['question']);
    final options = _list(v['options']).take(4).toList();
    if (question.isEmpty || options.length < 2) return null;
    return Clarification(question: question, options: options);
  }

  static const _attrKeys = ['size', 'pages', 'ruling', 'color', 'brand', 'grade'];

  static ItemSpec? _item(Object? raw, {String fallbackText = ''}) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final type = _s(m['product_type']);
    if (type.isEmpty) return null;
    final attrs = <String, String>{
      for (final k in _attrKeys)
        if (_s(m[k]).isNotEmpty) k: _s(m[k]),
    };
    return ItemSpec(
      productType: type,
      pack: m['pack'] == 'pack' ? PackMode.pack : PackMode.single,
      quantity: ((m['quantity'] as num?)?.toInt() ?? 1).clamp(1, 50),
      attributes: attrs,
      mustHave: _list(m['must_have_terms']),
      mustNot: _list(m['must_not_terms']),
      originalText: _s(m['original_text']).isEmpty ? fallbackText : _s(m['original_text']),
      role: _s(m['role']),
      essential: m['essential'] != false,
      isPrint: m['is_print'] == true,
      similar: _list(m['similar_terms']).take(4).toList(),
    );
  }

  static IntentKind _kind(Object? v) => switch (v) {
        'specific_item' => IntentKind.specificItem,
        'bundle_for_purpose' => IntentKind.bundleForPurpose,
        'gift_or_toy_for_purpose' => IntentKind.giftOrToyForPurpose,
        'question' => IntentKind.question,
        _ => IntentKind.unclear,
      };

  static IntentRequest? _request(Map<String, dynamic> m) {
    final kind = _kind(m['kind']);
    final text = _s(m['original_text']);
    switch (kind) {
      case IntentKind.specificItem:
        final item = _item(m['item'], fallbackText: text);
        return item == null ? null : IntentRequest(kind: kind, item: item, originalText: text);
      case IntentKind.bundleForPurpose:
        final needed = [
          for (final i in (m['needed_items'] as List<dynamic>? ?? const []).take(8)) _item(i),
        ].whereType<ItemSpec>().toList();
        return IntentRequest(
          kind: kind,
          purpose: _s(m['purpose']),
          audience: _s(m['audience']),
          age: (m['age'] as num?)?.toInt(),
          budget: (m['budget'] as num?)?.toInt(),
          neededItems: needed,
          originalText: text,
        );
      case IntentKind.giftOrToyForPurpose:
        final intents = [
          for (final i in (m['search_intents'] as List<dynamic>? ?? const []).take(4)) _item(i),
        ].whereType<ItemSpec>().toList();
        return IntentRequest(
          kind: kind,
          recipient: _s(m['recipient']),
          age: (m['age'] as num?)?.toInt(),
          occasion: _s(m['occasion']),
          interests: _list(m['interests']),
          desiredTraits: _list(m['desired_traits']),
          budget: (m['budget'] as num?)?.toInt(),
          searchIntents: intents,
          originalText: text,
        );
      case IntentKind.question:
      case IntentKind.unclear:
        return IntentRequest(kind: kind, originalText: text);
    }
  }
}
