import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project/core/design/tokens.dart';

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// رسوم الحالات الفارغة (icons.js · ILL). viewBox 220x170.
const Map<String, String> kIll = {
  'books': '''<ellipse cx="110" cy="152" rx="82" ry="8" class="f-soft"/>
<rect x="46" y="44" width="46" height="106" rx="6" class="f-ink"/><rect x="46" y="44" width="9" height="106" rx="4" class="f-paper" opacity=".28"/><rect x="62" y="62" width="22" height="3" rx="1.5" class="f-paper"/><rect x="62" y="70" width="14" height="3" rx="1.5" class="f-paper"/>
<g transform="rotate(8 124 150)"><rect x="98" y="56" width="42" height="94" rx="6" class="f-coral"/><rect x="98" y="56" width="8" height="94" rx="4" class="f-ink" opacity=".22"/><rect x="112" y="76" width="20" height="3" rx="1.5" class="f-paper"/></g>
<rect x="136" y="84" width="48" height="66" rx="5" class="f-paper"/><rect x="136" y="84" width="48" height="10" rx="3" class="f-amber"/><rect x="146" y="106" width="28" height="3" rx="1.5" class="f-ink" opacity=".5"/><rect x="146" y="114" width="20" height="3" rx="1.5" class="f-ink" opacity=".5"/>
<g transform="rotate(-24 178 40)"><rect x="170" y="14" width="10" height="64" rx="2" class="f-amber"/><path d="M170 78h10l-5 12z" class="f-paper"/><path d="M173 84h4l-2 6z" class="f-ink"/><rect x="170" y="14" width="10" height="9" rx="2" class="f-coral"/></g>''',
  'print': '''<ellipse cx="110" cy="152" rx="78" ry="8" class="f-soft"/>
<rect x="64" y="14" width="76" height="56" rx="4" class="f-white" transform="rotate(-6 100 40)"/><rect x="74" y="26" width="46" height="3" rx="1.5" class="f-ink" opacity=".5" transform="rotate(-6 100 40)"/><rect x="74" y="34" width="56" height="3" rx="1.5" class="f-ink" opacity=".5" transform="rotate(-6 100 40)"/><rect x="74" y="42" width="38" height="3" rx="1.5" class="f-ink" opacity=".5" transform="rotate(-6 100 40)"/>
<rect x="34" y="64" width="152" height="62" rx="16" class="f-ink"/><rect x="52" y="76" width="116" height="10" rx="5" class="f-paper" opacity=".25"/><circle cx="160" cy="104" r="5" class="f-amber"/>
<rect x="62" y="108" width="96" height="40" rx="3" class="f-paper"/><rect x="72" y="118" width="44" height="3" rx="1.5" class="f-ink" opacity=".5"/><rect x="72" y="126" width="62" height="3" rx="1.5" class="f-ink" opacity=".5"/><rect x="72" y="134" width="30" height="3" rx="1.5" class="f-ink" opacity=".5"/>''',
  'bag': '''<ellipse cx="110" cy="152" rx="70" ry="8" class="f-soft"/>
<path d="M62 62h96l-8 86H70z" class="f-paper"/><path d="M62 62h96l-3 30H65z" class="f-amber" opacity=".35"/><path d="M88 62V48a22 22 0 0144 0v14" class="s-ink" stroke-width="6"/>
<rect x="92" y="90" width="36" height="28" rx="3" class="f-ink"/><rect x="92" y="90" width="7" height="28" rx="3" class="f-coral"/><rect x="104" y="100" width="18" height="3" rx="1.5" class="f-paper"/>
<circle cx="168" cy="44" r="5" class="f-amber"/><circle cx="52" cy="84" r="3.5" class="f-coral"/><path d="M178 78l3 6 6 3-6 3-3 6-3-6-6-3 6-3z" class="f-ink" opacity=".8"/>''',
  'assist': '''<ellipse cx="110" cy="152" rx="76" ry="8" class="f-soft"/>
<path d="M44 34h92a14 14 0 0114 14v46a14 14 0 01-14 14H92l-24 20v-20H44a14 14 0 01-14-14V48a14 14 0 0114-14z" class="f-ink"/>
<rect x="48" y="56" width="50" height="4" rx="2" class="f-paper"/><rect x="48" y="68" width="76" height="4" rx="2" class="f-paper" opacity=".7"/><rect x="48" y="80" width="38" height="4" rx="2" class="f-paper" opacity=".5"/>
<path d="M170 60l5 13 13 5-13 5-5 13-5-13-13-5 13-5z" class="f-amber"/><path d="M186 112l2.5 6 6 2.5-6 2.5-2.5 6-2.5-6-6-2.5 6-2.5z" class="f-coral"/>''',
  'wait': '''<ellipse cx="110" cy="152" rx="70" ry="8" class="f-soft"/>
<rect x="58" y="22" width="104" height="126" rx="8" class="f-paper"/><rect x="58" y="22" width="104" height="18" rx="8" class="f-ink"/>
<rect x="74" y="56" width="72" height="4" rx="2" class="f-ink" opacity=".4"/><rect x="74" y="68" width="52" height="4" rx="2" class="f-ink" opacity=".4"/>
<circle cx="134" cy="112" r="30" class="f-white"/><circle cx="134" cy="112" r="30" class="s-ink" stroke-width="5"/><path d="M134 94v18l12 8" class="s-ink" stroke-width="5"/><circle cx="76" cy="112" r="4" class="f-amber"/>''',
  'done': '''<ellipse cx="110" cy="152" rx="70" ry="8" class="f-soft"/>
<rect x="56" y="20" width="108" height="130" rx="8" class="f-paper"/><rect x="72" y="42" width="60" height="4" rx="2" class="f-ink" opacity=".4"/><rect x="72" y="54" width="76" height="4" rx="2" class="f-ink" opacity=".4"/><rect x="72" y="66" width="44" height="4" rx="2" class="f-ink" opacity=".4"/>
<circle cx="134" cy="112" r="32" class="f-ink"/><path d="M118 112l11 11 20-22" class="s-amber" stroke-width="8" stroke-linejoin="round"/>
<path d="M44 40l3 6 6 3-6 3-3 6-3-6-6-3 6-3z" class="f-amber"/><circle cx="182" cy="60" r="5" class="f-coral"/><circle cx="40" cy="104" r="4" class="f-ink" opacity=".7"/>''',
  'offline': '''<ellipse cx="110" cy="152" rx="76" ry="8" class="f-soft"/>
<path d="M62 118a28 28 0 018-54 38 38 0 0172 8 24 24 0 014 46z" class="f-paper"/><path d="M62 118a28 28 0 018-54 38 38 0 0172 8 24 24 0 014 46z" class="s-ink" stroke-width="5"/>
<path d="M88 150l44-62" class="s-ink" stroke-width="7"/><circle cx="168" cy="48" r="5" class="f-amber"/><circle cx="48" cy="52" r="4" class="f-coral"/>''',
  'tools': '''<ellipse cx="110" cy="152" rx="76" ry="8" class="f-soft"/>
<rect x="50" y="64" width="120" height="80" rx="10" class="f-paper"/><rect x="50" y="64" width="120" height="16" rx="8" class="f-ink"/><circle cx="62" cy="72" r="2.5" class="f-amber"/><circle cx="72" cy="72" r="2.5" class="f-paper"/>
<g transform="rotate(35 112 52)"><rect x="104" y="6" width="16" height="70" rx="4" class="f-amber"/><rect x="104" y="6" width="16" height="12" rx="4" class="f-ink"/></g>
<g transform="rotate(-35 150 52)"><rect x="142" y="6" width="14" height="66" rx="3" class="f-coral"/><path d="M142 72h14l-7 14z" class="f-paper"/><path d="M146 80h6l-3 6z" class="f-ink"/></g>
<rect x="68" y="94" width="84" height="5" rx="2.5" class="f-ink" opacity=".35"/><rect x="68" y="108" width="58" height="5" rx="2.5" class="f-ink" opacity=".35"/>''',
  'pin': '''<ellipse cx="110" cy="152" rx="72" ry="8" class="f-soft"/>
<rect x="30" y="64" width="160" height="82" rx="12" class="f-paper"/><path d="M30 100h160M84 64v82M138 64v82" class="s-ink" opacity=".18" stroke-width="4"/>
<path d="M110 18a32 32 0 0132 32c0 26-32 54-32 54S78 76 78 50a32 32 0 0132-32z" class="f-ink"/><circle cx="110" cy="50" r="12" class="f-amber"/>''',
  'route': '''<ellipse cx="110" cy="152" rx="76" ry="8" class="f-soft"/>
<rect x="28" y="36" width="164" height="104" rx="14" class="f-paper"/><path d="M52 112c24-6 30-40 56-40s28 28 60 20" class="s-ink" stroke-width="5" stroke-dasharray="2 10"/>
<rect x="44" y="102" width="20" height="20" rx="5" class="f-amber"/><circle cx="170" cy="92" r="11" class="f-ink"/><circle cx="170" cy="92" r="4" class="f-paper"/>
<rect x="86" y="62" width="30" height="22" rx="4" class="f-coral"/><path d="M86 70h30" class="s-ink" opacity=".4" stroke-width="3"/>''',
  'lock': '''<ellipse cx="110" cy="152" rx="66" ry="8" class="f-soft"/>
<path d="M78 74V56a32 32 0 0164 0v18" class="s-ink" stroke-width="8"/><rect x="62" y="72" width="96" height="74" rx="14" class="f-ink"/><circle cx="110" cy="102" r="9" class="f-amber"/><rect x="106" y="106" width="8" height="20" rx="4" class="f-amber"/>''',
};

/// غلاف المنتج (COVER). viewBox 100x100.
const Map<String, String> kCovers = {
  'notebook':
      '<rect x="26" y="14" width="48" height="72" rx="5" fill="var(--il-ink)"/><rect x="26" y="14" width="7" height="72" rx="3" fill="var(--il-paper)" opacity=".3"/><rect x="40" y="30" width="26" height="3" rx="1.5" fill="var(--il-paper)"/><rect x="40" y="38" width="18" height="3" rx="1.5" fill="var(--il-paper)" opacity=".7"/><rect x="54" y="62" width="16" height="22" fill="var(--il-amber)"/>',
  'pen':
      '<g transform="rotate(35 50 50)"><rect x="44" y="10" width="12" height="62" rx="3" fill="var(--il-ink)"/><rect x="44" y="10" width="12" height="12" rx="3" fill="var(--il-amber)"/><path d="M44 72h12l-6 16z" fill="var(--il-paper)"/><path d="M48 82h4l-2 6z" fill="var(--il-ink)"/></g>',
  'pencils':
      '<g transform="rotate(-18 50 50)"><rect x="24" y="18" width="11" height="58" rx="2" fill="var(--il-amber)"/><rect x="40" y="14" width="11" height="62" rx="2" fill="var(--il-coral)"/><rect x="56" y="20" width="11" height="56" rx="2" fill="var(--il-ink)"/><path d="M24 76h11l-5.5 12zM40 76h11l-5.5 12zM56 76h11l-5.5 12z" fill="var(--il-white)"/></g>',
  'book':
      '<rect x="24" y="12" width="52" height="76" rx="5" fill="var(--il-coral)"/><rect x="24" y="12" width="8" height="76" rx="4" fill="var(--il-ink)" opacity=".25"/><rect x="38" y="28" width="28" height="4" rx="2" fill="var(--il-white)"/><rect x="38" y="37" width="20" height="4" rx="2" fill="var(--il-white)" opacity=".8"/><circle cx="52" cy="66" r="8" fill="var(--il-amber)"/>',
  'notes':
      '<rect x="20" y="24" width="42" height="42" rx="3" fill="var(--il-amber)" transform="rotate(-6 41 45)"/><rect x="38" y="36" width="42" height="42" rx="3" fill="var(--il-white)" transform="rotate(5 59 57)"/><rect x="46" y="50" width="26" height="3" rx="1.5" fill="var(--il-ink)" opacity=".5" transform="rotate(5 59 57)"/><rect x="46" y="58" width="18" height="3" rx="1.5" fill="var(--il-ink)" opacity=".5" transform="rotate(5 59 57)"/>',
  'planner':
      '<rect x="22" y="14" width="56" height="72" rx="6" fill="var(--il-ink)"/><rect x="22" y="14" width="56" height="12" rx="6" fill="var(--il-coral)"/><g fill="var(--il-paper)" opacity=".85"><rect x="32" y="36" width="8" height="8" rx="2"/><rect x="46" y="36" width="8" height="8" rx="2"/><rect x="60" y="36" width="8" height="8" rx="2"/><rect x="32" y="50" width="8" height="8" rx="2"/><rect x="46" y="50" width="8" height="8" rx="2"/><rect x="60" y="50" width="8" height="8" rx="2" fill="var(--il-amber)"/><rect x="32" y="64" width="8" height="8" rx="2"/><rect x="46" y="64" width="8" height="8" rx="2"/></g>',
  'colors':
      '<rect x="18" y="30" width="64" height="40" rx="6" fill="var(--il-ink)"/><g><rect x="26" y="38" width="8" height="24" rx="2" fill="var(--il-amber)"/><rect x="37" y="38" width="8" height="24" rx="2" fill="var(--il-coral)"/><rect x="48" y="38" width="8" height="24" rx="2" fill="var(--il-paper)"/><rect x="59" y="38" width="8" height="24" rx="2" fill="var(--il-white)"/><rect x="70" y="38" width="6" height="24" rx="2" fill="var(--il-amber)" opacity=".6"/></g>',
  'scissors':
      '<g transform="rotate(-30 50 50)"><circle cx="38" cy="72" r="10" fill="none" stroke="var(--il-ink)" stroke-width="5"/><circle cx="62" cy="72" r="10" fill="none" stroke="var(--il-coral)" stroke-width="5"/><path d="M42 63l16-46M58 63L42 17" stroke="var(--il-ink)" stroke-width="5" stroke-linecap="round"/></g>',
};

String _themeVars(String s, SatrColors c) => s
    .replaceAll('var(--il-ink)', _hex(c.ilInk))
    .replaceAll('var(--il-paper)', _hex(c.ilPaper))
    .replaceAll('var(--il-amber)', _hex(c.ilAmber))
    .replaceAll('var(--il-coral)', _hex(c.ilCoral))
    .replaceAll('var(--il-soft)', _hex(c.ilSoft))
    .replaceAll('var(--il-white)', _hex(c.ilWhite));

/// رسم توضيحي للحالات الفارغة والترحيب.
class Ill extends StatelessWidget {
  const Ill(this.name, {super.key, this.width = 190});
  final String name;
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    var body = kIll[name] ?? '';
    body = body
        .replaceAll('class="f-ink"', 'fill="${_hex(c.ilInk)}"')
        .replaceAll('class="f-paper"', 'fill="${_hex(c.ilPaper)}"')
        .replaceAll('class="f-amber"', 'fill="${_hex(c.ilAmber)}"')
        .replaceAll('class="f-coral"', 'fill="${_hex(c.ilCoral)}"')
        .replaceAll('class="f-soft"', 'fill="${_hex(c.ilSoft)}"')
        .replaceAll('class="f-white"', 'fill="${_hex(c.ilWhite)}"')
        .replaceAll('class="s-ink"',
            'fill="none" stroke="${_hex(c.ilInk)}" stroke-linecap="round" stroke-linejoin="round"')
        .replaceAll('class="s-amber"',
            'fill="none" stroke="${_hex(c.ilAmber)}" stroke-linecap="round"');
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 220 170">$body</svg>';
    return SvgPicture.string(svg,
        width: width, height: (width * 170 / 220).roundToDouble());
  }
}

/// غلاف منتج مرسوم (مصدره التصميم) عندما لا تتوفر image_url من الخادم.
class ProductCover extends StatelessWidget {
  const ProductCover({super.key, required this.kind, this.tone = 'paper', this.fit = false});
  final String kind;
  final String tone;
  final bool fit;

  static String kindFor(String name) {
    final n = name;
    if (n.contains('دفتر')) return 'notebook';
    if (n.contains('رصاص')) return 'pencils';
    if (n.contains('قلم') || n.contains('أقلام') || n.contains('حبر')) return 'pen';
    if (n.contains('مفكرة') || n.contains('تقويم')) return 'planner';
    if (n.contains('لاصق') || n.contains('ملاحظات')) return 'notes';
    if (n.contains('ألوان') || n.contains('الوان')) return 'colors';
    if (n.contains('مقص')) return 'scissors';
    return 'book';
  }

  static String toneFor(int seed) =>
      const ['paper', 'amber', 'coral', 'plum'][seed.abs() % 4];

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ground = switch (tone) {
      'amber' => c.amberSoft,
      'coral' => c.coralSoft,
      'plum' => c.plumSoft,
      _ => c.hero,
    };
    final body = _themeVars(kCovers[kind] ?? kCovers['notebook']!, c);
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" fill="${_hex(ground)}"/>$body</svg>';
    return SvgPicture.string(svg,
        fit: fit ? BoxFit.contain : BoxFit.cover,
        width: double.infinity,
        height: double.infinity);
  }
}

/// شعار سطر: الصورة الأصلية من الأصول (LOGO في التصميم).
class SatrLogo extends StatelessWidget {
  const SatrLogo({super.key, this.width = 230});
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final img = Image.asset('assets/images/Satr_logo.png',
        width: width,
        fit: BoxFit.contain,
        colorBlendMode: c.dark ? BlendMode.srcATop : BlendMode.multiply);
    return img;
  }
}
