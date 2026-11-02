import 'dart:async';
import 'dart:math' as math;

import 'package:dartz/dartz.dart' hide State;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/core/config/ai_config.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/illustrations.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/network/api_client.dart';
import 'package:project/core/services/audio_recorder_service.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/catalog_remote_datasource.dart';
import 'package:project/customer/features/ai_assistant/data/datasources/gemini_extractor.dart';
import 'package:project/customer/features/ai_assistant/data/matching/product_matcher.dart';
import 'package:project/customer/features/ai_assistant/data/matching/request_parser.dart';
import 'package:project/customer/features/ai_assistant/data/repositories/ai_assistant_repository_impl.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/assistant_result.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/audio_clip.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';
import 'package:project/customer/features/ai_assistant/domain/failures/ai_failures.dart';
import 'package:project/customer/features/ai_assistant/domain/repositories/ai_assistant_repository.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/features/common.dart';

enum Phase { idle, recording, analyzing, results, error }

/// متحكم المساعد: منطق الفريق (Gemini + مطابقة الكتالوج الحي) مع سلة موحّدة.
/// لا يُضاف شيء للسلة قبل تأكيد صريح، ولا يُنشأ طلب من المساعد أبدًا.
class AssistantController extends GetxController {
  late final AiAssistantRepository _repo;
  final _recorder = AudioRecorderService();

  final text = TextEditingController();
  final phase = Phase.idle.obs;
  final elapsed = 0.obs;
  final level = 0.0.obs;
  final items = <SuggestionItem>[].obs;
  final selected = <int>{}.obs; // فهارس العناصر المحددة
  final transcript = ''.obs;
  final errorText = RxnString();
  final micDenied = false.obs;
  AudioClip? _clip;
  String _lastText = '';
  Timer? _tick;
  StreamSubscription<double>? _lv;
  int _seq = 0;

  static const maxSeconds = 60;

  @override
  void onInit() {
    super.onInit();
    final geminiDio = Dio(BaseOptions(baseUrl: AiConfig.geminiBaseUrl, connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 40), headers: {'Content-Type': 'application/json', 'x-goog-api-key': AiConfig.geminiApiKey}));
    _repo = AiAssistantRepositoryImpl(CatalogRemoteDataSourceImpl(Get.find<ApiClient>().dio), GeminiRestExtractor(geminiDio), const RequestParser(), const ProductMatcher());
    final a = Get.arguments;
    if (a is Map && a['listen'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => startRecording());
    }
  }

  void reset() {
    _seq++;
    text.clear();
    items.clear();
    selected.clear();
    transcript.value = '';
    errorText.value = null;
    phase.value = Phase.idle;
  }

  Future<void> startRecording() async {
    if (phase.value != Phase.idle && phase.value != Phase.error) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final granted = await _recorder.requestPermission();
    if (!granted) {
      micDenied.value = true;
      return;
    }
    micDenied.value = false;
    try {
      await _recorder.start();
    } catch (_) {
      showToast('تعذّر تشغيل الميكروفون', icon: 'alertC');
      return;
    }
    elapsed.value = 0;
    phase.value = Phase.recording;
    _lv = _recorder.levels.listen((v) => level.value = v);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed.value++;
      if (elapsed.value >= maxSeconds) stopAndSend();
    });
  }

  void _stopTimers() {
    _tick?.cancel();
    _lv?.cancel();
    level.value = 0;
  }

  Future<void> cancelRecording() async {
    if (phase.value != Phase.recording) return;
    _stopTimers();
    await _recorder.cancel();
    phase.value = Phase.idle;
  }

  Future<void> stopAndSend() async {
    if (phase.value != Phase.recording) return;
    _stopTimers();
    final audio = await _recorder.stop();
    if (audio == null || audio.duration < const Duration(seconds: 1)) {
      phase.value = Phase.idle;
      showToast('التسجيل قصير جدًا. حاول مجددًا.', icon: 'alertC');
      return;
    }
    _clip = AudioClip(bytes: audio.wavBytes, mimeType: 'audio/wav');
    _lastText = '';
    transcript.value = '';
    await _run(() => _repo.suggestFromAudio(_clip!));
  }

  Future<void> sendText([String? quick]) async {
    final t = (quick ?? text.text).trim();
    if (t.isEmpty) {
      showToast('اكتب طلبك أولًا', icon: 'alertC');
      return;
    }
    if (phase.value != Phase.idle && phase.value != Phase.error) return;
    FocusManager.instance.primaryFocus?.unfocus();
    _clip = null;
    _lastText = t;
    transcript.value = t;
    text.clear();
    await _run(() => _repo.suggestFromText(t));
  }

  Future<void> retry() async {
    if (_clip != null) {
      await _run(() => _repo.suggestFromAudio(_clip!));
    } else if (_lastText.isNotEmpty) {
      await _run(() => _repo.suggestFromText(_lastText));
    } else {
      reset();
    }
  }

  Future<void> _run(Future<Either<Failure, AssistantResult>> Function() f) async {
    final seq = ++_seq;
    errorText.value = null;
    phase.value = Phase.analyzing;
    final r = await f();
    if (seq != _seq) return; // أُلغي
    r.fold((fail) {
      errorText.value = fail is AiUnavailableFailure ? 'خدمة المساعد غير متاحة الآن.' : (fail is AiQuotaFailure ? 'المساعد مشغول الآن. حاول بعد قليل.' : failureText(fail));
      phase.value = Phase.error;
    }, (res) {
      if (res.unclear || res.items.isEmpty) {
        errorText.value = 'لم أفهم الطلب. جرّب صياغة أخرى.';
        phase.value = Phase.error;
        return;
      }
      if (res.transcript.isNotEmpty) transcript.value = res.transcript;
      items.assignAll(res.items);
      selected
        ..clear()
        ..addAll([for (var i = 0; i < res.items.length; i++) if (res.items[i].isIncluded) i]);
      phase.value = Phase.results;
    });
  }

  void cancelAnalyzing() {
    _seq++;
    phase.value = Phase.idle;
  }

  void toggle(int i) {
    if (!items[i].isSelectable) return;
    selected.contains(i) ? selected.remove(i) : selected.add(i);
    selected.refresh();
  }

  void setQty(int i, int q) {
    items[i] = items[i].withQuantity(q);
    if (items[i].quantity == 0) selected.remove(i);
  }

  void substitute(int i, SuggestedProduct alt) {
    items[i] = items[i].substitutedWith(alt);
    if (items[i].isIncluded) selected.add(i);
  }

  List<SuggestionItem> get chosen => [for (final i in selected) if (i < items.length && items[i].isIncluded) items[i]];
  List<SuggestionItem> get missing => items.where((i) => i.status == SuggestionStatus.notFound).toList();
  num get total => chosen.fold<num>(0, (s, i) => s + i.product!.priceAmount * i.quantity);

  /// إضافة صريحة بعد التأكيد: عقد السلة (id + كمية + مفاتيح خيارات) بلا أسعار.
  void addChosenToCart() {
    for (final it in chosen) {
      final p = it.product!;
      cartCtl.addProduct(CartItemRequest(productId: p.id, quantity: it.quantity, options: {for (final e in p.selectedOptions.entries) e.key: [e.value]}), maxQty: p.maxQuantity == 0 ? 99 : p.maxQuantity);
    }
  }

  void sendMissingAsRequest() {
    for (final m in missing) {
      cartCtl.addShoppingRequest(m.requestedQty > 1 ? '${m.requestText} × ${m.requestedQty}' : m.requestText);
    }
  }

  @override
  void onClose() {
    _stopTimers();
    _recorder.dispose();
    text.dispose();
    super.onClose();
  }
}

class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctl = Get.put(AssistantController());
    return Obx(() {
      final ph = ctl.phase.value;
      return Page2(
        tab: 'ai',
        top: TopBar(title: 'مساعد سطر', back: false, right: SIconBtn('refresh', onTap: ctl.reset)),
        body: switch (ph) {
          Phase.idle => _idle(context, ctl),
          Phase.recording => _recording(context, ctl),
          Phase.analyzing => _analyzing(context, ctl),
          Phase.results => _results(context, ctl),
          Phase.error => _error(context, ctl),
        },
        foot: switch (ph) {
          Phase.idle => _inputBar(context, ctl),
          Phase.recording => Foot(child: _recFoot(context, ctl)),
          Phase.results => FootBar(child: SBtn('أضف المحدد إلى السلة · ${(ctl.total / 100).toStringAsFixed(2)} ₪', full: true, disabled: ctl.chosen.isEmpty, onTap: () => _confirm(context, ctl))),
          _ => null,
        },
      );
    });
  }

  Widget _idle(BuildContext context, AssistantController ctl) {
    final c = context.sc;
    return Column(children: [
      if (!AiConfig.hasGeminiKey) ...[const Note('warn', text: 'الصوت وفهم الجمل المعقّدة يحتاجان مفتاح خدمة الذكاء الاصطناعي. الكتابة تعمل بالمطابقة المحلية على الكتالوج.'), const SizedBox(height: 16)],
      if (ctl.micDenied.value) ...[Note('warn', icon: 'mic', title: 'الميكروفون غير مسموح.', text: 'يمكنك الكتابة بدلًا من الكلام، أو تفعيل الإذن من الإعدادات.', action: 'فتح الإعدادات', onActionTap: openAppSettings), const SizedBox(height: 16)],
      const SizedBox(height: 8),
      const Ill('assist', width: 190),
      const SizedBox(height: 24),
      Text('ماذا تحتاج اليوم؟', style: T.d2(c.tx)),
      const SizedBox(height: 8),
      Text('اكتب أو تحدّث بكلامك، مثل:', style: T.bd(c.tx2)),
      const SizedBox(height: 24),
      for (final t in const ['دفترين مسطرين وعلبة أقلام زرقاء', 'هدية لطفل عمره 7 سنوات', 'أحتاج مفكرة وقلم رصاص']) ...[
        Align(alignment: AlignmentDirectional.centerStart, child: GestureDetector(
          onTap: () => ctl.sendText(t),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [SIcon('sparkles', size: 16, color: c.tx), const SizedBox(width: 6), Flexible(child: Text(t, style: TextStyle(fontFamily: Fonts.ui, fontSize: 14.5, fontWeight: FontWeight.w500, color: c.tx)))]),
          ),
        )),
        const SizedBox(height: 8),
      ],
    ]);
  }

  Widget _inputBar(BuildContext context, AssistantController ctl) {
    final c = context.sc;
    return FootBar(
      child: Row(children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(999)),
            child: TextField(controller: ctl.text, textInputAction: TextInputAction.send, onSubmitted: (_) => ctl.sendText(), cursorColor: c.pri, style: TextStyle(fontFamily: Fonts.ui, fontSize: 16, color: c.tx), decoration: InputDecoration(border: InputBorder.none, hintText: 'اكتب طلبك هنا…', hintStyle: TextStyle(fontFamily: Fonts.ui, color: c.tx3))),
          ),
        ),
        const SizedBox(width: 10),
        SIconBtn('mic', box: 52, bg: c.hero, fg: c.onHero, onTap: ctl.startRecording),
        const SizedBox(width: 10),
        SIconBtn('send', box: 52, size: 22, bg: c.pri, fg: c.onPri, onTap: () => ctl.sendText()),
      ]),
    );
  }

  Widget _recording(BuildContext context, AssistantController ctl) {
    final c = context.sc;
    final m = ctl.elapsed.value ~/ 60, s = ctl.elapsed.value % 60;
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: c.errSoft, borderRadius: BorderRadius.circular(999)), child: Text('● يسجّل · ${two(m)}:${two(s)}', style: TextStyle(fontFamily: Fonts.ui, fontSize: 13, fontWeight: FontWeight.w600, color: c.errInk))),
        const SizedBox(height: 24),
        _Wave(ctl.level.value),
        const SizedBox(height: 24),
        Text('تحدّث الآن بما تحتاجه', textAlign: TextAlign.center, style: T.d2(c.tx, size: 24, height: 1.6)),
        const SizedBox(height: 8),
        Text('سيتحوّل كلامك إلى طلب تراجعه قبل أي إضافة للسلة.', textAlign: TextAlign.center, style: T.sm(c.tx2)),
      ]),
    );
  }

  Widget _recFoot(BuildContext context, AssistantController ctl) {
    final c = context.sc;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SIconBtn('x', box: 60, size: 26, tonal: true, onTap: ctl.cancelRecording),
      const SizedBox(width: 28),
      GestureDetector(
        onTap: ctl.stopAndSend,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(color: c.pri, shape: BoxShape.circle, boxShadow: [BoxShadow(color: c.pri.withValues(alpha: .12), spreadRadius: 10), BoxShadow(color: c.pri.withValues(alpha: .06), spreadRadius: 22)]),
          child: Center(child: SIcon('check', size: 34, color: c.onPri, filled: true)),
        ),
      ),
      const SizedBox(width: 28),
      const SizedBox(width: 60),
    ]);
  }

  Widget _bubbleUser(BuildContext context, String t) {
    final c = context.sc;
    return Align(alignment: AlignmentDirectional.centerStart, child: Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: c.pri, borderRadius: const BorderRadiusDirectional.only(topStart: Radius.circular(18), topEnd: Radius.circular(18), bottomEnd: Radius.circular(18), bottomStart: Radius.circular(6))),
      child: Text(t, style: TextStyle(fontFamily: Fonts.ui, fontSize: 15.5, height: 1.65, color: c.onPri)),
    ));
  }

  Widget _bubbleAssistant(BuildContext context, Widget child) {
    final c = context.sc;
    return Align(alignment: AlignmentDirectional.centerEnd, child: Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .85),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: c.sf2, borderRadius: const BorderRadiusDirectional.only(topStart: Radius.circular(18), topEnd: Radius.circular(18), bottomStart: Radius.circular(18), bottomEnd: Radius.circular(6))),
      child: DefaultTextStyle(style: TextStyle(fontFamily: Fonts.ui, fontSize: 15, height: 1.65, color: c.tx), child: child),
    ));
  }

  Widget _analyzing(BuildContext context, AssistantController ctl) {
    final c = context.sc;
    return Padding(padding: const EdgeInsets.only(top: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _bubbleUser(context, ctl.transcript.value.isEmpty ? 'رسالة صوتية' : ctl.transcript.value),
      const SizedBox(height: 16),
      _bubbleAssistant(context, Row(mainAxisSize: MainAxisSize.min, children: [SIcon('sparkles', size: 18, color: c.amber), const SizedBox(width: 10), const Text('أبحث في الكتالوج…')])),
      for (var i = 0; i < 2; i++) ...[const SizedBox(height: 16), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(Rad.m), border: Border.all(color: c.ln)), child: const Row(children: [Skel(w: 56, h: 56, r: 12), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Skel(h: 14), SizedBox(height: 8), Skel(w: 100, h: 12)]))]))],
      const SizedBox(height: 16),
      Center(child: SBtn('إلغاء', kind: BtnKind.ghost, size: BtnSize.sm, onTap: ctl.cancelAnalyzing)),
    ]));
  }

  Widget _error(BuildContext context, AssistantController ctl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (ctl.transcript.value.isNotEmpty) _bubbleUser(context, ctl.transcript.value),
      EmptyState(ill: 'offline', title: 'تعذّر فهم الطلب الآن', text: '${ctl.errorText.value ?? 'حدث خلل في الاتصال بالمساعد.'} طلبك محفوظ.', cta: Column(children: [SBtn('أعد المحاولة', icon: 'refresh', full: true, onTap: ctl.retry), const SizedBox(height: 8), SBtn('تصفّح يدويًا', kind: BtnKind.sec, full: true, onTap: () => Get.toNamed('/products', arguments: {'title': 'المنتجات'})), const SizedBox(height: 8), SBtn('ابدأ من جديد', kind: BtnKind.ghost, full: true, onTap: ctl.reset)])),
    ]);
  }

  Widget _results(BuildContext context, AssistantController ctl) {
    final c = context.sc;
    final found = ctl.items.where((i) => i.product != null).length;
    final missing = ctl.missing;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _bubbleUser(context, ctl.transcript.value),
      const SizedBox(height: 16),
      _bubbleAssistant(context, found == 0 ? const Text('لم أجد في الكتالوج ما يطابق طلبك.') : Text.rich(TextSpan(children: [const TextSpan(text: 'وجدت '), TextSpan(text: '$found ${found == 1 ? 'منتجًا' : 'منتجات'}', style: const TextStyle(fontWeight: FontWeight.w700)), const TextSpan(text: ' تطابق طلبك. راجعها قبل إضافتها إلى السلة.')]))),
      for (var i = 0; i < ctl.items.length; i++)
        if (ctl.items[i].product != null) ...[const SizedBox(height: 16), _SugRow(ctl, i)],
      if (missing.isNotEmpty) ...[
        const SizedBox(height: 16),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [SIcon('alertC', size: 20, color: c.tx), const SizedBox(width: 10), Expanded(child: Text('لم نجد: ${missing.map((m) => m.requestText).join('، ')}', style: T.h3(c.tx, size: 15.5)))]),
          const SizedBox(height: 8),
          Text('يمكنك إرسالها كطلب نصي، وتبحث عنها المكتبة وتعرض لك السعر للموافقة.', style: T.sm(c.tx2)),
          const SizedBox(height: 12),
          SBtn('أرسلها كطلب للمكتبة', kind: BtnKind.sec, size: BtnSize.sm, icon: 'send', onTap: () {
            ctl.sendMissingAsRequest();
            showToast('أُضيف الطلب النصي إلى السلة', actionLabel: 'عرض', onAction: () => Get.toNamed('/cart'));
          }),
        ])),
      ],
      if (ctl.items.any((i) => i.status == SuggestionStatus.printJob)) ...[const SizedBox(height: 16), Note('plum', icon: 'printer', text: 'ذكرت طباعة. افتح الطباعة لرفع ملفك واختيار المواصفات.', action: 'فتح الطباعة', onActionTap: () => goTab('/print'))],
      const SizedBox(height: 16),
      const Note('plum', text: 'لن يُرسل أي طلب. تُضاف الاختيارات إلى السلة وتراجعها أولًا.'),
    ]);
  }

  void _confirm(BuildContext context, AssistantController ctl) {
    final c = context.sc;
    showSheet(context, title: 'أضف إلى السلة؟', body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var i = 0; i < ctl.chosen.length; i++) ...[
        if (i > 0) const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider2()),
        Row(children: [
          ProdThumb(imageUrl: ctl.chosen[i].product!.imageUrl, name: ctl.chosen[i].product!.name, seed: ctl.chosen[i].product!.id),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(ctl.chosen[i].product!.name, style: T.h3(c.tx, size: 15).copyWith(height: 1.45)), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Num('× ${ctl.chosen[i].quantity}', style: T.sm(c.tx2)), Mny(ctl.chosen[i].product!.priceAmount * ctl.chosen[i].quantity)])])),
        ]),
      ],
      const SizedBox(height: 12),
      Text('لن يُنشأ أي طلب الآن. تراجع السلة أولًا.', style: T.sm(c.tx2)),
    ]), foot: [
      SBtn('أضف وراجع السلة', full: true, onTap: () {
        ctl.addChosenToCart();
        Get.back();
        ctl.reset();
        Get.toNamed('/cart');
      }),
      SBtn('رجوع للتعديل', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
    ]);
  }
}

class _SugRow extends StatelessWidget {
  const _SugRow(this.ctl, this.i);
  final AssistantController ctl;
  final int i;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final it = ctl.items[i];
    final p = it.product!;
    final on = ctl.selected.contains(i);
    final clear = it.status == SuggestionStatus.available;
    final tag = switch (it.status) {
      SuggestionStatus.available => ('مطابقة واضحة', 'plum'),
      SuggestionStatus.limited => ('تحقّق: المتوفر ${it.maxQuantity}', 'soft'),
      SuggestionStatus.outOfStock => ('غير متوفر', 'err'),
      _ => ('تحقّق: هل تقصد؟', 'soft'),
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(Rad.m), border: Border.all(color: c.ln)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Opacity(opacity: it.isSelectable ? 1 : .3, child: SCheck(on, onTap: () => ctl.toggle(i))),
          const SizedBox(width: 12),
          ProdThumb(imageUrl: p.imageUrl, name: p.name, seed: p.id, size: 56),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: T.h3(c.tx, size: 14.5).copyWith(height: 1.4)),
            const SizedBox(height: 2),
            Row(children: [STag(tag.$1, kind: tag.$2), const SizedBox(width: 6), Mny(p.priceAmount)]),
          ])),
        ]),
        if (it.isSelectable) ...[
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(clear ? 'الكمية' : 'الكمية المقترحة', style: T.sm(c.tx2)),
            Stepper2(value: it.quantity, min: 1, maxed: it.quantity >= it.maxQuantity, onInc: () => ctl.setQty(i, it.quantity + 1), onDec: () => ctl.setQty(i, it.quantity - 1)),
          ]),
        ],
        if (it.alternatives.isNotEmpty && (it.status == SuggestionStatus.outOfStock || !clear)) ...[
          const SizedBox(height: 10),
          Text('بدائل:', style: T.sm(c.tx2)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final a in it.alternatives.take(3)) SChip(a.name, onTap: () => ctl.substitute(i, a))]),
        ],
      ]),
    );
  }
}

class _Wave extends StatefulWidget {
  const _Wave(this.level);
  final double level;
  @override
  State<_Wave> createState() => _WaveState();
}

class _WaveState extends State<_Wave> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final col = context.sc.pri;
    return SizedBox(
      height: 48,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          for (var i = 0; i < 21; i++)
            Container(
              width: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 10 + 32 * math.max(.15, widget.level) * (0.5 + 0.5 * math.sin((_c.value * 2 * math.pi) + (i % 7) * .9)).abs(),
              decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(3)),
            ),
        ]),
      ),
    );
  }
}
