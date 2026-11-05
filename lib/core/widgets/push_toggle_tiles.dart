import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/services/push/push_service.dart';

/// مفتاح «تفعيل الإشعارات» المشترك (حسابي / إعدادات السائق) + «فتح إعدادات النظام» عند الرفض.
class PushToggleTiles extends StatelessWidget {
  const PushToggleTiles({super.key, this.first = true});
  final bool first;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final push = PushService.maybe;
    if (push == null || !push.supported) {
      return LiTile('bell', l.pushToggleTitle, sub: l.pushUnsupported, first: first, end: const SSwitch(false));
    }

    Future<void> toggle(bool value) async {
      final r = await push.setEnabled(value);
      if (r == PushToggleResult.failed) {
        showToast(l.pushToggleError, icon: 'alertC', actionLabel: l.pushRetry, onAction: () => toggle(value));
      }
    }

    return Obx(() {
      final c = context.sc;
      final on = push.isEnabled.value;
      final busy = push.busy.value;
      final denied = push.permissionDenied.value;
      return Column(children: [
        MergeSemantics(
          child: LiTile(
            'bell',
            l.pushToggleTitle,
            sub: denied ? l.pushDenied : l.pushToggleSub,
            first: first,
            onTap: busy ? null : () => toggle(!on),
            end: busy
                ? SizedBox(width: 50, height: 48, child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: c.pri))))
                : SSwitch(on, onChanged: toggle),
          ),
        ),
        if (denied) LiTile('sliders', l.pushOpenSystem, first: false, onTap: ph.openAppSettings),
      ]);
    });
  }
}
