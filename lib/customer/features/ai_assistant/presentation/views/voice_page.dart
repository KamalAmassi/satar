import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/utils/haptics.dart';
import 'package:project/customer/features/ai_assistant/presentation/controllers/voice_controller.dart';
import 'package:project/customer/features/ai_assistant/presentation/widgets/voice/found_items_row.dart';
import 'package:project/customer/features/ai_assistant/presentation/widgets/voice/pen_orb.dart';
import 'package:project/customer/features/ai_assistant/presentation/widgets/voice/voice_summary_sheet.dart';

/// صفحة المحادثة الصوتية بلا لمس. صفحة جديدة منفصلة عن المساعد النصي.
class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  late final VoiceController ctl = Get.find<VoiceController>();
  Worker? _finishWorker;

  @override
  void initState() {
    super.initState();
    _finishWorker = ever<int>(ctl.finishTick, (_) => _review());
    WidgetsBinding.instance.addPostFrameCallback((_) => ctl.start());
  }

  Future<void> _review() async {
    if (!mounted) return;
    final added = await showVoiceSummarySheet(context, ctl);
    if (!mounted) return;
    if (added == true) {
      Haptics.success();
      showToast(AppLocalizations.of(context)!.voiceAddedToCart);
      Get.back<void>();
    } else {
      ctl.resume();
    }
  }

  @override
  void dispose() {
    _finishWorker?.dispose();
    super.dispose();
  }

  String _label(AppLocalizations l, VoiceState s) => switch (s) {
        VoiceState.listening => l.listeningState,
        VoiceState.thinking => l.thinkingState,
        VoiceState.speaking => l.speakingState,
        VoiceState.error => l.voiceNetworkMessage,
        VoiceState.idle => ctl.paused.value ? l.voiceTapToResume : '',
      };

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Obx(() {
          if (ctl.unsupported.value) return _Notice(text: l.voiceUnsupported, onBack: Get.back<void>);
          if (ctl.micDenied.value) {
            return _Notice(text: l.voiceMicDenied, action: l.voiceOpenSettings, onAction: openAppSettings, onBack: Get.back<void>);
          }
          final s = ctl.state.value;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(children: [
                SIconBtn('x', onTap: Get.back<void>),
                Expanded(child: Text(l.voiceModeTitle, textAlign: TextAlign.center, style: T.h3(c.tx))),
                const SizedBox(width: 48),
              ]),
            ),
            if (ctl.arabicVoiceMissing.value)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l.voiceArabicVoiceMissing, textAlign: TextAlign.center, style: T.cap(c.coralInk)),
              ),
            Expanded(
              child: VoiceStage(
                state: s,
                micLevel: () => ctl.micLevel,
                speaking: () => ctl.speakingNow,
                semanticLabel: _label(l, s).isEmpty ? l.voiceModeTitle : _label(l, s),
                onTap: ctl.onPenTap,
              ),
            ),
            Text(_label(l, s), style: T.h3(c.tx)),
            const SizedBox(height: 6),
            _Captions(user: ctl.userCaption.value, assistant: ctl.assistantCaption.value),
            const SizedBox(height: 10),
            FoundItemsRow(items: ctl.foundItems.toList(), onAdd: ctl.proposeManual),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(children: [
                SIconBtn(ctl.paused.value ? 'mic' : 'x', onTap: ctl.toggleMic, box: 64, size: 28, tonal: !ctl.paused.value),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(clipBehavior: Clip.none, children: [
                    SBtn(l.finishVoiceSession, full: true, onTap: ctl.finish),
                    if (ctl.proposals.isNotEmpty)
                      PositionedDirectional(
                        top: -8,
                        end: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: c.coralTag, borderRadius: BorderRadius.circular(Rad.l)),
                          child: Semantics(label: l.voiceProposedCount(ctl.proposals.length), child: Text('${ctl.proposals.length}', style: T.cap(c.onPri))),
                        ),
                      ),
                  ]),
                ),
              ]),
            ),
          ]);
        }),
      ),
    );
  }
}

class _Captions extends StatelessWidget {
  const _Captions({required this.user, required this.assistant});
  final String user;
  final String assistant;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Column(key: ValueKey('$user|$assistant'), children: [
          if (user.isNotEmpty) Text(user, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: T.sm(c.tx2)),
          if (assistant.isNotEmpty) Text(assistant, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: T.sm(c.tx)),
        ]),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, required this.onBack, this.action, this.onAction});
  final String text;
  final String? action;
  final VoidCallback? onAction;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(text, textAlign: TextAlign.center, style: T.h3(c.tx)),
          const SizedBox(height: 20),
          if (action != null) ...[SBtn(action!, full: true, onTap: onAction), const SizedBox(height: 8)],
          SBtn(l.voiceBackToText, full: true, kind: BtnKind.ghost, onTap: onBack),
        ]),
      ),
    );
  }
}
