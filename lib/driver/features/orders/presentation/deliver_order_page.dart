import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;
import 'package:get/get.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/shell.dart';
import 'package0/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/failure.dart';
import 'package0/core/extensions/context_extensions.dart';
import 'package:project/core/network/idempotency.dart';
import 'package0/core/utils/haptics.dart';
import 'package:project/core/data/models.dart';
import 'package0/driver/features/orders/presentation/driver_page.dart';
import 'package:project/driver/features/orders/presentation/deliver_order.dart';
import 'package:project/core/widgets/common_widgets.dart';

class DriverDeliverScreen extends StatefulWidget {
  const DriverDeliverScreen({super.key});
  @override
  State<DriverDeliverScreen> createState() => _DriverDeliverScreenState();
}

class _DriverDeliverScreenState extends State<DriverDeliverScreen> {
  static const _maxLen = 8, _minLen = 4;
  String otp = '';
  bool busy = false;
  Failure? fail;
  int shake = 0;
  String key = IdempotencyKey.generate();
  DriverOrderModel? o;
  final _deliver = DeliverOrderUseCase(
    deliver: (id, {otp, uploadIds, required key}) => backend.driverDeliver(id, otp: otp, uploadIds: uploadIds, key: key),
    current: () => backend.driverCurrent(),
  );

  @override
  void initState() {
    super.initState();
    o = Get.isRegistered<TaskController>() ? Get.find<TaskController>().order.value : driverCtl().current.value;
  }

  bool get photo => Get.find<RemoteConfigRepository>().current?.deliveryConfirmation == 'photo';
  bool get ready => !busy && otp.length >= _minLen;

  Future<void> _submit({List<int> ups = const []}) async {
    final order = o;
    if (order == null || busy) return;
    setState(() {
      busy = true;
      fail = null;
    });
    final r = await _deliver(order: order, otp: otp, uploadIds: ups, key: key);
    if (!mounted) return;
    r.fold((f) {
      Haptics.error();
      setState(() {
        busy = false;
        fail = f;
        shake++;
        if (!f.hasNoResponse) key = IdempotencyKey.generate();
      });
    }, (v) => _close(order, v));
  }

  Future<void> _close(DriverOrderModel before, DriverOrderModel after) async {
    Haptics.confirm();
    if (Get.isRegistered<TaskController>()) {
      final t = Get.find<TaskController>()..stopPolling();
      t.order.value = null;
      t.loading.value = false;
    }
    final d = driverCtl();
    d.current.value = null;
    await d.refreshAll();
    if (Get.isRegistered<AvailableController>()) Get.find<AvailableController>().load(silent: true);
    final earning = after.earning.amount > 0 ? after.earning.amount : before.earning.amount;
    Get.offAllNamed('/driver/delivered', arguments: {'earning': earning, 'code': before.code});
  }

  void _key(String k) {
    if (busy) return;
    setState(() {
      fail = null;
      if (k == '⌫') {
        if (otp.isNotEmpty) otp = otp.substring(0, otp.length - 1);
      } else if (otp.length < _maxLen) {
        otp += k;
      }
    });
  }

  Future<void> _paste() async {
    final t = (await Clipboard.getData('text/plain'))?.text ?? '';
    final digits = t.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty || !mounted) return;
    setState(() {
      fail = null;
      otp = digits.length > _maxLen ? digits.substring(0, _maxLen) : digits;
    });
  }

  String _errText(BuildContext context, Failure f) {
    final l = context.l10n;
    if (f is DeliveryCodeInvalid) return l.driverDeliverErrWrong;
    if (f is DeliveryTooManyAttempts) return l.driverDeliverErrTooMany;
    if (f is DeliveryInvalidState) return l.driverDeliverErrState;
    if (f is NetworkFailure || f is TimeoutFailure) return l.driverDeliverErrNetwork;
    if (f is UnauthorizedFailure) return l.driverDeliverErrSession;
    return failureText(f);
  }

  Widget? _errAction(BuildContext context, Failure f) {
    final l = context.l10n;
    if (f is DeliveryInvalidState) {
      return SBtn(l.driverDeliverRefresh, kind: BtnKind.sec, size: BtnSize.sm, icon: 'refresh', onTap: () async {
        await driverCtl().refreshAll();
        if (Get.isRegistered<TaskController>()) await Get.find<TaskController>().load();
        Get.back();
      });
    }
    if (f is UnauthorizedFailure) return SBtn(l.driverSignIn, kind: BtnKind.sec, size: BtnSize.sm, onTap: () => Get.offAllNamed('/auth/phone'));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    final x = o;
    final f = fail;
    final action = f == null ? null : _errAction(context, f);
    return Page2(
      top: TopBar(title: l.driverDeliverTitle),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(photo ? 'صوّر لإثبات التسليم' : l.driverDeliverTitle, style: T.h1(c.tx)),
        const SizedBox(height: 8),
        Text(photo ? 'التقط صورة للطلب عند باب الزبون.' : l.driverDeliverHint, style: T.sm(c.tx2)),
        if (x != null) ...[
          const SizedBox(height: 8),
          Text('${x.code} · ${x.customerName ?? 'الزبون'}', style: T.cap(c.tx2)),
        ],
        const SizedBox(height: 24),
        if (photo)
          DropZone(icon: 'camera', title: 'التقط صورة', onTap: busy ? null : () async {
            final ups = await pickAndUpload('delivery_proof');
            if (ups != null) _submit(ups: ups);
          })
        else ...[
          ShakeOnChange(trigger: shake, child: FittedBox(fit: BoxFit.scaleDown, child: OtpBoxes(digits: otp, length: otp.length < _minLen ? _minLen : otp.length, bad: f is DeliveryCodeInvalid, current: otp.length < _minLen))),
          const SizedBox(height: 8),
          Center(child: SLink(l.driverDeliverPaste, onTap: busy ? null : _paste)),
        ],
        if (f != null) ...[
          const SizedBox(height: 16),
          Note('err', icon: 'alertC', text: _errText(context, f)),
          if (action != null) ...[const SizedBox(height: 8), Align(alignment: AlignmentDirectional.centerStart, child: action)],
        ],
        const SizedBox(height: 24),
        if (x != null && x.isCash) Panel(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.driverDeliverCollect, style: T.cap(c.tx2)), Mny(x.collect.amount, size: 26)]), SIcon('cash', size: 30, color: c.tx)])),
        const SizedBox(height: 16),
        Center(child: SLink(l.driverFailDeliveryCta, color: c.err, onTap: busy ? null : () => Get.toNamed('/driver/failed'))),
      ]),
      foot: photo
          ? null
          : Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: SBtn(l.driverDeliverConfirm, full: true, icon: 'checkC', loading: busy, disabled: !ready, hapticOnPress: false, onTap: ready ? () => _submit() : null)),
              Keypad(onKey: _key, disabled: busy),
            ]),
    );
  }
}
