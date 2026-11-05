import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/uploads/picked_file.dart';
import 'package:project/core/uploads/upload_repository.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';
import 'package:project/customer/features/printing/domain/entities/print_spec.dart';
import 'package:project/customer/features/printing/presentation/controllers/printing_controller.dart';
import 'package:project/core/widgets/common_widgets.dart';

PrintingController printCtl() {
  PrintingBinding().dependencies();
  return Get.find<PrintingController>();
}

class PrintLandingScreen extends StatelessWidget {
  const PrintLandingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final cfg = Get.find<RemoteConfigRepository>().current?.printing;
    return Page2(
      tab: 'print',
      top: const TopBar(title: 'الطباعة', back: false, right: CartBadgeButton()),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        HeroBox(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('اطبع ملفاتك بسهولة', style: T.d2(c.onHero)),
          const SizedBox(height: 8),
          Text('ارفع ملفات PDF أو الصور، اختر الورق والتجليد، ونوصلها لك.', style: T.bd(c.onHero)),
        ])),
        const SizedBox(height: 24),
        Text('خدمات الطباعة', style: T.h2(c.tx, size: 18)),
        const SizedBox(height: 12),
        for (final (icon, title, desc) in const [
          ('file', 'طباعة المستندات', 'A4 / A3، أبيض وأسود أو ملوّن'),
          ('layers', 'التجليد والتغليف', 'حلزوني، حراري، أو سلك'),
          ('printer', 'جودة عالية وتسليم سريع', 'تستلمها مع طلباتك السابقة'),
        ]) ...[
          Card2(child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: c.plumSoft, borderRadius: BorderRadius.circular(12)), child: Center(child: SIcon(icon, size: 22, color: c.plumInk))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: T.h3(c.tx, size: 15.5)), Text(desc, style: T.sm(c.tx2))])),
          ])),
          const SizedBox(height: 12),
        ],
      ]),
      foot: Foot(child: SBtn('اختر ملفات', icon: 'upload', full: true, disabled: cfg == null, onTap: () => Get.toNamed('/print/upload', arguments: {'pick': true}))),
    );
  }
}

class PrintUploadScreen extends StatefulWidget {
  const PrintUploadScreen({super.key});
  @override
  State<PrintUploadScreen> createState() => _PrintUploadScreenState();
}

class _PrintUploadScreenState extends State<PrintUploadScreen> {
  late final ctl = printCtl();
  bool picking = false;

  @override
  void initState() {
    super.initState();
    final a = Get.arguments;
    if (a is Map && a['pick'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickFiles());
    }
  }

  Future<void> _pickFiles() async {
    if (picking) return;
    setState(() => picking = true);
    try {
      final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'], allowMultiple: true, withData: false, withReadStream: true);
      if (res != null && res.files.isNotEmpty) {
        for (final f in res.files) {
          if (f.path != null) {
            final picked = PickedFile(id: f.path!, name: f.name, sizeBytes: f.size, path: f.path, mimeType: f.extension == 'pdf' ? 'application/pdf' : 'image/jpeg');
            ctl.addJob(picked);
          }
        }
      }
    } catch (_) {
      showToast('تعذّر اختيار الملفات', icon: 'alertC');
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Obx(() {
      final jobs = ctl.jobs;
      final ready = ctl.readyToProceed;
      return Page2(
        top: TopBar(title: 'ملفات الطباعة', right: SBtn('إضافة ملف', kind: BtnKind.sec, size: BtnSize.xs, icon: 'plus', onTap: _pickFiles)),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (jobs.isEmpty)
            Card2(
              onTap: _pickFiles,
              child: Column(children: [
                SIcon('upload', size: 40, color: c.plumInk),
                const SizedBox(height: 12),
                Text('اضغط لاختيار ملفات PDF أو صور', style: T.h3(c.tx)),
                const SizedBox(height: 4),
                Text('PDF، PNG، JPG حتى 50 ميغابايت للملف', style: T.sm(c.tx2)),
              ]),
            )
          else
            Column(children: [
              for (final j in jobs) ...[
                _JobUploadCard(j, ctl),
                const SizedBox(height: 12),
              ],
            ]),
        ]),
        foot: FootBar(child: SBtn(ready ? 'متابعة إلى المواصفات' : (jobs.isEmpty ? 'اختر ملفًا أولًا' : 'أكمل رفع الملفات'), full: true, disabled: !ready, onTap: () => Get.toNamed('/print/specs'))),
      );
    });
  }
}

class _JobUploadCard extends StatelessWidget {
  const _JobUploadCard(this.job, this.ctl);
  final PrintJob job;
  final PrintingController ctl;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final st = job.uploadState;
    return Card2(child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: c.plumSoft, borderRadius: BorderRadius.circular(14)), child: Center(child: SIcon('file', size: 24, color: c.plumInk))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(job.fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.h3(c.tx, size: 15)),
        const SizedBox(height: 2),
        if (st == JobUploadState.done) Text('جاهز · ${job.pageCount ?? '?'} صفحة', style: T.sm(c.okInk)) else if (st == JobUploadState.uploading) Text('جارٍ الرفع…', style: T.sm(c.amberInk)) else Text('لم يكتمل الرفع', style: T.sm(c.errInk)),
      ])),
      SIconBtn('trash', size: 20, box: 40, onTap: () => ctl.removeJob(job.id)),
    ]));
  }
}

class PrintSpecsScreen extends StatefulWidget {
  const PrintSpecsScreen({super.key});
  @override
  State<PrintSpecsScreen> createState() => _PrintSpecsScreenState();
}

class _PrintSpecsScreenState extends State<PrintSpecsScreen> {
  late final ctl = printCtl();
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final cfg = Get.find<RemoteConfigRepository>().current?.printing;
    if (cfg == null) return Page2(top: const TopBar(title: 'مواصفات الطباعة'), center: true, body: EmptyState(ill: 'print', title: 'خدمة الطباعة غير متاحة', text: 'حاول مجددًا بعد قليل.'));
    return Obx(() {
      final jobs = ctl.jobs;
      final selId = ctl.selectedJobId.value ?? (jobs.isNotEmpty ? jobs.first.id : '');
      final job = jobs.firstWhereOrNull((j) => j.id == selId) ?? (jobs.isNotEmpty ? jobs.first : null);
      if (job == null) return Page2(top: const TopBar(title: 'مواصفات الطباعة'), center: true, body: EmptyState(ill: 'file', title: 'لا ملفات مطابقة', text: 'اختر ملفًا أولًا.', cta: SBtn('اختر ملفات', onTap: () => Get.toNamed('/print/upload'))));
      final s = job.spec;
      final anyBad = ctl.hasInvalidSpecs;
      return Page2(
        top: const TopBar(title: 'مواصفات الطباعة'),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (jobs.length > 1) ...[
            SizedBox(
              height: 40,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                for (final j in jobs) ...[SChip(j.fileName, icon: 'file', on: j.id == job.id, onTap: () => setState(() => ctl.selectedJobId.value = j.id)), const SizedBox(width: 8)],
              ]),
            ),
            const SizedBox(height: 16),
          ],
          Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('العدد والأحجام', style: T.h3(c.tx)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('عدد النسخ', style: T.sm(c.tx)),
              Stepper2(value: s.copies, lg: true, onInc: () => _apply(job, (x) => x.copyWith(copies: (x.copies + 1).clamp(1, 99))), onDec: () => _apply(job, (x) => x.copyWith(copies: (x.copies - 1).clamp(1, 99)))),
            ]),
            const SizedBox(height: 16),
            Text('التجليد والتغليف', style: T.sm(c.tx)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final b in cfg.bindings) ...[SChip(b.label, on: s.binding == b.key, onTap: () => _apply(job, (x) => x.copyWith(binding: b.key)))],
            ]),
          ])),
          const SizedBox(height: 16),
          Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('اللون والوجهين', style: T.h3(c.tx)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OptCard(on: s.color == 'bw', icon: 'file', title: 'أبيض وأسود', onTap: () => _apply(job, (x) => x.copyWith(color: 'bw')))),
              const SizedBox(width: 12),
              Expanded(child: OptCard(on: s.color == 'color', icon: 'sparkles', title: 'ملوّن', onTap: () => _apply(job, (x) => x.copyWith(color: 'color')))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OptCard(on: s.sides == 'double', icon: 'layers', title: 'وجهان', onTap: () => _apply(job, (x) => x.copyWith(sides: 'double')))),
              const SizedBox(width: 12),
              Expanded(child: OptCard(on: s.sides == 'single', icon: 'file', title: 'وجه واحد', onTap: () => _apply(job, (x) => x.copyWith(sides: 'single')))),
            ]),
          ])),
        ]),
        foot: FootBar(child: SBtn(anyBad ? 'صحّح الحقول' : 'مراجعة الطباعة', disabled: anyBad, onTap: () => Get.toNamed('/print/review'))),
      );
    });
  }

  void _apply(PrintJob job, PrintSpec Function(PrintSpec) f) {
    ctl.updateSpec(job.id, f(job.spec));
  }
}

class PrintReviewScreen extends StatelessWidget {
  const PrintReviewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = printCtl();
    final cfg = Get.find<RemoteConfigRepository>().current?.printing;
    return Obx(() {
      final jobs = ctl.jobs;
      final totalEst = ctl.totalEstimateMinor;
      return Page2(
        top: const TopBar(title: 'مراجعة الطباعة'),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final j in jobs) ...[
            Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                SIcon('file', size: 22, color: c.plumInk),
                const SizedBox(width: 10),
                Expanded(child: Text(j.fileName, style: T.h3(c.tx))),
              ]),
              const SizedBox(height: 8),
              Text(specSummary(j, cfg), style: T.sm(c.tx2)),
            ])),
            const SizedBox(height: 12),
          ],
          PriceBox(rows: [('تقدير الطباعة', Mny(totalEst))], totalMinor: totalEst, totalLabel: 'التقدير التخليقي'),
          const SizedBox(height: 16),
          const Note('plum', text: 'هذا السعر تقديري. تحسب المكتبة السعر النهائي الدقيق وتعرضه عليك للموافقة.'),
        ]),
        foot: FootBar(child: SBtn('أضف إلى السلة', icon: 'bag', full: true, onTap: () {
          ctl.addJobsToCart();
          Get.toNamed('/cart');
        })),
      );
    });
  }
}
