import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// مجموعة الأيقونات المعتمدة (icons.js · IC): خط 24px بسماكة 1.75.
const Map<String, String> kIcons = {
  'home': '<path d="M3 11l9-8 9 8"/><path d="M5 10v10h5v-6h4v6h5V10"/>',
  'printer':
      '<path d="M7 9V3h10v6"/><rect x="3" y="9" width="18" height="8" rx="2"/><path d="M7 14h10v7H7z"/>',
  'sparkles':
      '<path d="M11 3l1.9 5.1L18 10l-5.1 1.9L11 17l-1.9-5.1L4 10l5.1-1.9z"/><path d="M19 15l.8 2.2L22 18l-2.2.8L19 21l-.8-2.2L16 18l2.2-.8z"/>',
  'orders':
      '<rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4h6v3H9z"/><path d="M9 12h6M9 16h4"/>',
  'user': '<circle cx="12" cy="8" r="4"/><path d="M4 21c1-4 4-6 8-6s7 2 8 6"/>',
  'bag': '<path d="M5 8h14l-1 12H6z"/><path d="M9 8V6a3 3 0 016 0v2"/>',
  'search': '<circle cx="11" cy="11" r="7"/><path d="M20 20l-4-4"/>',
  'sliders':
      '<path d="M4 7h10M18 7h2M4 17h2M10 17h10"/><circle cx="16" cy="7" r="2"/><circle cx="8" cy="17" r="2"/>',
  'back': '<path d="M5 12h14M13 6l6 6-6 6"/>',
  'fwd': '<path d="M19 12H5M11 6l-6 6 6 6"/>',
  'chevL': '<path d="M15 6l-6 6 6 6"/>',
  'chevR': '<path d="M9 6l6 6-6 6"/>',
  'chevD': '<path d="M6 9l6 6 6-6"/>',
  'x': '<path d="M6 6l12 12M18 6L6 18"/>',
  'plus': '<path d="M12 5v14M5 12h14"/>',
  'minus': '<path d="M5 12h14"/>',
  'check': '<path d="M5 12.5l4.5 4.5L19 7"/>',
  'checkC': '<circle cx="12" cy="12" r="9"/><path d="M8 12.5l2.7 2.7L16 9.5"/>',
  'alert': '<path d="M12 3.5l9.5 16.5h-19z"/><path d="M12 10v4M12 17.2v.1"/>',
  'alertC': '<circle cx="12" cy="12" r="9"/><path d="M12 7.5v5.5M12 16.3v.1"/>',
  'info': '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 7.8v.1"/>',
  'clock': '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  'pin':
      '<path d="M12 21s7-6 7-11a7 7 0 10-14 0c0 5 7 11 7 11z"/><circle cx="12" cy="10" r="2.5"/>',
  'phone':
      '<path d="M5 4h4l2 5-2.5 1.5a11 11 0 005 5L15 13l5 2v4a2 2 0 01-2 2A16 16 0 013 6a2 2 0 012-2z"/>',
  'upload':
      '<path d="M12 16V4M7 9l5-5 5 5"/><path d="M4 16v3a1 1 0 001 1h14a1 1 0 001-1v-3"/>',
  'file':
      '<path d="M7 3h7l5 5v12a1 1 0 01-1 1H7a1 1 0 01-1-1V4a1 1 0 011-1z"/><path d="M14 3v5h5"/>',
  'image':
      '<rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="9" cy="10" r="1.6"/><path d="M4 18l5-5 4 4 3-3 4 4"/>',
  'trash':
      '<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"/>',
  'edit': '<path d="M4 20h4L19 9l-4-4L4 16z"/><path d="M13.5 6.5l4 4"/>',
  'mic': '<rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0014 0M12 18v3"/>',
  'send': '<path d="M21 3L10 14M21 3l-7 18-4-7-7-4z"/>',
  'copy':
      '<rect x="8" y="8" width="12" height="12" rx="2"/><path d="M16 8V5a1 1 0 00-1-1H5a1 1 0 00-1 1v10a1 1 0 001 1h3"/>',
  'share':
      '<circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="6" r="2.5"/><circle cx="18" cy="18" r="2.5"/><path d="M8.2 10.8l7.6-3.6M8.2 13.2l7.6 3.6"/>',
  'star':
      '<path d="M12 3.5l2.6 5.5 6 .8-4.4 4.2 1.1 6-5.3-2.9-5.3 2.9 1.1-6L3.4 9.8l6-.8z"/>',
  'bell': '<path d="M6 17V11a6 6 0 0112 0v6l2 2H4z"/><path d="M10 21h4"/>',
  'truck':
      '<path d="M3 6h11v10H3zM14 9h4l3 3v4h-7"/><circle cx="7" cy="17.5" r="1.8"/><circle cx="17" cy="17.5" r="1.8"/>',
  'box': '<path d="M3 8l9-5 9 5v9l-9 5-9-5z"/><path d="M3 8l9 5 9-5M12 13v9"/>',
  'bank': '<path d="M3 9l9-5 9 5M5 10v8M9.5 10v8M14.5 10v8M19 10v8M3 21h18"/>',
  'wallet':
      '<path d="M4 7a2 2 0 012-2h11v4"/><rect x="4" y="7" width="17" height="13" rx="2"/><circle cx="16.5" cy="13.5" r="1.2"/>',
  'cash':
      '<rect x="2.5" y="6" width="19" height="12" rx="2"/><circle cx="12" cy="12" r="2.8"/><path d="M6 9.5v.1M18 14.5v.1"/>',
  'lock': '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 018 0v3"/>',
  'globe':
      '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/>',
  'logout':
      '<path d="M10 4H6a1 1 0 00-1 1v14a1 1 0 001 1h4M15 8l4 4-4 4M19 12H9"/>',
  'wifiOff':
      '<path d="M3 3l18 18M8.5 16.5a5 5 0 017 0M5 12.9a10 10 0 013.6-2.2M10.7 5.1A15 15 0 0122 9M2 9a15 15 0 013-2.2M12 20v.1"/>',
  'refresh':
      '<path d="M20 11a8 8 0 00-14-4L4 9M4 4v5h5M4 13a8 8 0 0014 4l2-2M20 20v-5h-5"/>',
  'camera':
      '<path d="M4 8h3l2-3h6l2 3h3a1 1 0 011 1v10a1 1 0 01-1 1H4a1 1 0 01-1-1V9a1 1 0 011-1z"/><circle cx="12" cy="13.5" r="3.5"/>',
  'nav': '<path d="M3 11l18-8-8 18-2-8z"/>',
  'cal':
      '<rect x="3.5" y="5" width="17" height="15" rx="2"/><path d="M3.5 10h17M8 3v4M16 3v4"/>',
  'tag': '<path d="M3 12V4a1 1 0 011-1h8l9 9-9 9z"/><circle cx="8" cy="8" r="1.4"/>',
  'book': '<path d="M4 5a2 2 0 012-2h13v16H6a2 2 0 00-2 2z"/><path d="M4 19V5M8 7h7"/>',
  'layers':
      '<path d="M12 3l9 5-9 5-9-5z"/><path d="M3 13l9 5 9-5M3 17.5l9 5 9-5" opacity=".6"/>',
  'eye':
      '<path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>',
  'shield': '<path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/><path d="M8.5 12l2.5 2.5L15.5 10"/>',
  'headset':
      '<path d="M4 14v-2a8 8 0 0116 0v2"/><rect x="3" y="14" width="4" height="6" rx="1.5"/><rect x="17" y="14" width="4" height="6" rx="1.5"/><path d="M19 20c0 1-2 2-5 2"/>',
  'grid':
      '<rect x="4" y="4" width="7" height="7" rx="1.5"/><rect x="13" y="4" width="7" height="7" rx="1.5"/><rect x="4" y="13" width="7" height="7" rx="1.5"/><rect x="13" y="13" width="7" height="7" rx="1.5"/>',
  'power': '<path d="M12 3v9M6.5 6.5a8 8 0 1011 0"/>',
  'wrench': '<path d="M14.5 6.5a4 4 0 005 5L9 22l-3-3z"/><path d="M14.5 6.5a4 4 0 00-1 4"/>',
  'download':
      '<path d="M12 4v12M7 11l5 5 5-5"/><path d="M4 16v3a1 1 0 001 1h14a1 1 0 001-1v-3"/>',
  'qr':
      '<rect x="4" y="4" width="6" height="6" rx="1"/><rect x="14" y="4" width="6" height="6" rx="1"/><rect x="4" y="14" width="6" height="6" rx="1"/><path d="M14 14h3v3M20 14v.1M14 20h3M20 17v3"/>',
  'user2': '<circle cx="12" cy="8" r="4"/><path d="M4 21c1-4 4-6 8-6s7 2 8 6"/>',
  'menu': '<path d="M4 7h16M4 12h16M4 17h16"/>',
  'more': '<path d="M5 12h.1M12 12h.1M19 12h.1" stroke-width="3"/>',
  'filter': '<path d="M4 5h16l-6 8v6l-4-2v-4z"/>',
  'handoff': '<path d="M7 12l-4 4 4 4M3 16h11M17 12l4-4-4-4M21 8H10"/>',
  'zap': '<path d="M13 3L5 14h6l-1 7 8-11h-6z"/>',
};

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

final Map<String, String> _cache = {};

/// أيقونة التصميم. [filled] لنجمة التقييم (icf).
class SIcon extends StatelessWidget {
  const SIcon(this.name, {super.key, this.size = 22, this.color, this.filled = false});

  final String name;
  final double size;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    final hex = _hex(c);
    final key = '$name|$hex|$filled';
    final svg = _cache.putIfAbsent(key, () {
      final body = kIcons[name] ?? '';
      return filled
          ? '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="$hex" stroke="$hex" stroke-width="1.2" stroke-linejoin="round">$body</svg>'
          : '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="$hex" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">$body</svg>';
    });
    return SvgPicture.string(svg, width: size, height: size);
  }
}
