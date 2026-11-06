import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/masar_model/masar_models.dart';
import 'package:project/core/utils/arabic_text.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_extractor.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_matcher.dart';
import 'package:project/customer/features/ai_assistant/data/matching/request_parser.dart';
import 'package:project/customer/features/ai_assistant/data/models/extraction_model.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/assistant_result.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/audio_clip.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/ai_assistant_repository.dart';

class AiAssistantRepositoryImpl implements AiAssistantRepository {
  AiAssistantRepositoryImpl(
      this._catalog,
      this._gemini,
      this._parser,
      this._matcher,
      );

  final CatalogRemoteDataSource _catalog;
  final GeminiExtractor _gemini;
  final RequestParser _parser;
  final ProductMatcher _matcher;

  static const _cacheTtl = Duration(minutes: 5);
  static const _maxTextLength = 500;

  final Map<String, ({DateTime at, List<Product> items})> _searchCache = {};

  /// المرشّحون للمطابقة: نتائج بحث الخادم لكل صنف مطلوب (لا نفترض أن صفحة واحدة تمثّل الكتالوج).
  /// يُرجَع اتحاد النتائج بلا تكرار؛ ما لا يجده الخادم يبقى «غير موجود».
  Future<List<Product>> _candidates(Iterable<String> queries) async {
    final qs = <String>{for (final q in queries) if (q.trim().isNotEmpty) q.trim()}.take(12).toList();
    final byId = <int, Product>{};
    for (final q in qs) {
      var found = await _searchOne(q);
      if (found.isEmpty) {
        // لا نتائج للعبارة كاملة: نجرّب أطول كلمة فيها.
        final words = q.split(RegExp(r'\s+'))..sort((x, y) => y.length.compareTo(x.length));
        if (words.length > 1 && words.first.length >= 3) found = await _searchOne(words.first);
      }
      for (final p in found) {
        byId[p.id] = p;
      }
    }
    return byId.values.toList();
  }

  Future<List<Product>> _searchOne(String q) async {
    final hit = _searchCache[q];
    if (hit != null && DateTime.now().difference(hit.at) < _cacheTtl) return hit.items;
    final fresh = await _catalog.search(q);
    _searchCache[q] = (at: DateTime.now(), items: fresh);
    return fresh;
  }

  @override
  Future<Either<Failure, AssistantResult>> suggestFromText(String text) {
    return ErrorHandler.guard(() async {
      final input = text.length > _maxTextLength
          ? text.substring(0, _maxTextLength)
          : text;

      // Gemini أولاً، وإذا فشل لأي سبب نرجع للمحلل المحلي.
      ExtractionModel? extraction;
      try {
        extraction = await _gemini.fromText(input);
      } catch (_) {
        extraction = null;
      }

      if (extraction != null && extraction.unclear && !extraction.hasSearchable) {
        return AssistantResult(transcript: input, unclear: true, items: const []);
      }

      final List<SuggestionItem> items;
      if (extraction != null && extraction.hasSearchable) {
        final products = await _candidates(_extractionQueries(extraction));
        items = _resolveExtraction(extraction, products);
      } else {
        final parsed = _parser.parse(input);
        final products = await _candidates([
          for (final r in parsed) ...[r.tokens.join(' '), for (final a in r.alternatives.take(2)) a.join(' ')],
        ]);
        items = _mergeDuplicates([
          for (final r in parsed) _matcher.resolve(r, products),
        ]);
      }
      return AssistantResult(
        transcript: input,
        unclear: items.isEmpty,
        items: items,
      );
    });
  }

  @override
  Future<Either<Failure, AssistantResult>> suggestFromAudio(AudioClip clip) {
    return ErrorHandler.guard(() async {
      // أخطاء Gemini تُرمى كـ Failure جاهزة (حصة/شبكة/غير متاح).
      final extraction = await _gemini.fromAudio(clip.bytes, clip.mimeType);
      if (extraction.unclear && !extraction.hasSearchable) {
        return AssistantResult(
          transcript: extraction.transcript,
          unclear: true,
          items: const [],
        );
      }
      final products = await _candidates(_extractionQueries(extraction));
      final items = _resolveExtraction(extraction, products);
      return AssistantResult(
        transcript: extraction.transcript,
        unclear: items.isEmpty,
        items: items,
      );
    });
  }

  // انتقالي (الخطوة 2): الطلبات المحددة فقط تُحوَّل لاستعلامات؛ يُستبدل بالمحرك الجديد في الخطوة 3.
  List<ItemSpec> _specs(ExtractionModel e) => [
        for (final r in e.requests)
          if (r.item != null) r.item!,
      ];

  Iterable<String> _extractionQueries(ExtractionModel e) => [
        for (final i in _specs(e))
          if (!i.isPrint) i.productType,
      ];

  List<SuggestionItem> _resolveExtraction(
      ExtractionModel extraction,
      List<Product> products,
      ) {
    final items = <SuggestionItem>[];
    for (final item in _specs(extraction)) {
      if (item.isPrint) {
        items.add(SuggestionItem.printJob(requestText: item.originalText));
        continue;
      }
      final tokens = _tokens('${item.productType} ${item.attributes.values.join(' ')}');
      if (tokens.isEmpty) continue;
      items.add(_matcher.resolve(
        RequestedItem(tokens: tokens, quantity: item.quantity, hasExplicitQuantity: true),
        products,
      ));
    }
    return _mergeDuplicates(items);
  }

  List<String> _tokens(String text) => ArabicText.normalize(text)
      .split(' ')
      .where((t) => t.isNotEmpty)
      .toList();

  /// نفس المنتج مذكور مرتين = سطر واحد بكمية مجمّعة.
  List<SuggestionItem> _mergeDuplicates(List<SuggestionItem> items) {
    final result = <SuggestionItem>[];
    final indexById = <int, int>{};

    for (final item in items) {
      final product = item.product;
      if (product == null || item.status == SuggestionStatus.printJob) {
        result.add(item);
        continue;
      }
      final existingIndex = indexById[product.id];
      if (existingIndex == null) {
        indexById[product.id] = result.length;
        result.add(item);
      } else {
        final first = result[existingIndex];
        result[existingIndex] = SuggestionItem.resolve(
          requestText: first.requestText,
          requestedQty: first.requestedQty + item.requestedQty,
          product: first.product,
          alternatives: first.alternatives,
        );
      }
    }
    return result;
  }
}