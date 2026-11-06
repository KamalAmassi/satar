import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/match_info.dart';

/// نص السبب بالعربية/الإنجليزية من رمز الملاحظة (لا نصوص ثابتة في المحرك).
String matchNoteText(AppLocalizations l, MatchNote n) => switch (n.code) {
      NoteCode.singleNotPack => l.aiNoteSingleNotPack,
      NoteCode.packNotSingle => l.aiNotePackNotSingle,
      NoteCode.unwantedTerm => l.aiNoteUnwanted(n.arg),
      NoteCode.attrDiffers => l.aiNoteAttrDiffers(n.arg),
      NoteCode.attrUnknown => l.aiNoteAttrUnknown(n.arg),
      NoteCode.differentType => n.arg.isEmpty ? l.aiNoteDifferentType : l.aiNoteDifferentTypeIn(n.arg),
      NoteCode.ageFits => l.aiNoteAgeFits(n.arg),
      NoteCode.ageUnknown => l.aiNoteAgeUnknown,
      NoteCode.ageOutside => l.aiNoteAgeOutside(n.arg),
      NoteCode.judged => n.arg,
    };
