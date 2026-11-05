import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/utils/haptics.dart';

/// صف إعداد «الاهتزاز» (حسابي / ملف السائق). يُعاد بناؤه وحده عبر Obx.
class VibrationTile extends StatelessWidget {
  const VibrationTile({super.key, this.first = false});
  final bool first;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Obx(() {
      final on = Haptics.enabled.value;
      void toggle() => Haptics.setEnabled(!on);
      return MergeSemantics(
        child: LiTile(
          'sparkles',
          l.vibrationSettingTitle,
          sub: l.vibrationSettingSub,
          first: first,
          onTap: toggle,
          end: SSwitch(on, onChanged: (_) => toggle()),
        ),
      );
    });
  }
}
