import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/data/models.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/network/idempotency.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/core/widgets/common_widgets.dart';
import 'package:project/driver/features/orders/presentation/driver_page.dart';

/// تعذّر التسليم: POST /driver/orders/{id}/transition (to: delivery_failed). منقولة من
/// d1d6084:lib/features/driver/driver.dart (DriverFailedScreen).
class DriverFailedScreen extends StatefulWidget {
  const DriverFailedScreen({super.key});
  @override
  State<DriverFailedScreen> createState() => _DriverFailedScreenState();
}

class _DriverFailedScreenState extends State<DriverFailedScreen> {
  String reason = 'customer_unreachable';
  final note = TextEditingController();
  List<int>? photo;
  bool busy = false;
  String? err;
  final key = IdempotencyKey.generate();

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  List<(String, String)> _reasons(AppLocalizations l) => [
        ('customer_unreachable', l.driverFailReasonUnreachable),
        ('incorrect_address', l.driverFailReasonAddress),
        ('reschedule_requested', l.driverFailReasonReschedule),
        ('access_unavailable', l.driverFailReasonAccess),
        ('other', l.driverFailReasonOther),
      ];

  Future<void> _send() async {
    final o = Get.isRegistered<TaskController>() ? Get.find<TaskController>().order.value : null;
    if (o == null) return;
    setState(() {
      busy = true;
      err = null;
    });
    final r = await backend.driverTransition(o.id, 'delivery_failed', key: key, fields: {'delivery_failure_reason': reason}, note: note.text, uploadIds: photo);
    if (!mounted) return;
    setState(() => busy = false);
    await r.fold((f) async {
      Haptics.error();
      setState(() => err = failureText(f));
    }, (_) async {
      Haptics.confirm();
      await driverCtl().refreshAll();
      Get.offNamed('/driver/failure-recorded');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    return Page2(
      top: TopBar(title: l.driverFailedTitle),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.driverFailedQuestion, style: T.h1(c.tx)),
        const SizedBox(height: 16),
        for (final r in _reasons(l)) ...[OptCard(on: reason == r.$1, title: r.$2, onTap: () => setState(() => reason = r.$1)), const SizedBox(height: 8)],
        const SizedBox(height: 8),
        Fld(label: l.driverNoteLabel, hint: l.driverNoteHint, controller: note, optional: true, maxLines: 3),
        const SizedBox(height: 16),
        DropZone(
          compact: true,
          icon: photo == null ? 'camera' : 'checkC',
          title: photo == null ? l.driverAddPhotoOptional : l.driverPhotoAttached,
          onTap: () async {
            final p = await pickAndUpload('delivery_proof');
            if (p != null) setState(() => photo = p);
          },
        ),
        if (err != null) ...[const SizedBox(height: 16), Note('err', text: err)],
      ]),
      foot: FootBar(child: SBtn(l.driverRecordFailure, kind: BtnKind.danger, full: true, loading: busy, hapticOnPress: false, onTap: _send)),
    );
  }
}
