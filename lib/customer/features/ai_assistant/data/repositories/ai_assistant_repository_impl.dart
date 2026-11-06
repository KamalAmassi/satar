import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:project/core/errors/error_handler.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/utils/arabic_text.dart';
import 'package:project/customer/features/ai_assistant/data/catalog/catalog_index.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/matching/arabic_lexicon.dart';
import 'package:project/customer/features/ai_assistant/data/matching/bundle_planner.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_extractor.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_judge.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_scorer.dart';
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
      GeminiJudge? judge,
      })  : _provider = provider ?? CatalogProvider(catalog),
        _judge = judge;

  final GeminiExtractor _gemini;
  final RequestParser _parser;
  final ProductMatcher _matcher;
  final CatalogProvider _provider;
  late final BundlePlanner _planner = BundlePlanner(_matcher);
  final GeminiJudge? _judge;

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
    final specs = [
      for (final r in extraction.requests)
        if (r.kind == IntentKind.specificItem && r.item != null) r.item!,
    ];
    final scored = <int, List<ScoredMatch>>{
      for (var i = 0; i < specs.length; i++)
        if (!specs[i].isPrint) i: _matcher.scorer.score(specs[i], index),
    };

    // حكم اختياري: نداء واحد لكل الطلب، فقط حين تكون نتيجة صنف ما ملتبسة (أكثر من exact).
    final ambiguous = [
      for (final e in scored.entries)
        if (_matcher.scorer.rank(e.value).exact.length >= 2)
          JudgeRequest(index: e.key, spec: specs[e.key], candidates: e.value.take(GeminiRestJudge.maxCandidates).toList()),
    ];
    if (ambiguous.isNotEmpty && _judge != null) {
      try {
        final verdicts = await _judge.judge(ambiguous);
        for (final req in ambiguous) {
          scored[req.index] = applyJudge(scored[req.index]!, [for (final v in verdicts) if (v.request == req.index) v]);
        }
      } catch (_) {
        // الحكم اختياري؛ نكمل بالنتيجة الحتمية.
      }
    }

    final items = <SuggestionItem>[];
    for (var i = 0; i < specs.length; i++) {
      final spec = specs[i];
      if (spec.isPrint) {
        items.add(SuggestionItem.printJob(requestText: spec.originalText.isEmpty ? spec.productType : spec.originalText));
        continue;
      }
      final ranked = _matcher.scorer.rank(scored[i]!);
      if (kDebugMode) {
        debugPrint('[ai] kind=specific_item candidates=${scored[i]!.length} '
            'exact=${ranked.exact.map((m) => m.entry.id).toList()} close=${ranked.close.map((m) => m.entry.id).toList()}');
      }
      items.add(_matcher.fromRanked(spec, ranked));
    }
    final merged = _mergeDuplicates(items);

    // بكج / هدية: كل دور أو نية يمر بنفس الاسترجاع والتحقق، من الكتالوج فقط.
    final planned = <SuggestionItem>[];
    PlanSummary? plan;
    for (final r in extraction.requests) {
      if (r.kind == IntentKind.bundleForPurpose && r.neededItems.isNotEmpty) {
        final p = _planner.bundle(r, index);
        planned.addAll(p.items);
        plan ??= p.plan;
      } else if (r.kind == IntentKind.giftOrToyForPurpose && r.searchIntents.isNotEmpty) {
        final p = _planner.gift(r, index);
        planned.addAll(p.items);
        plan ??= p.plan;
      }
    }
    final all = [...merged, ...planned];
    return AssistantResult(
      transcript: transcript,
      unclear: all.isEmpty && extraction.clarification == null,
      items: all,
      clarification: extraction.clarification,
      plan: plan,
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
