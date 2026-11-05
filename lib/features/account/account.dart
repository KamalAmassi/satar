import 'package:flutter/material.dart';
import 'package:project/core/services/push/push_service.dart';
import 'package:project/core/widgets/push_toggle_tiles.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/design/vibration_tile.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/storage/session_store.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/customer/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:project/data/models.dart';
import 'package:project/features/common.dart';
import 'package:project/features/orders/orders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountController extends GetxController {
  final user = Rxn<UserModel>();
  final addresses = <AddressModel>[].obs;
  final loading = true.obs;
  final failure = Rxn<Failure>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = user.value == null;
    final r = await Future.wait([backend.me(), backend.addresses()]);
    r[0].fold((f) => failure.value = f, (v) {
      user.value = v as UserModel;
      failure.value = null;
    });
    r[1].fold((_) {}, (v) => addresses.assignAll(v as List<AddressModel>));
    loading.value = false;
  }
}

Future<void> doSignOut({bool call = true}) async {
  final s = Get.find<SessionStore>();
  // إلغاء تسجيل رمز FCM قبل إبطال جلسة الخادم؛ الفشل لا يمنع الخروج.
  await PushService.maybe?.onLogout();
  if (call) {
    await (s.isDriver ? backend.driverLogout() : backend.logout());
  }
  await s.signOut();
  if (Get.isRegistered<CheckoutController>()) Get.delete<CheckoutController>(force: true);
  Get.offAllNamed('/');
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = Get.put(AccountController());
    return Obx(() {
      final u = ctl.user.value;
      final cfg = Get.find<RemoteConfigRepository>().current;
      final lang = (Get.locale?.languageCode ?? 'ar') == 'en' ? 'English' : 'العربية';
      if (ctl.loading.value && u == null) return Page2(tab: 'acc', top: const BigHeadTop(eyebrow: 'الحساب', title: 'حسابي'), body: const Column(children: [SizedBox(height: 12), Skel(h: 90, r: 20), SizedBox(height: 24), Skel(h: 200, r: 20)]));
      if (u == null) return Page2(tab: 'acc', center: true, body: EmptyState(ill: 'offline', title: 'تعذّر تحميل الحساب', text: failureText(ctl.failure.value ?? const UnknownFailure()), cta: SBtn('أعد المحاولة', full: true, onTap: ctl.load)));
      return Page2(
        tab: 'acc',
        top: const BigHeadTop(eyebrow: 'الحساب', title: 'حسابي'),
        onRefresh: ctl.load,
        body: Padding(padding: const EdgeInsets.only(top: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card2(child: Row(children: [
            Avatar(u.initial, large: true),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text((u.name ?? '').isEmpty ? 'مرحبًا' : u.name!, style: T.h2(c.tx)), Text(u.phone, textDirection: TextDirection.ltr, textAlign: TextAlign.start, style: T.sm(c.tx2))])),
            SBtn('تعديل', kind: BtnKind.sec, size: BtnSize.xs, onTap: () async {
              await Get.toNamed('/profile');
              ctl.load();
            }),
          ])),
          const SizedBox(height: 24),
          Card2(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [
            LiTile('pin', 'عناويني', sub: ctl.addresses.isEmpty ? 'لا عناوين محفوظة' : '${ctl.addresses.length} ${ctl.addresses.length == 1 ? 'عنوان محفوظ' : 'عناوين محفوظة'}', onTap: () async {
              await Get.toNamed('/addresses');
              ctl.load();
            }),
            const PushToggleTiles(first: false),
            LiTile('globe', 'اللغة', sub: lang, first: false, onTap: () => langSheet(context)),
            const VibrationTile(),
          ])),
          const SizedBox(height: 24),
          Card2(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: [
            LiTile('headset', 'الدعم', sub: cfg?.supportPhone == null ? null : 'اتصل بنا: ${cfg!.supportPhone}', onTap: supportCall),
            LiTile('file', 'الشروط والأحكام', first: false, onTap: () async {
              final t = cfg?.termsUrl;
              if (t != null) await launchUrl(Uri.parse(t), mode: LaunchMode.externalApplication);
            }),
          ])),
          const SizedBox(height: 24),
          Card2(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: LiTile('logout', 'تسجيل الخروج', onTap: () => logoutDialog(context))),
          const SizedBox(height: 24),
          Center(child: SLink('حذف حسابي', color: c.errInk, onTap: () => Get.toNamed('/account/delete'))),
          Center(child: Text('سطر · النسخة 1.0.0 · الإعدادات v${cfg?.configVersion ?? '-'}', style: T.cap(c.tx2))),
        ])),
      );
    });
  }
}

void langSheet(BuildContext context) {
  var sel = Get.locale?.languageCode ?? 'ar';
  final supported = Get.find<RemoteConfigRepository>().current?.supportedLocales ?? const ['ar', 'en'];
  showSheet(context, title: 'اللغة', body: StatefulBuilder(builder: (ctx, set) => Column(children: [
        if (supported.contains('ar')) ...[OptCard(on: sel == 'ar', title: 'العربية', sub: 'اتجاه من اليمين لليسار', onTap: () => set(() => sel = 'ar')), const SizedBox(height: 8)],
        if (supported.contains('en')) OptCard(on: sel == 'en', title: 'English', sub: 'Left-to-right', onTap: () => set(() => sel = 'en')),
      ])), foot: [
    SBtn('تم', full: true, onTap: () async {
      Get.back();
      await Get.find<SharedPreferences>().setString('locale', sel);
      Get.updateLocale(Locale(sel));
      Get.find<RemoteConfigRepository>().load(refresh: true);
      final s = Get.find<SessionStore>();
      if (s.isSignedIn) {
        s.isDriver ? await backend.updateDriver(locale: sel) : await backend.updateMe(locale: sel);
      }
    }),
  ]);
}

void logoutDialog(BuildContext context) {
  showDlg(context, icon: 'logout', title: 'تسجيل الخروج؟', text: 'ستحتاج لرمز جديد عند الدخول مجددًا. تبقى سلتك محفوظة على الجهاز.', foot: [
    SBtn('تسجيل الخروج', full: true, onTap: () {
      Get.back();
      doSignOut();
    }),
    SBtn('إلغاء', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
  ]);
}

// ------------------------------------------------------------- profile edit

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final name = TextEditingController();
  UserModel? u;
  bool busy = false;
  int? avatarId;
  String? err;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    backend.me().then((r) => r.fold((_) {}, (v) {
          if (!mounted) return;
          setState(() => u = v);
          name.text = v.name ?? '';
        }));
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> _avatar() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1200);
    if (x == null) return;
    setState(() => uploading = true);
    final b = await x.readAsBytes();
    final mime = x.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
    final r = await Get.find<UploadRepository>().upload(bytes: b, fileName: x.name, mime: mime, purpose: 'avatar');
    if (!mounted) return;
    setState(() => uploading = false);
    r.fold((f) => showToast(failureText(f), icon: 'alertC'), (up) {
      setState(() => avatarId = up.uploadId);
      showToast('اختيرت الصورة. اضغط حفظ');
    });
  }

  Future<void> _save() async {
    final n = name.text.trim();
    if (n.length < 2 || n.length > 120) {
      setState(() => err = 'الاسم من حرفين إلى 120 حرفًا.');
      return;
    }
    setState(() {
      busy = true;
      err = null;
    });
    final r = await backend.updateMe(name: n, avatarUploadId: avatarId);
    if (!mounted) return;
    setState(() => busy = false);
    r.fold((f) => setState(() => err = f is ValidationFailure ? (f.fieldErrors['name'] ?? f.message) : failureText(f)), (_) {
      showToast('تم الحفظ');
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Page2(
      top: const TopBar(title: 'تعديل الملف'),
      body: u == null
          ? const Skel(h: 200, r: 20)
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(child: Column(children: [
                Avatar(u!.initial, large: true),
                const SizedBox(height: 8),
                SBtn('تغيير الصورة', kind: BtnKind.ghost, size: BtnSize.sm, icon: 'camera', loading: uploading, onTap: _avatar),
              ])),
              const SizedBox(height: 24),
              Fld(label: 'الاسم', controller: name, error: err),
              const SizedBox(height: 24),
              Fld(label: 'رقم الجوال', controller: TextEditingController(text: u!.phone), ltr: true, enabled: false, helper: 'لا يمكن تغيير الرقم من هنا.'),
            ]),
      foot: FootBar(child: SBtn('حفظ', full: true, loading: busy, onTap: u == null ? null : _save)),
    );
  }
}

// --------------------------------------------------------------- addresses

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<AddressModel>? list;
  Failure? f;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await backend.addresses();
    if (!mounted) return;
    r.fold((e) => setState(() => f = e), (v) => setState(() {
          list = v;
          f = null;
        }));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(
      top: TopBar(title: 'عناويني', right: SIconBtn('plus', onTap: () async {
        await Get.toNamed('/address/form');
        _load();
      })),
      onRefresh: _load,
      body: list == null
          ? (f == null ? const Skel(h: 80, r: 20) : EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(f!), cta: SBtn('أعد المحاولة', full: true, onTap: _load)))
          : list!.isEmpty
              ? EmptyState(ill: 'pin', title: 'لا عناوين بعد', text: 'أضف عنوانك ليصلك الطلب إلى بابك.', cta: SBtn('إضافة عنوان', icon: 'plus', full: true, onTap: () async {
                  await Get.toNamed('/address/form');
                  _load();
                }))
              : Column(children: [
                  for (final a in list!) ...[
                    Card2(child: Row(children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(14)), child: Center(child: SIcon('pin', size: 22, color: c.onHero))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [Text(a.title, style: T.h3(c.tx, size: 15.5)), const SizedBox(width: 8), if (a.isDefault) const STag('الافتراضي', kind: 'plum')]),
                        Text(a.details ?? '', style: T.sm(c.tx2)),
                        if (!a.isDefault) InkWell(onTap: () async {
                          await backend.saveAddress(id: a.id, label: a.title, lat: a.lat, lng: a.lng, details: a.details, isDefault: true);
                          _load();
                        }, child: Padding(padding: const EdgeInsets.only(top: 4), child: Text('تعيين كافتراضي', style: T.sm(c.plumInk, w: FontWeight.w600).copyWith(decoration: TextDecoration.underline)))),
                      ])),
                      SIconBtn('edit', size: 20, onTap: () async {
                        await Get.toNamed('/address/form', arguments: a);
                        _load();
                      }),
                      SIconBtn('trash', size: 20, onTap: () => _delete(context, a)),
                    ])),
                    const SizedBox(height: 16),
                  ],
                ]),
    );
  }

  void _delete(BuildContext context, AddressModel a) {
    showDlg(context, kind: 'err', icon: 'trash', title: 'حذف عنوان «${a.title}»؟', text: 'طلباتك السابقة تحتفظ بنسخة من العنوان ولن تتأثر.', foot: [
      SBtn('احذف', kind: BtnKind.danger, full: true, onTap: () async {
        Get.back();
        final r = await backend.deleteAddress(a.id);
        r.fold((e) => showToast(failureText(e), icon: 'alertC'), (_) => showToast('حُذف العنوان'));
        _load();
      }),
      SBtn('تراجع', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
    ]);
  }
}

// ------------------------------------------------------------ delete account

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});
  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final t = TextEditingController();
  bool busy = false;
  String? err;
  @override
  void dispose() {
    t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Page2(
      top: const TopBar(title: 'حذف الحساب'),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Note('err', icon: 'alert', child: Text('هذا الإجراء لا يمكن التراجع عنه.', style: TextStyle(fontWeight: FontWeight.w700))),
        const SizedBox(height: 24),
        Text('ماذا يحدث عند الحذف؟', style: T.h1(c.tx)),
        const SizedBox(height: 8),
        for (final s in const ['تُخفى بيانات حسابك وعناوينك.', 'يُسجَّل خروجك من كل الأجهزة.', 'تبقى الطلبات السابقة في سجلات المكتبة لأغراض العمل.']) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(top: 4), child: SIcon('check', size: 18, color: c.tx)), const SizedBox(width: 10), Expanded(child: Text(s, style: T.bd(c.tx)))])),
        const SizedBox(height: 16),
        Fld(label: 'اكتب «حذف» للتأكيد', hint: 'حذف', controller: t, onChanged: (_) => setState(() => err = null), error: err),
      ]),
      foot: FootBar(child: Column(mainAxisSize: MainAxisSize.min, children: [
        SBtn('احذف حسابي نهائيًا', kind: BtnKind.danger, full: true, loading: busy, disabled: t.text.trim() != 'حذف', onTap: () async {
          setState(() => busy = true);
          final r = await backend.deleteMe();
          if (!mounted) return;
          setState(() => busy = false);
          r.fold((f) => setState(() => err = failureText(f)), (_) async {
            await doSignOut(call: false);
          });
        }),
        const SizedBox(height: 8),
        SBtn('احتفظ بحسابي', full: true, onTap: () => Get.back()),
      ])),
    );
  }
}
