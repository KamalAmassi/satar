import 'package:dartz/dartz.dart';
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/arabic_text.dart';
import 'package:project/customer/features/ai_assistant/data/catalog/catalog_index.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/matching/arabic_lexicon.dart';
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
      CatalogRemoteDataSource catalog,
      this._gemini,
      this._parser,
      this._matcher, {
      CatalogProvider? provider,
      })  : _provider = provider ?? CatalogProvider(catalog);

  final GeminiExtractor _gemini;
  final RequestParser _parser;
  final ProductMatcher _matcher;
  final CatalogProvider _provider;

  static const _maxTextLength = 500;

  @override
  Future<Either<Failure, AssistantResult>> suggestFromText(String text) {
    return ErrorHandler.guard(() async {
      final input = text.length > _maxTextLength ? text.substring(0, _maxTextLength) : text;

      // Gemini أولاً، وإذا فشل لأي سبب نرجع للمحلل المحلي.
      ExtractionModel? extraction;
      try {
        extraction = await _gemini.fromText(input);
      } catch (_) {
        extraction = null;
      }
      if (extraction != null && extraction.hasSearchable) {
        return _build(input, extraction);
      }
      if (extraction != null && extraction.clarification != null) {
        return AssistantResult(transcript: input, unclear: false, items: const [], clarification: extraction.clarification);
      }
      if (extraction != null && extraction.unclear) {
        return AssistantResult(transcript: input, unclear: true, items: const []);
      }

      final index = await _provider.load();
      final parsed = _parser.parse(input);
      final items = _mergeDuplicates([
        for (final r in parsed) _matcher.resolve(_specFromTokens(r), index),
      ]);
      return AssistantResult(transcript: input, unclear: items.isEmpty, items: items);
    });
  }

  @override
  Future<Either<Failure, AssistantResult>> suggestFromAudio(AudioClip clip) {
    return ErrorHandler.guard(() async {
      // أخطاء Gemini تُرمى كـ Failure جاهزة (حصة/شبكة/غير متاح).
      final extraction = await _gemini.fromAudio(clip.bytes, clip.mimeType);
      if (!extraction.hasSearchable) {
        return AssistantResult(
          transcript: extraction.transcript,
          unclear: extraction.clarification == null,
          items: const [],
          clarification: extraction.clarification,
        );
      }
      return _build(extraction.transcript, extraction);
    });
  }

  Future<AssistantResult> _build(String transcript, ExtractionModel extraction) async {
    final index = await _provider.load();
    final items = <SuggestionItem>[];
    for (final r in extraction.requests) {
      if (r.kind != IntentKind.specificItem || r.item == null) continue;
      final spec = r.item!;
      items.add(spec.isPrint
          ? SuggestionItem.printJob(requestText: spec.originalText.isEmpty ? spec.productType : spec.originalText)
          : _matcher.resolve(spec, index));
    }
    final merged = _mergeDuplicates(items);
    return AssistantResult(
      transcript: transcript,
      unclear: merged.isEmpty,
      items: merged,
      clarification: extraction.clarification,
    );
  }

  /// احتياطي بلا نموذج: أول كلمة = النوع، الكلمات الباقية شروط، وكلمات العبوة تحدد pack.
  ItemSpec _specFromTokens(RequestedItem r) {
    final rest = <String>[];
    var pack = PackMode.single;
    for (final t in r.tokens) {
      if (ArabicLexicon.packStems.contains(ArabicText.stem(t))) {
        pack = PackMode.pack;
      } else {
        rest.add(t);
      }
    }
    return ItemSpec(
      productType: rest.isEmpty ? r.query : rest.first,
      pack: pack,
      quantity: r.quantity,
      mustHave: rest.skip(1).toList(),
      originalText: r.query,
    );
  }

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
          level: first.level,
          note: first.note,
          close: first.close,
          similar: first.similar,
          role: first.role,
        );
      }
    }
    return result;
  }
}
