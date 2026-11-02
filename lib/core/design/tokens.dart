import 'package:flutter/material.dart';

/// رموز التصميم المعتمدة (app.css · .app و .app[data-mode=dark]).
@immutable
class SatrColors extends ThemeExtension<SatrColors> {
  const SatrColors({
    required this.bg,
    required this.sf,
    required this.sf2,
    required this.sf3,
    required this.ln,
    required this.pri,
    required this.priHi,
    required this.onPri,
    required this.tx,
    required this.tx2,
    required this.tx3,
    required this.plumSoft,
    required this.plumInk,
    required this.hero,
    required this.onHero,
    required this.hero2,
    required this.amber,
    required this.amberSoft,
    required this.amberInk,
    required this.coral,
    required this.coralTag,
    required this.coralSoft,
    required this.coralInk,
    required this.ok,
    required this.okSoft,
    required this.okInk,
    required this.err,
    required this.errSoft,
    required this.errInk,
    required this.ilInk,
    required this.ilPaper,
    required this.ilAmber,
    required this.ilCoral,
    required this.ilSoft,
    required this.ilWhite,
    required this.shadow,
    required this.dark,
  });

  final Color bg, sf, sf2, sf3, ln;
  final Color pri, priHi, onPri;
  final Color tx, tx2, tx3;
  final Color plumSoft, plumInk;
  final Color hero, onHero, hero2;
  final Color amber, amberSoft, amberInk;
  final Color coral, coralTag, coralSoft, coralInk;
  final Color ok, okSoft, okInk;
  final Color err, errSoft, errInk;
  final Color ilInk, ilPaper, ilAmber, ilCoral, ilSoft, ilWhite;
  final Color shadow;
  final bool dark;

  static const light = SatrColors(
    bg: Color(0xFFFBF6EA),
    sf: Color(0xFFFFFEFB),
    sf2: Color(0xFFF4EAD3),
    sf3: Color(0xFFEADBBA),
    ln: Color(0x1C30142A),
    pri: Color(0xFF30142A),
    priHi: Color(0xFF4A2442),
    onPri: Color(0xFFF7EBD0),
    tx: Color(0xFF2A1226),
    tx2: Color(0xFF6A5464),
    tx3: Color(0xFF8C7886),
    plumSoft: Color(0xFFEDE1EA),
    plumInk: Color(0xFF4A2442),
    hero: Color(0xFFEFDFBF),
    onHero: Color(0xFF30142A),
    hero2: Color(0xFFE6D2A6),
    amber: Color(0xFFD39A2C),
    amberSoft: Color(0xFFF7E6BC),
    amberInk: Color(0xFF7A5210),
    coral: Color(0xFFC95F4B),
    coralTag: Color(0xFFB4513E),
    coralSoft: Color(0xFFF7DDD4),
    coralInk: Color(0xFF8F3A2B),
    ok: Color(0xFF2E7D57),
    okSoft: Color(0xFFDCEBDD),
    okInk: Color(0xFF1D5A3C),
    err: Color(0xFFB3261E),
    errSoft: Color(0xFFF8DAD5),
    errInk: Color(0xFF8A1D17),
    ilInk: Color(0xFF30142A),
    ilPaper: Color(0xFFEFDFBF),
    ilAmber: Color(0xFFD39A2C),
    ilCoral: Color(0xFFC95F4B),
    ilSoft: Color(0xFFE4D2AA),
    ilWhite: Color(0xFFFFFEFB),
    shadow: Color(0xFF30142A),
    dark: false,
  );

  static const darkMode = SatrColors(
    bg: Color(0xFF190A16),
    sf: Color(0xFF261221),
    sf2: Color(0xFF321A2C),
    sf3: Color(0xFF432640),
    ln: Color(0x21EFDFBF),
    pri: Color(0xFFEFDFBF),
    priHi: Color(0xFFF7EBD0),
    onPri: Color(0xFF30142A),
    tx: Color(0xFFF6EBD3),
    tx2: Color(0xFFC9B3BF),
    tx3: Color(0xFF9D8695),
    plumSoft: Color(0xFF43263C),
    plumInk: Color(0xFFEFDFBF),
    hero: Color(0xFF3A1D34),
    onHero: Color(0xFFF3E4C4),
    hero2: Color(0xFF4B2843),
    amber: Color(0xFFE2B04E),
    amberSoft: Color(0xFF4A3716),
    amberInk: Color(0xFFF0CE86),
    coral: Color(0xFFE0806D),
    coralTag: Color(0xFFB4513E),
    coralSoft: Color(0xFF4F2A24),
    coralInk: Color(0xFFF2B3A6),
    ok: Color(0xFF5BBE8A),
    okSoft: Color(0xFF1F3A2C),
    okInk: Color(0xFF9BDCB8),
    err: Color(0xFFF0766C),
    errSoft: Color(0xFF4D221F),
    errInk: Color(0xFFF6B2AB),
    ilInk: Color(0xFFEFDFBF),
    ilPaper: Color(0xFF5B3552),
    ilAmber: Color(0xFFE2B04E),
    ilCoral: Color(0xFFE0806D),
    ilSoft: Color(0xFF3A1F34),
    ilWhite: Color(0xFF2C1727),
    shadow: Color(0xFF000000),
    dark: true,
  );

  /// ظل البطاقات: 0 1px 2px / 0 8px 22px -6px.
  List<BoxShadow> get cardShadow => [
        BoxShadow(
            color: shadow.withValues(alpha: dark ? .3 : .06),
            blurRadius: 2,
            offset: const Offset(0, 1)),
        BoxShadow(
            color: shadow.withValues(alpha: dark ? .4 : .10),
            blurRadius: 22,
            spreadRadius: -6,
            offset: const Offset(0, 8)),
      ];

  List<BoxShadow> get upShadow => [
        BoxShadow(
            color: shadow.withValues(alpha: dark ? .5 : .18),
            blurRadius: 30,
            spreadRadius: -8,
            offset: const Offset(0, -10)),
      ];

  @override
  SatrColors copyWith() => this;

  @override
  SatrColors lerp(ThemeExtension<SatrColors>? other, double t) =>
      t < .5 ? this : (other as SatrColors? ?? this);
}

extension SatrContext on BuildContext {
  SatrColors get sc =>
      Theme.of(this).extension<SatrColors>() ?? SatrColors.light;
}

/// أنصاف الأقطار (--r-s .. --r-xl).
abstract final class Rad {
  static const s = 10.0, m = 14.0, l = 20.0, xl = 28.0;
}

abstract final class Fonts {
  static const ui = 'IBMPlexSansArabic';
  static const dis = 'ArefRuqaa';
}

/// سلّم الخطوط (app.css · type).
abstract final class T {
  static TextStyle d1(Color c) => TextStyle(
      fontFamily: Fonts.dis,
      fontWeight: FontWeight.w700,
      fontSize: 36,
      height: 1.3,
      color: c);
  static TextStyle d2(Color c, {double size = 28, double height = 1.35}) =>
      TextStyle(
          fontFamily: Fonts.dis,
          fontWeight: FontWeight.w700,
          fontSize: size,
          height: height,
          color: c);
  static TextStyle h1(Color c) => TextStyle(
      fontFamily: Fonts.ui,
      fontWeight: FontWeight.w700,
      fontSize: 24,
      height: 1.4,
      color: c);
  static TextStyle h2(Color c, {double size = 20}) => TextStyle(
      fontFamily: Fonts.ui,
      fontWeight: FontWeight.w700,
      fontSize: size,
      height: 1.45,
      color: c);
  static TextStyle h3(Color c, {double size = 17}) => TextStyle(
      fontFamily: Fonts.ui,
      fontWeight: FontWeight.w600,
      fontSize: size,
      height: 1.5,
      color: c);
  static TextStyle bd(Color c) => TextStyle(
      fontFamily: Fonts.ui, fontSize: 16, height: 1.7, color: c);
  static TextStyle sm(Color c, {FontWeight? w}) => TextStyle(
      fontFamily: Fonts.ui,
      fontSize: 14,
      height: 1.65,
      fontWeight: w,
      color: c);
  static TextStyle cap(Color c) => TextStyle(
      fontFamily: Fonts.ui,
      fontSize: 12.5,
      height: 1.5,
      fontWeight: FontWeight.w500,
      color: c);
  static TextStyle eyebrow(Color c) => TextStyle(
      fontFamily: Fonts.ui,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      letterSpacing: .5,
      color: c);
}
