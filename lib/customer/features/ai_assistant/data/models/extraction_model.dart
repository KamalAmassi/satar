class ExtractedItem {
  const ExtractedItem({
    required this.name,
    required this.quantity,
    required this.isPrint,
    required this.searchTerms,
  });

  factory ExtractedItem.fromJson(Map<String, dynamic> json) => ExtractedItem(
    name: (json['name'] as String? ?? '').trim(),
    quantity: ((json['quantity'] as num?)?.toInt() ?? 1).clamp(1, 50),
    isPrint: json['kind'] == 'print',
    searchTerms: [
      for (final t in (json['search_terms'] as List<dynamic>? ?? const []))
        t.toString(),
    ],
  );

  final String name;
  final int quantity;
  final bool isPrint;
  final List<String> searchTerms;
}

/// ما أرجعه Gemini: الطلب المفهوم + الأصناف.
class ExtractionModel {
  const ExtractionModel({
    required this.transcript,
    required this.unclear,
    required this.items,
  });

  const ExtractionModel.unclear()
      : transcript = '',
        unclear = true,
        items = const [];

  factory ExtractionModel.fromJson(Map<String, dynamic> json) {
    final items = [
      for (final e in (json['items'] as List<dynamic>? ?? const []))
        ExtractedItem.fromJson(Map<String, dynamic>.from(e as Map)),
    ].where((i) => i.name.isNotEmpty).toList();
    return ExtractionModel(
      transcript: (json['transcript'] as String? ?? '').trim(),
      unclear: json['unclear'] == true,
      items: items,
    );
  }

  final String transcript;
  final bool unclear;
  final List<ExtractedItem> items;
}