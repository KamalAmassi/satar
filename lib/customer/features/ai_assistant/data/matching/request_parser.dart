
import 'package:project/core/utils/arabic_text.dart';

class RequestedItem {
  const RequestedItem({
    required this.tokens,
    required this.quantity,
    required this.hasExplicitQuantity,
    this.alternatives = const [],
  });

  final List<String> tokens;
  final int quantity;
  final bool hasExplicitQuantity;

  final List<List<String>> alternatives;

  String get query => tokens.join(' ');
}

class RequestParser {
  const RequestParser();

  static const _numberWords = {
    'واحد': 1, 'وحده': 1, 'اثنين': 2, 'اتنين': 2, 'ثنتين': 2,
    'ثلاث': 3, 'ثلاثه': 3, 'تلات': 3, 'تلاته': 3,
    'اربع': 4, 'اربعه': 4, 'خمس': 5, 'خمسه': 5,
    'ست': 6, 'سته': 6, 'سبع': 7, 'سبعه': 7,
    'ثمان': 8, 'ثمانيه': 8, 'تمن': 8, 'تمانيه': 8,
    'تسع': 9, 'تسعه': 9, 'عشر': 10, 'عشره': 10,
  };

  static const _fillers = {
    'بدي', 'بدنا', 'بدك', 'اريد', 'ابي', 'ابغي', 'ممكن', 'لو', 'سمحت',
    'عندكم', 'جيبلي', 'اعطيني', 'الي', 'لي',
  };

  static const _separators = {'مع', 'و', 'كمان', 'وكمان', 'بالاضافه'};

  int? _numberOf(String token) {
    final digits = int.tryParse(token);
    if (digits != null) return digits >= 1 && digits <= 50 ? digits : null;
    return _numberWords[token];
  }

  List<RequestedItem> parse(String text) {
    final segments = <List<String>>[];

    for (final chunk in text.split(RegExp(r'[،؛,;\n]+'))) {
      var current = <String>[];
      void flush() {
        if (current.isNotEmpty) segments.add(current);
        current = <String>[];
      }

      for (var token in ArabicText.normalize(chunk).split(' ')) {
        if (token.isEmpty) continue;
        if (_separators.contains(token)) {
          flush();
          continue;
        }
        // "وثلاث" / "وطباعة" ملتصقة: واو العطف تفصل عنصراً جديداً.
        if (token.startsWith('و') && token.length > 3) {
          final rest = token.substring(1);
          if (_numberOf(rest) != null || current.isNotEmpty) {
            flush();
            token = rest;
          }
        }
        current.add(token);
      }
      flush();
    }

    final items = <RequestedItem>[];
    for (final tokens in segments) {
      var quantity = 1;
      var explicit = false;
      final query = <String>[];
      for (final token in tokens) {
        if (_fillers.contains(token)) continue;
        final number = _numberOf(token);
        if (number != null && !explicit) {
          quantity = number;
          explicit = true;
          continue;
        }
        query.add(token);
      }
      if (query.isEmpty) continue;
      items.add(RequestedItem(
        tokens: query,
        quantity: quantity,
        hasExplicitQuantity: explicit,
      ));
    }
    return items;
  }
}