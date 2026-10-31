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

  List<Product>? _cache;
  DateTime? _cachedAt;

  Future<List<Product>> _loadCatalog() async {
    final cached = _cache;
    final at = _cachedAt;
    if (cached != null &&
        at != null &&
        DateTime.now().difference(at) < _cacheTtl) {
      return cached;
    }
    final fresh = await _catalog.fetchProducts();
    _cache = fresh;
    _cachedAt = DateTime.now();
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

      if (extraction != null && extraction.unclear && extraction.items.isEmpty) {
        return AssistantResult(transcript: input, unclear: true, items: const []);
      }

      final products = await _loadCatalog();
      final List<SuggestionItem> items;
      if (extraction != null && extraction.items.isNotEmpty) {
        items = _resolveExtraction(extraction, products);
      } else {
        items = _mergeDuplicates([
          for (final r in _parser.parse(input)) _matcher.resolve(r, products),
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
      if (extraction.unclear && extraction.items.isEmpty) {
        return AssistantResult(
          transcript: extraction.transcript,
          unclear: true,
          items: const [],
        );
      }
      final products = await _loadCatalog();
      final items = _resolveExtraction(extraction, products);
      return AssistantResult(
        transcript: extraction.transcript,
        unclear: items.isEmpty,
        items: items,
      );
    });
  }

  List<SuggestionItem> _resolveExtraction(
      ExtractionModel extraction,
      List<Product> products,
      ) {
    final items = <SuggestionItem>[];
    for (final item in extraction.items) {
      if (item.isPrint) {
        items.add(SuggestionItem.printJob(requestText: item.name));
        continue;
      }
      final tokens = _tokens(item.name);
      if (tokens.isEmpty) continue;
      items.add(_matcher.resolve(
        RequestedItem(
          tokens: tokens,
          quantity: item.quantity,
          hasExplicitQuantity: true,
          alternatives: [
            for (final term in item.searchTerms)
              if (_tokens(term).isNotEmpty) _tokens(term),
          ],
        ),
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