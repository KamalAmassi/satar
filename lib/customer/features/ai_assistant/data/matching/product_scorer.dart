import 'package:project/customer/features/ai_assistant/data/catalog/catalog_index.dart';
import 'package:project/customer/features/ai_assistant/data/matching/arabic_lexicon.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/intent.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';

class ScoredMatch {
  const ScoredMatch({required this.entry, required this.score, required this.level, this.note});
  final CatalogEntry entry;
  final double score;
  final MatchLevel level;
  final MatchNote? note;

  ScoredMatch withLevel(MatchLevel l, [MatchNote? n]) =>
      ScoredMatch(entry: entry, score: score, level: l, note: n ?? note);
}

/// نتيجة التصنيف لطلب واحد، بالسقوف المطلوبة.
class RankedMatches {
  const RankedMatches({required this.exact, required this.close, required this.alternatives});
  final List<ScoredMatch> exact;
  final List<ScoredMatch> close;

  /// تُعرض فقط إن لم يوجد exact ولا close.
  final List<ScoredMatch> alternatives;

  bool get isEmpty => exact.isEmpty && close.isEmpty && alternatives.isEmpty;
}

/// مسجِّل حتمي: لا نموذج هنا. نوع المنتج في الاسم هو الأقوى؛ أي تعارض يخفّض المستوى فقط.
class ProductScorer {
  const ProductScorer();

  static const maxResults = 5;

  static final _rulingStems = {
    for (final w in const ['مسطر', 'مربعات', 'سلك', 'سادة'])
      ArabicLexicon.stemOf(w),
  };

  List<ScoredMatch> score(ItemSpec spec, CatalogIndex index) {
    final headStems = ArabicLexicon.stems(spec.productType);
    if (headStems.isEmpty) return const [];

    // ما قاله المستخدم صراحةً (لا نعاقب عليه).
    final said = <String>{
      ...ArabicLexicon.stems(spec.originalText),
      for (final v in spec.attributes.values) ...ArabicLexicon.stems(v),
      for (final t in spec.mustHave) ...ArabicLexicon.stems(t),
    };

    // المرفوضات: صريحة من النموذج + ضمنية من القاموس، دون ما ذكره المستخدم.
    final unwanted = <String, String>{}; // جذع ← نص للعرض
    for (final t in spec.mustNot) {
      final st = ArabicLexicon.stems(t);
      if (st.length == 1 && !said.contains(st.first)) unwanted[st.first] = t;
    }
    for (final h in headStems) {
      for (final s in ArabicLexicon.confusables[h] ?? const <String>{}) {
        if (!said.contains(s)) unwanted.putIfAbsent(s, () => s);
      }
    }
    final displayOf = _displayTerms();

    final out = <ScoredMatch>[];
    for (final c in index.candidates(spec.productType)) {
      final e = c.entry;
      var score = c.head == HeadMatch.name ? 50.0 : 20.0;
      var level = MatchLevel.exact;
      MatchNote? note;
      var notePriority = 0;

      void demote(MatchLevel to, int priority, MatchNote n) {
        if (to.index > level.index) level = to;
        if (priority > notePriority) {
          notePriority = priority;
          note = n;
        }
      }

      if (c.head == HeadMatch.category) {
        demote(MatchLevel.alternative, 1, MatchNote(NoteCode.differentType, e.categoryName));
      }

      // مفرد/عبوة.
      if (spec.pack == PackMode.pack) {
        if (e.isPack) {
          score += 15;
        } else {
          score -= 25;
          demote(MatchLevel.close, 4, const MatchNote(NoteCode.singleNotPack));
        }
      } else if (e.isPack) {
        score -= 10;
        demote(MatchLevel.close, 4, const MatchNote(NoteCode.packNotSingle));
      }

      // مرفوضات.
      for (final entry in unwanted.entries) {
        if (e.nameSet.contains(entry.key)) {
          score -= 60;
          demote(c.head == HeadMatch.name ? MatchLevel.close : MatchLevel.reject, 6,
              MatchNote(NoteCode.unwantedTerm, displayOf[entry.key] ?? entry.value));
          break;
        }
      }

      // الصفات.
      for (final a in spec.attributes.entries) {
        final vs = ArabicLexicon.stems(a.value);
        if (vs.isEmpty) continue;
        if (vs.every(e.hasStem)) {
          score += 10;
        } else if (_conflicts(a.key, vs, e)) {
          score -= 20;
          demote(MatchLevel.close, 5, MatchNote(NoteCode.attrDiffers, a.value));
        } else {
          score -= 5;
          demote(MatchLevel.close, 3, MatchNote(NoteCode.attrUnknown, a.value));
        }
      }
      for (final t in spec.mustHave) {
        final vs = ArabicLexicon.stems(t);
        if (vs.isEmpty) continue;
        if (vs.every(e.hasStem)) {
          score += 10;
        } else {
          score -= 5;
          demote(MatchLevel.close, 3, MatchNote(NoteCode.attrUnknown, t));
        }
      }

      if (!e.available) score -= 5;
      score -= e.nameStems.length * 0.1; // الاسم الأخصر أدق قليلًا.

      if (level == MatchLevel.reject) continue;
      out.add(ScoredMatch(entry: e, score: score, level: level, note: note));
    }
    out.sort((a, b) {
      final byLevel = a.level.index.compareTo(b.level.index);
      if (byLevel != 0) return byLevel;
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.entry.priceAmount.compareTo(b.entry.priceAmount);
    });
    return out;
  }

  /// فرز وسقوف: exact أولاً، close تكمل حتى 5، والبدائل فقط إن لم يوجد شيء.
  RankedMatches rank(List<ScoredMatch> scored) {
    final exact = [for (final m in scored) if (m.level == MatchLevel.exact) m].take(maxResults).toList();
    final close = [for (final m in scored) if (m.level == MatchLevel.close) m]
        .take(maxResults - exact.length)
        .toList();
    final alts = exact.isEmpty && close.isEmpty
        ? [for (final m in scored) if (m.level == MatchLevel.alternative) m].take(3).toList()
        : <ScoredMatch>[];
    return RankedMatches(exact: exact, close: close, alternatives: alts);
  }

  RankedMatches resolve(ItemSpec spec, CatalogIndex index) => rank(score(spec, index));

  bool _conflicts(String key, List<String> wanted, CatalogEntry e) {
    if (key == 'color') {
      final group = ArabicLexicon.colorGroupOf(wanted.first);
      return e.nameStems.any((s) {
        final g = ArabicLexicon.colorGroupOf(s);
        return g != null && g != group;
      });
    }
    if (key == 'ruling') {
      return e.nameStems.any((s) => _rulingStems.contains(s) && !wanted.contains(s));
    }
    return false;
  }

  static Map<String, String> _displayTerms() => {
        ArabicLexicon.stemOf('سلك'): 'سلك',
        ArabicLexicon.stemOf('سلكي'): 'سلك',
        ArabicLexicon.stemOf('حلزوني'): 'حلزوني',
        ArabicLexicon.stemOf('نوتة'): 'نوتة',
        ArabicLexicon.stemOf('ملاحظات'): 'ملاحظات',
        ArabicLexicon.stemOf('مفكرة'): 'مفكرة',
      };
}
