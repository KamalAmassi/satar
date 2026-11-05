import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/vibration_tile.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/motion/entrance.dart';
import 'package:project/core/services/push/push_service.dart';
import 'package:project/core/widgets/push_toggle_tiles.dart';
import 'package:project/data/models.dart';
import 'package:project/features/account/account.dart' show doSignOut, langSheet;
import 'package:project/features/common.dart';
import 'package:project/features/driver/driver.dart';

// ------------------------------------------------------------------ use case

/// تسجيل خروج السائق: إيقاف التتبّع ← غير متصل (إن كان متصلًا) ← إلغاء رمز FCM
/// ← POST /driver/auth/logout ← مسح الجلسة محليًا **دائمًا** حتى لو فشل أي استدعاء (شبكة/401).
class DriverSignOutUseCase {
  DriverSignOutUseCase({
    required this.isOnline,
    required this.goOffline,
    required this.stopTracking,
    required this.unregisterPush,
    required this.remoteLogout,
    required this.clearSession,
  });

  final bool Function() isOnline;
  final Future<void> Function() goOffline;
  final void Function() stopTracking;
  final Future<void> Function() unregisterPush;
  final Future<Either<Failure, void>> Function() remoteLogout;
  final Future<void> Function() clearSession;

  Future<void> call() async {
    try {
      try {
        stopTracking();
      } catch (_) {}
      if (isOnline()) {
        try {
          await goOffline();
        } catch (_) {}
      }
      // قبل إبطال الجلسة على الخادم حتى يُقبل الطلب بالتوكن الحالي.
      try {
        await unregisterPush();
      } catch (_) {}
      try {
        await remoteLogout();
      } catch (_) {}
    } finally {
      await clearSession();
    }
  }
}

// ---------------------------------------------------------------- controller

class DriverSettingsController extends GetxController {
  DriverSettingsController({required this.fetchMe, required this.signOutUseCase, this.onLoaded, DriverModel? initial}) {
    me.value = initial;
  }

  final Future<Either<Failure, DriverModel>> Function() fetchMe;
  final DriverSignOutUseCase signOutUseCase;
  final void Function(DriverModel)? onLoaded;

  final me = Rxn<DriverModel>();
  final loading = false.obs;
  final failure = Rxn<Failure>();
  final signingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// GET /driver/me. البيانات القديمة تبقى معروضة عند الفشل أثناء السحب للتحديث.
  Future<void> load() async {
    loading.value = true;
    final r = await fetchMe();
    r.fold((f) => failure.value = f, (m) {
      me.value = m;
      failure.value = null;
      onLoaded?.call(m);
    });
    loading.value = false;
  }

  /// يمنع الضغط المزدوج: أي نداء أثناء التنفيذ يُتجاهل.
  Future<void> signOut() async {
    if (signingOut.value) return;
    signingOut.value = true;
    try {
      await signOutUseCase();
    } finally {
      signingOut.value = false;
    }
  }
}

DriverSettingsController _driverSettingsCtl() {
  if (Get.isRegistered<DriverSettingsController>()) return Get.find<DriverSettingsController>();
  final d = driverCtl();
  return Get.put(DriverSettingsController(
    initial: d.me.value,
    fetchMe: backend.driverMe,
    onLoaded: (m) => d.me.value = m,
    signOutUseCase: DriverSignOutUseCase(
      isOnline: () => Get.isRegistered<DriverController>() && (Get.find<DriverController>().me.value?.isOnline ?? false),
      goOffline: () => backend.driverStatus(false),
      stopTracking: () {
        if (Get.isRegistered<DriverLocationService>()) Get.find<DriverLocationService>().stop();
      },
      unregisterPush: () async => PushService.maybe?.onLogout(),
      remoteLogout: backend.driverLogout,
      clearSession: () async {
        // يلغي مؤقّت الاستطلاع (onClose) ثم يمسح الجلسة ويعود للجذر بلا رجوع.
        if (Get.isRegistered<DriverController>()) Get.delete<DriverController>(force: true);
        await doSignOut(call: false);
      },
    ),
  ));
}

// -------------------------------------------------------------------- labels

String vehicleLabel(AppLocalizations l, String key) => switch (key) {
      'motorcycle' => l.vehicleMotorcycle,
      'car' => l.vehicleCar,
      'bicycle' => l.vehicleBicycle,
      'van' => l.vehicleVan,
      'tuk_tuk' => l.vehicleTukTuk,
      'on_foot' => l.vehicleOnFoot,
      _ => key,
    };

// -------------------------------------------------------------------- screen

/// إعدادات السائق (/driver/profile): بطاقة السائق، بياناتي، الإشعارات، اللغة، الخروج.
class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ctl = _driverSettingsCtl();
    return Obx(() {
      final me = ctl.me.value;
      final Widget body;
      if (me == null && ctl.failure.value != null) {
        return Page2(
          tab: 'set',
          role: TabRole.driver,
          top: TopBar(title: l.driverSettingsTitle, back: false),
          center: true,
          body: EmptyState(ill: 'offline', title: l.driverSettingsLoadErrorTitle, text: l.driverSettingsLoadErrorText, cta: SBtn(l.driverSettingsRetry, full: true, onTap: ctl.load)),
        );
      } else if (me == null) {
        body = const Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Skel(h: 110, r: 20), SizedBox(height: 24), Skel(h: 260, r: 20), SizedBox(height: 24), Skel(h: 140, r: 20)]);
      } else {
        body = _Content(ctl: ctl, me: me);
      }
      return Page2(tab: 'set', role: TabRole.driver, top: TopBar(title: l.driverSettingsTitle, back: false), onRefresh: ctl.load, body: body);
    });
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.ctl, required this.me});
  final DriverSettingsController ctl;
  final DriverModel me;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    var i = 0;
    Widget e(Widget w) => Entrance(index: i++, child: w);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      e(_DriverCard(me: me)),
      const SizedBox(height: 24),
      e(_Section(title: l.driverSettingsMyData, child: _DataRows(me: me))),
      const SizedBox(height: 24),
      e(_Section(title: l.driverSettingsNotifications, child: const _NotifRows())),
      const SizedBox(height: 24),
      e(Card2(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: [
          LiTile('globe', l.driverSettingsLanguage, sub: _langName(), onTap: () => langSheet(context)),
          const VibrationTile(),
        ]),
      )),
      const SizedBox(height: 24),
      e(_LogoutTile(ctl: ctl)),
      const SizedBox(height: 16),
    ]);
  }
}

String _langName() => (Get.locale?.languageCode ?? 'ar') == 'en' ? 'English' : 'العربية';

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SecHead(title),
        const SizedBox(height: 10),
        Card2(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: child),
      ]);
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.me});
  final DriverModel me;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    final url = me.avatarUrl;
    final avatar = Avatar(me.initial, large: true);
    return Card2(
      child: Row(children: [
        url == null || url.isEmpty
            ? avatar
            : ClipOval(child: Image.network(url, width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (_, __, ___) => avatar)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(me.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.h2(c.tx)),
            Text(me.phone, textDirection: TextDirection.ltr, style: T.sm(c.tx2)),
            const SizedBox(height: 4),
            Text(vehicleLabel(l, me.vehicleType), style: T.sm(c.tx2)),
            const SizedBox(height: 6),
            Row(children: [
              for (var s = 1; s <= 5; s++) SIcon('star', size: 14, color: s <= me.rating.round() ? c.amber : c.tx3, filled: s <= me.rating.round()),
              const SizedBox(width: 6),
              Flexible(child: Text(l.driverSettingsRatingCount(me.rating.toStringAsFixed(1), me.ratingCount), style: T.sm(c.tx))),
            ]),
          ]),
        ),
        const SizedBox(width: 8),
        _OnlineBadge(on: me.isOnline),
      ]),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge({required this.on});
  final bool on;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: on ? c.okSoft : c.sf2, borderRadius: BorderRadius.circular(Rad.l)),
      child: Text(on ? l.driverSettingsOnline : l.driverSettingsOffline, style: T.cap(on ? c.okInk : c.tx2)),
    );
  }
}

class _DataRows extends StatelessWidget {
  const _DataRows({required this.me});
  final DriverModel me;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    const none = SizedBox.shrink();
    final zone = me.zoneName ?? (me.zoneId == null ? null : '#${me.zoneId}');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      LiTile('user', l.driverSettingsName, sub: me.name, end: none),
      LiTile('phone', l.driverSettingsPhone, sub: '‎${me.phone}', end: none, first: false),
      LiTile('truck', l.driverSettingsVehicle, sub: vehicleLabel(l, me.vehicleType), end: none, first: false),
      if (zone != null) LiTile('pin', l.driverSettingsZone, sub: zone, end: none, first: false),
      _CashRow(me: me),
      LiTile('globe', l.driverSettingsLanguage, sub: me.locale == 'en' ? 'English' : 'العربية', end: none, first: false),
    ]);
  }
}

class _CashRow extends StatelessWidget {
  const _CashRow({required this.me});
  final DriverModel me;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    final max = me.maxCash.amount;
    final ratio = max <= 0 ? 0.0 : me.cashOnHand.amount / max;
    final near = ratio >= 0.8;
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.ln))),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(l.driverSettingsCash, style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w600, fontSize: 15.5, color: c.tx))),
          Mny(me.cashOnHand.amount, size: 14, color: near ? c.errInk : c.tx),
          Text(' / ', style: T.sm(c.tx2)),
          Mny(me.maxCash.amount, size: 14, weight: FontWeight.w400, color: c.tx2),
        ]),
        const SizedBox(height: 8),
        ProgressBar(ratio, color: near ? c.err : c.amber),
        if (near) ...[
          const SizedBox(height: 8),
          Text(l.driverSettingsCashNearLimit, style: T.cap(c.errInk)),
        ],
      ]),
    );
  }
}

class _NotifRows extends StatelessWidget {
  const _NotifRows();
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(children: [
      const PushToggleTiles(),
      LiTile('clock', l.driverSettingsNotifHistory, first: false, onTap: () => Get.toNamed('/driver/notifications')),
    ]);
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.ctl});
  final DriverSettingsController ctl;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    return Obx(() {
      final busy = ctl.signingOut.value;
      return Card2(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: LiTile(
          'logout',
          l.driverSettingsLogout,
          sub: l.driverSettingsLogoutSub,
          iconBg: c.errSoft,
          end: busy ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: c.errInk)) : null,
          onTap: busy
              ? null
              : () => showDlg(context, kind: 'err', icon: 'logout', title: l.driverSettingsLogoutTitle, text: l.driverSettingsLogoutText, foot: [
                    SBtn(l.driverSettingsLogout, kind: BtnKind.danger, full: true, onTap: () {
                      Get.back();
                      ctl.signOut();
                    }),
                    SBtn(l.driverSettingsCancel, kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
                  ]),
        ),
      );
    });
  }
}
