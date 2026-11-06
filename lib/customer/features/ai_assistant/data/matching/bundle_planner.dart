import 'package:project/customer/features/ai_assistant/data/catalog/catalog_index.dart';
import 'package:project/customer/features/ai_assistant/data/matching/arabic_lexicon.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_matcher.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_scorer.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/assistant_result.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';

typedef PlanResult = ({List<SuggestionItem> items, PlanSummary plan});

/// مخطِّط البكج والهدايا: يمرّ على كل دور/نية عبر نفس الاسترجاع والتحقق، من الكتالوج فقط.
class BundlePlanner {
  const BundlePlanner(this.matcher);

  final ProductMatcher matcher;
  ProductScorer get _scorer => matcher.scorer;

  /// الأسعار بالأغورة؛ الميزانية بالشيكل.
  static const _unit = 100;

  // ---------------- بكج ----------------

  PlanResult bundle(IntentRequest r, CatalogIndex index) {
    final hint = '${r.purpose} ${r.audience} ${r.originalText}';
    var needed = r.neededItems.isEmpty ? defaultKit(hint) : r.neededItems;
    // خطة النموذج لم تعطِ أي نتيجة (لا مطابق ولا قريب ولا مشابه): جرّب الخطة الجاهزة.
    if (r.neededItems.isNotEmpty && !_anyHit(r.neededItems, index)) needed = defaultKit(hint);
    var items = <SuggestionItem>[];
    for (final spec in needed) {
      final role = spec.role.isNotEmpty ? spec.role : spec.productType;
      final withRole = ItemSpec(
        productType: spec.productType,
        pack: spec.pack,
        quantity: spec.quantity,
        attributes: spec.attributes,
        mustHave: spec.mustHave,
        mustNot: spec.mustNot,
        originalText: role,
        role: role,
        essential: spec.essential,
        similar: spec.similar,
      );
      items.add(matcher.resolve(withRole, index));
    }
    // أدوار بلا أي نتيجة (لا exact ولا قريب) لا تُعرض كصفوف فارغة.
    final specsByRole = {for (final s in needed) (s.role.isNotEmpty ? s.role : s.productType): s};

    final dropped = <String>[];
    final replaced = <String>[];
    final budget = r.budget == null ? null : r.budget! * _unit;
    var over = false;

    if (budget != null) {
      // 1) استبدال الأغلى ببديل مطابق أرخص.
      for (var guard = 0; guard < 20 && _total(items) > budget; guard++) {
        final order = [for (var i = 0; i < items.length; i++) i]
          ..sort((a, b) => _line(items[b]).compareTo(_line(items[a])));
        var changed = false;
        for (final i in order) {
          final it = items[i];
          final p = it.product;
          if (p == null || !it.isIncluded) continue;
          final cheaper = [for (final a in it.alternatives) if (a.priceAmount < p.priceAmount) a]
            ..sort((a, b) => a.priceAmount.compareTo(b.priceAmount));
          if (cheaper.isEmpty) continue;
          items[i] = it.substitutedWith(cheaper.first);
          if (!replaced.contains(it.role)) replaced.add(it.role);
          changed = true;
          break;
        }
        if (!changed) break;
      }
      // 2) حذف الأغلى من غير الأساسي.
      while (_total(items) > budget) {
        final candidates = [
          for (var i = 0; i < items.length; i++)
            if (items[i].isIncluded && !(specsByRole[items[i].role]?.essential ?? true)) i,
        ]..sort((a, b) => _line(items[b]).compareTo(_line(items[a])));
        if (candidates.isEmpty) break;
        dropped.add(items[candidates.first].role);
        items = [...items]..removeAt(candidates.first);
      }
      over = _total(items) > budget;
    }

    return (
      items: items,
      plan: PlanSummary(
        totalAmount: _total(items),
        budgetAmount: budget,
        overBudget: over,
        droppedRoles: dropped,
        replacedRoles: replaced,
      ),
    );
  }

  bool _anyHit(List<ItemSpec> specs, CatalogIndex index) {
    for (final s in specs) {
      if (_scorer.score(s, index).isNotEmpty) return true;
    }
    return false;
  }

  int _line(SuggestionItem i) => i.isIncluded ? i.product!.priceAmount * i.quantity : 0;
  int _total(List<SuggestionItem> items) => items.fold(0, (s, i) => s + _line(i));

  // ---------------- خطط جاهزة (شبكة أمان) ----------------

  static final _bundleWords = RegExp(r'بكج|طالب|طلاب|توجيهي|ثانوي|جامع|مدرس|تخصص|لوازم|مجموع');

  /// هل النص يطلب مجموعة/بكج؟
  static bool looksLikeBundle(String text) => _bundleWords.hasMatch(ArabicLexicon.stems(text).join(' '));

  static ItemSpec _k(String type, String role, {PackMode pack = PackMode.single, bool essential = true, List<String> similar = const []}) =>
      ItemSpec(productType: type, pack: pack, role: role, essential: essential, similar: similar);

  /// خطة افتراضية حسب الفئة المذكورة؛ تُستخدم حين لا يعطي النموذج خطة أو تفشل كلها.
  static List<ItemSpec> defaultKit(String text) {
    final t = ArabicLexicon.stems(text).join(' ');
    bool has(String w) => t.contains(w);
    if (has('جامع') || has('تخصص') || has('برمج') || has('حاسوب') || RegExp(r'(^| )it( |$)').hasMatch(t)) {
      return [
        _k('دفتر', 'دفاتر', similar: ['كراسة']),
        _k('قلم', 'أقلام'),
        _k('فلاشة', 'فلاشة', similar: ['ذاكرة']),
        _k('ماوس', 'ماوس', essential: false),
        _k('حاسبة', 'آلة حاسبة', similar: ['آلة']),
        _k('ملف', 'ملفات'),
        _k('حقيبة', 'حقيبة', similar: ['شنطة']),
        _k('سماعات', 'سماعات', essential: false),
      ];
    }
    if (has('توجيهي') || has('ثانوي')) {
      return [
        _k('دفتر', 'دفاتر', pack: PackMode.pack),
        _k('قلم', 'أقلام'),
        _k('قلم رصاص', 'قلم رصاص'),
        _k('هايلايتر', 'هايلايتر', similar: ['ماركر', 'قلم تحديد']),
        _k('حاسبة', 'آلة حاسبة', similar: ['آلة']),
        _k('ملف', 'ملفات'),
        _k('ورق', 'ورق', essential: false),
        _k('ممحاة', 'ممحاة', essential: false),
      ];
    }
    return [
      _k('حقيبة', 'حقيبة', similar: ['شنطة']),
      _k('دفتر', 'دفاتر', pack: PackMode.pack),
      _k('قلم', 'أقلام'),
      _k('ممحاة', 'ممحاة'),
      _k('مبراة', 'براية'),
      _k('مسطرة', 'مسطرة'),
    ];
  }

  // ---------------- هدية / لعبة ----------------

  PlanResult gift(IntentRequest r, CatalogIndex index) {
    final traits = <String>{
      for (final t in [...r.interests, ...r.desiredTraits]) ...ArabicLexicon.stems(t),
    };
    final budget = r.budget == null ? null : r.budget! * _unit;
    final items = <SuggestionItem>[];

    for (final spec in r.searchIntents) {
      final role = spec.role.isNotEmpty ? spec.role : spec.productType;
      final scored = _scorer.score(spec, index);
      final adjusted = <ScoredMatch>[];
      for (final m in scored) {
        if (budget != null && m.entry.priceAmount > budget) continue;
        var level = m.level;
        var note = m.note;
        // نفس الفئة بنوع اسم مختلف (دمية/سيارة ضمن "ألعاب") فكرة مقبولة لكنها غير مؤكدة.
        if (level == MatchLevel.alternative && note?.code == NoteCode.differentType) level = MatchLevel.close;

        final age = r.age;
        if (age != null) {
          final range = parseAgeRange('${m.entry.product.name} ${m.entry.product.description ?? ''}');
          if (range != null) {
            if (age < range.$1 || (range.$2 != null && age > range.$2!)) continue; // خارج العمر بحسب الكتالوج.
            note = MatchNote(NoteCode.ageFits, range.$2 == null ? '${range.$1}+' : '${range.$1}-${range.$2}');
          } else {
            note = const MatchNote(NoteCode.ageUnknown);
          }
        }
        final hits = traits.where(m.entry.hasStem).length;
        adjusted.add(ScoredMatch(
          entry: m.entry,
          score: m.score + hits * 12,
          level: level,
          note: note,
        ));
      }
      adjusted.sort((a, b) {
        final byLevel = a.level.index.compareTo(b.level.index);
        return byLevel != 0 ? byLevel : b.score.compareTo(a.score);
      });
      final ranked = _scorer.rank(adjusted);
      final item = matcher.fromRanked(
        ItemSpec(productType: spec.productType, quantity: 1, originalText: role, role: role),
        ranked,
      );
      items.add(item);
    }

    return (
      items: items,
      plan: PlanSummary(totalAmount: _total(items), budgetAmount: budget, overBudget: budget != null && _total(items) > budget),
    );
  }

  /// يقرأ "5+" أو "من 5 سنوات" أو "3-6 سنوات" من نص الكتالوج. (min, max?)
  static (int, int?)? parseAgeRange(String raw) {
    var t = raw;
    const ar = '٠١٢٣٤٥٦٧٨٩';
    for (var i = 0; i < ar.length; i++) {
      t = t.replaceAll(ar[i], '$i');
    }
    final range = RegExp(r'(\d{1,2})\s*[-–]\s*(\d{1,2})\s*(?:سن|عام|years)').firstMatch(t);
    if (range != null) return (int.parse(range.group(1)!), int.parse(range.group(2)!));
    final plus = RegExp(r'(\d{1,2})\s*\+').firstMatch(t);
    if (plus != null) return (int.parse(plus.group(1)!), null);
    final from = RegExp(r'من\s*(\d{1,2})\s*(?:سن|عام)').firstMatch(t);
    if (from != null) return (int.parse(from.group(1)!), null);
    return null;
  }
}
