import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/customer/features/printing/domain/entities/file_check.dart';
import 'package:project/customer/features/printing/domain/entities/page_range.dart';
import 'package:project/customer/features/printing/domain/entities/print_estimate.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';
import 'package:project/customer/features/printing/domain/entities/print_spec.dart';
import 'package:project/customer/features/printing/presentation/bindings/printing_binding.dart';
import 'package:project/customer/features/printing/presentation/controllers/printing_controller.dart';
import 'package:project/features/catalog/catalog.dart';
import 'package:project/features/common.dart';

PrintingController printingCtl() {
  PrintingBinding().dependencies();
  return Get.find<PrintingController>();
}

String _rejection(FileRejection r, PrintingConfig? cfg) => switch (r) {
      FileRejection.tooLarge => 'الملف أكبر من ${(cfg?.maxFileBytes ?? 10485760) ~/ 1048576} ميغابايت. اضغطه أو اختر ملفًا أصغر.',
      FileRejection.unsupportedType => 'نوع الملف غير مدعوم أو محتواه لا يطابق امتداده. افتحه وأعد حفظه بصيغة PDF أو صورة.',
      FileRejection.empty => 'الملف فارغ.',
    };

String _size(int b) => b >= 1048576 ? '${(b / 1048576).toStringAsFixed(1)} MB' : '${(b / 1024).toStringAsFixed(0)} KB';

String _ext(PrintJob j) {
  final m = j.serverMime ?? j.localMime;
  return m.contains('pdf') ? 'PDF' : (m.contains('png') ? 'PNG' : (m.contains('webp') ? 'WEBP' : 'JPG'));
}

// ---------------------------------------------------------------- landing

class PrintLandingScreen extends StatelessWidget {
  const PrintLandingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = printingCtl();
    return Obx(() {
      cartCtl.revision.value;
      final cfg = ctl.printing.value;
      if (ctl.configFailure.value != null && cfg == null) {
        return Page2(tab: 'print', top: const TopBar(title: 'الطباعة', back: false, right: CartBadgeButton()), center: true, body: EmptyState(ill: 'offline', title: 'تعذّر التحميل', text: failureText(ctl.configFailure.value!), cta: SBtn('أعد المحاولة', full: true, onTap: () => ctl.load(refresh: true))));
      }
      if (!ctl.configLoading.value && cfg == null && ctl.remoteConfig.value != null) {
        return Page2(tab: 'print', top: const TopBar(title: 'الطباعة', back: false), center: true, body: EmptyState(ill: 'tools', title: 'هذه الميزة غير متاحة الآن', text: 'تعطّلت مؤقتًا. يمكنك متابعة التسوق.', cta: SBtn('العودة للرئيسية', full: true, onTap: () => goTab('/home'))));
      }
      final jobs = cartCtl.printJobs;
      final maxMb = (cfg?.maxFileBytes ?? 10485760) ~/ 1048576;
      return Page2(
        tab: 'print',
        top: const TopBar(title: 'الطباعة', back: false, right: CartBadgeButton()),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          HeroBox(padding: const EdgeInsets.fromLTRB(14, 22, 14, 14), child: Column(children: [
            const Ill('print', width: 210),
            const SizedBox(height: 8),
            Text('اطبع ملفاتك بلا تعقيد', textAlign: TextAlign.center, style: T.d2(c.onHero)),
            const SizedBox(height: 2),
            Text('ارفع الملف، اختر المواصفات، وتابع السعر بشفافية.', textAlign: TextAlign.center, style: T.sm(c.onHero.withValues(alpha: .8))),
          ])),
          if (jobs.isNotEmpty) ...[
            const SizedBox(height: 24),
            Note('warn', icon: 'clock', onTap: () => Get.toNamed(cartCtl.hasInterruptedUploads ? '/print/upload' : '/print/specs'), child: Row(children: [
              Expanded(child: Text.rich(TextSpan(children: [const TextSpan(text: 'مسودة طباعة غير مكتملة\n', style: TextStyle(fontWeight: FontWeight.w700)), TextSpan(text: jobs.length == 1 ? 'ملف محفوظ على جهازك. تابع من حيث توقفت.' : '${jobs.length} ملفات محفوظة على جهازك. تابع من حيث توقفت.')]))),
              SIcon('chevL', size: 20, color: c.amberInk),
            ])),
          ],
          const SizedBox(height: 24),
          for (final s in const [('upload', 'ارفع', 'PDF أو صورة (JPG، PNG، WebP)'), ('sliders', 'اختر المواصفات', 'الورق، اللون، الوجهان، النسخ، التجليد'), ('bag', 'أضفها إلى السلة', 'مع منتجات أخرى إن أردت، ثم ادفع مرة واحدة')])
            LiTile(s.$1, s.$2, sub: s.$3, end: const SizedBox.shrink(), first: s.$1 == 'upload'),
          const SizedBox(height: 16),
          Text('حتى ${cfg?.maxJobs ?? 20} ملفًا · حتى $maxMb ميغابايت لكل ملف', textAlign: TextAlign.center, style: T.sm(c.tx2)),
        ]),
        foot: Foot(child: SBtn('اختر ملفات', icon: 'upload', full: true, disabled: cfg == null, onTap: () => Get.toNamed('/print/upload', arguments: {'pick': true}))),
      );
    });
  }
}

// ------------------------------------------------------------------ upload

class PrintUploadScreen extends StatefulWidget {
  const PrintUploadScreen({super.key});
  @override
  State<PrintUploadScreen> createState() => _PrintUploadScreenState();
}

class _PrintUploadScreenState extends State<PrintUploadScreen> {
  late final ctl = printingCtl();
  @override
  void initState() {
    super.initState();
    final a = Get.arguments;
    if (a is Map && a['pick'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ctl.load();
        ctl.pickFiles();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      cartCtl.revision.value;
      final cfg = ctl.printing.value;
      final jobs = cartCtl.printJobs.toList();
      final rej = ctl.rejected.toList();
      final ready = jobs.isNotEmpty && jobs.every((j) => j.isUploaded);
      final bad = jobs.where((j) => j.needsAttention).length + rej.length;
      return Page2(
        top: const TopBar(title: 'ملفات الطباعة'),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (cartCtl.hasInterruptedUploads) ...[const Note('warn', title: 'استعدنا مسودتك.', text: 'ملف لم يكتمل رفعه قبل إغلاق التطبيق. اختره من جديد ونحتفظ بمواصفاته.'), const SizedBox(height: 16)],
          if (bad > 0 && !cartCtl.hasInterruptedUploads) ...[Note('err', title: 'تعذّر رفع $bad ${bad == 1 ? 'ملف' : 'ملفات'}.', text: jobs.any((j) => j.isUploaded) ? 'الملف السليم جاهز، يمكنك المتابعة به أو إصلاح الباقي.' : 'استبدل الملف أو اختر ملفًا آخر.'), const SizedBox(height: 16)],
          if (ctl.limitReached.value) ...[Note('warn', text: 'وصلت إلى الحد الأقصى (${cfg?.maxJobs ?? 20} ملفًا).'), const SizedBox(height: 16)],
          DropZone(icon: 'upload', title: 'اضغط لاختيار ملفات', sub: 'PDF · JPG · PNG · WebP · حتى ${(cfg?.maxFileBytes ?? 10485760) ~/ 1048576} ميغابايت', onTap: ctl.picking.value ? null : ctl.pickFiles),
          const SizedBox(height: 16),
          for (final r in rej) ...[
            FileRow(name: r.name, ext: r.name.toLowerCase().endsWith('.pdf') ? 'PDF' : 'IMG', state: 'bad', error: _rejection(r.reason, cfg), actionLabel: 'استبدل', onAction: ctl.pickFiles),
            const SizedBox(height: 8),
          ],
          for (final j in jobs) ...[
            _jobRow(j),
            const SizedBox(height: 8),
          ],
        ]),
        foot: FootBar(child: SBtn(ready ? 'متابعة إلى المواصفات' : (jobs.isEmpty ? 'اختر ملفًا أولًا' : 'أكمل رفع الملفات أولًا'), full: true, disabled: !ready, onTap: () => Get.toNamed('/print/specs'))),
      );
    });
  }

  Widget _jobRow(PrintJob j) {
    switch (j.status) {
      case UploadStatus.uploaded:
        return FileRow(name: j.fileName, ext: _ext(j), meta: '${j.pages != null ? '${j.pages} صفحة · ' : ''}${_size(j.size)}', onRemove: () => cartCtl.removePrintJob(j.id));
      case UploadStatus.uploading:
        return FileRow(name: j.fileName, ext: _ext(j), state: 'up', progress: j.progress, meta: 'جارٍ الرفع ${(j.progress * 100).round()}٪ · ${_size(j.size)}', onCancel: () => cartCtl.removePrintJob(j.id));
      case UploadStatus.interrupted:
        return FileRow(name: j.fileName, ext: _ext(j), state: 'int', error: 'انقطع الرفع. اختر الملف مجددًا ونحتفظ بمواصفاتك.', actionLabel: 'اختر الملف', onAction: () => ctl.reselect(j.id));
      case UploadStatus.failed:
        final f = j.failure;
        final msg = f is NetworkFailure || f is TimeoutFailure ? 'تعذّر الرفع بسبب الاتصال.' : (f?.message ?? 'تعذّر رفع الملف.');
        return FileRow(name: j.fileName, ext: _ext(j), state: 'bad', error: msg, actionLabel: 'أعد الرفع', onAction: () => ctl.reselect(j.id));
    }
  }
}

// -------------------------------------------------------------------- specs

class PrintSpecsScreen extends StatefulWidget {
  const PrintSpecsScreen({super.key});
  @override
  State<PrintSpecsScreen> createState() => _PrintSpecsScreenState();
}

class _PrintSpecsScreenState extends State<PrintSpecsScreen> {
  late final ctl = printingCtl();
  String? selectedId;
  bool same = true;
  final range = TextEditingController();
  final notes = TextEditingController();
  String? boundJob;

  @override
  void initState() {
    super.initState();
    ctl.load();
  }

  @override
  void dispose() {
    range.dispose();
    notes.dispose();
    super.dispose();
  }

  void _apply(PrintJob job, PrintSpec Function(PrintSpec) f) {
    final targets = same ? cartCtl.printJobs.toList() : [job];
    for (final t in targets) {
      ctl.updateSpec(t.id, (s) => f(s));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Obx(() {
      cartCtl.revision.value;
      final cfg = ctl.printing.value;
      final jobs = cartCtl.printJobs.toList();
      if (jobs.isEmpty || cfg == null) {
        return Page2(top: const TopBar(title: 'مواصفات الطباعة'), center: true, body: EmptyState(ill: 'print', title: 'لا ملفات بعد', text: 'اختر ملفات للطباعة أولًا.', cta: SBtn('اختر ملفات', full: true, onTap: () => Get.offNamed('/print/upload', arguments: {'pick': true}))));
      }
      final job = jobs.firstWhereOrNull((j) => j.id == selectedId) ?? jobs.first;
      if (boundJob != job.id) {
        boundJob = job.id;
        // تعديل المتحكّم أثناء البناء يستدعي setState داخل البناء؛ نؤجله لما بعد الإطار.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          range.text = job.spec.pageRange;
          notes.text = job.spec.notes;
        });
      }
      final s = job.spec;
      final total = job.knownPages;
      final rangeErr = job.fieldErrors['print_page_range'] ?? (!PageRange.isValid(s.pageRange, totalPages: total) && s.pageRange.trim().isNotEmpty ? (total != null ? 'الملف $total صفحة فقط. صحّح النطاق أو اتركه فارغًا لطباعة الكل.' : 'صيغة النطاق غير صحيحة. مثال: 1-5, 8, 11-13') : null);
      final copiesErr = job.fieldErrors['print_copies'] ?? (s.copies > cfg.maxCopies ? 'الحد الأقصى ${cfg.maxCopies} نسخة.' : null);
      final anyBad = jobs.any((j) => !PageRange.isValid(j.spec.pageRange, totalPages: j.knownPages) || j.spec.copies > cfg.maxCopies);
      num est = 0;
      var unknown = false;
      for (final j in jobs) {
        final m = PrintEstimate.forJob(j, cfg);
        if (m == null) {
          unknown = true;
        } else {
          est += m.amount;
        }
      }
      Widget group(String t, Widget body) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(t, style: TextStyle(fontFamily: Fonts.ui, fontSize: 15, fontWeight: FontWeight.w600, color: c.tx)), const SizedBox(height: 8), body]);
      return Page2(
        top: const TopBar(title: 'مواصفات الطباعة'),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final j in jobs) ...[SChip(j.fileName, icon: 'file', on: j.id == job.id, onTap: () => setState(() => selectedId = j.id)), const SizedBox(width: 8)],
          ])),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text('تطبيق نفس المواصفات على كل الملفات', style: T.h3(c.tx, size: 15.5))), SSwitch(same, onChanged: (v) => setState(() => same = v))]),
          const SizedBox(height: 24),
          group('حجم الورق', GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: .82, children: [
            for (final p in cfg.paperSizes)
              OptTile(on: s.paperSize == p.key, label: p.label, onTap: () => _apply(job, (x) => x.copyWith(paperSize: p.key)), child: _paperGlyph(context, p.key, s.paperSize == p.key)),
          ])),
          const SizedBox(height: 24),
          group('اللون', Seg(items: [for (final k in cfg.colors) (k, k == 'color' ? 'ملوّن' : 'أبيض وأسود')], value: s.color, onChanged: (v) => _apply(job, (x) => x.copyWith(color: v)))),
          const SizedBox(height: 24),
          group('الطباعة على', Seg(items: [for (final k in cfg.sides) (k, k == 'double' ? 'وجهان' : 'وجه واحد')], value: s.sides, onChanged: (v) => _apply(job, (x) => x.copyWith(sides: v)))),
          const SizedBox(height: 24),
          group('عدد النسخ', Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Stepper2(value: s.copies, lg: true, onInc: () => _apply(job, (x) => x.copyWith(copies: (x.copies + 1).clamp(1, cfg.maxCopies))), onDec: () => _apply(job, (x) => x.copyWith(copies: (x.copies - 1).clamp(1, cfg.maxCopies))), maxed: s.copies >= cfg.maxCopies),
              Text('الحد الأقصى ${cfg.maxCopies}', style: T.sm(c.tx2)),
            ]),
            if (copiesErr != null) ...[const SizedBox(height: 8), FieldError(copiesErr)],
          ])),
          const SizedBox(height: 24),
          group('التجليد', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final b in cfg.bindings) ...[SChip(b.label, on: s.binding == b.key, onTap: () => _apply(job, (x) => x.copyWith(binding: b.key))), const SizedBox(width: 8)],
            ])),
            const SizedBox(height: 8),
            Text('يُحسب لكل نسخة.', style: T.sm(c.tx2).copyWith(fontSize: 13)),
          ])),
          const SizedBox(height: 24),
          Fld(label: 'نطاق الصفحات', hint: 'مثال: 1-5, 8, 11-13', controller: range, optional: true, ltr: true, error: rangeErr, helper: 'اتركه فارغًا لطباعة كل الصفحات.', onChanged: (v) => ctl.updateSpec(job.id, (x) => x.copyWith(pageRange: v))),
          const SizedBox(height: 24),
          Fld(label: 'ملاحظات خاصة بالطباعة', hint: 'مثال: طباعة بجودة عالية', controller: notes, optional: true, maxLines: 3, onChanged: (v) => ctl.updateSpec(job.id, (x) => x.copyWith(notes: v))),
          const SizedBox(height: 60),
        ]),
        foot: FootBar(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('تقدير الطباعة · غير نهائي', style: T.cap(c.tx2)), unknown && est == 0 ? Text('بعد رفع الملف', style: T.h3(c.tx)) : Mny(est, size: 26)]),
          SBtn(anyBad ? 'صحّح الحقول' : 'مراجعة الطباعة', disabled: anyBad, onTap: () => Get.toNamed('/print/review')),
        ])),
      );
    });
  }

  Widget _paperGlyph(BuildContext context, String key, bool on) {
    final c = context.sc;
    final (w, h) = switch (key) { 'A3' => (54.0, 76.0), 'A5' => (34.0, 48.0), _ => (44.0, 62.0) };
    return Container(width: w * .7, height: h * .7, decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(3), border: Border.all(color: on ? c.pri : c.ln, width: on ? 1.5 : 1)));
  }
}

// ------------------------------------------------------------------- review

class PrintReviewScreen extends StatelessWidget {
  const PrintReviewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final ctl = printingCtl();
    return Obx(() {
      cartCtl.revision.value;
      final cfg = ctl.printing.value;
      final jobs = cartCtl.printJobs.toList();
      num est = 0, bind = 0, pages = 0;
      for (final j in jobs) {
        final m = cfg == null ? null : PrintEstimate.forJob(j, cfg);
        est += m?.amount ?? 0;
        bind += (cfg?.binding(j.spec.binding)?.price.amount ?? 0) * j.spec.copies;
        pages += (PrintEstimate.selectedPages(j) ?? 0) * j.spec.copies;
      }
      return Page2(
        top: const TopBar(title: 'مراجعة الطباعة'),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final j in jobs) ...[
            Card2(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Container(width: 40, height: 48, decoration: BoxDecoration(color: c.hero, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Text(_ext(j), style: TextStyle(fontFamily: Fonts.ui, fontSize: 11, fontWeight: FontWeight.w700, color: c.onHero))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(j.fileName, textDirection: TextDirection.ltr, textAlign: TextAlign.start, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: Fonts.ui, fontWeight: FontWeight.w600, color: c.tx)), if (j.knownPages != null) Text('${j.knownPages} صفحة', style: T.sm(c.tx2).copyWith(fontSize: 13))])),
                SIconBtn('edit', size: 20, box: 40, onTap: () => Get.back()),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: [
                STag(cfg?.paper(j.spec.paperSize)?.label ?? j.spec.paperSize, kind: 'plum'),
                STag(j.spec.color == 'bw' ? 'أبيض وأسود' : 'ملوّن', kind: 'plum'),
                STag(j.spec.sides == 'double' ? 'وجهان' : 'وجه واحد', kind: 'plum'),
                STag('${j.spec.copies} نسخ', kind: 'plum'),
                STag(cfg?.binding(j.spec.binding)?.label ?? j.spec.binding, kind: 'plum'),
              ]),
            ])),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          PriceBox(rows: [('طباعة ($pages صفحة)', Mny(est - bind)), ('تجليد', Mny(bind))], totalMinor: est, totalLabel: 'التقدير'),
          const SizedBox(height: 16),
          const Note('plum', text: 'هذا تقدير. يظهر السعر المؤكد من الخادم قبل تأكيد الطلب، ولن تدفع قبل موافقتك على عرض المكتبة.'),
        ]),
        foot: FootBar(child: SBtn('أضف إلى السلة', icon: 'bag', full: true, onTap: () => Get.toNamed('/cart'))),
      );
    });
  }
}
