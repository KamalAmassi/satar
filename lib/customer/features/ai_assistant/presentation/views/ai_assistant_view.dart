import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project/core/animations/app_motion.dart';
import 'package:project/core/animations/entrance.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/core/widgets/app_loading.dart';
import 'package:project/core/widgets/cart_badge_button.dart';
import 'package:project/customer/features/ai_assistant/presentation/controllers/ai_assistant_controller.dart';
import 'package:project/customer/features/ai_assistant/presentation/widgets/voice_recorder_bar.dart';

class AiAssistantView extends GetView<AiAssistantController> {
  const AiAssistantView({super.key});

  static const _hPad = 20.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    final quickChips = [
      'دفاتر مدرسية مع أقلام',
      'أدوات رسم وتلوين',
      'هدية عيد ميلاد لطفل',
      'طباعة أوراق بحث A4',
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Column(
              children: [
                // Header
                Entrance(
                  offset: const Offset(0, -12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _hPad,
                      AppSizes.md,
                      _hPad,
                      AppSizes.sm,
                    ),
                    child: SizedBox(
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            l10n.aiTitle,
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: _RoundBackButton(onPressed: () => Get.back()),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Obx(
                                  () => CartBadgeButton(
                                count: controller.cartCount.value,
                                onPressed: () =>
                                    Get.toNamed(CustomerRoutes.cart),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Chat Messages Feed
                Expanded(
                  child: Obx(() {
                    final msgs = controller.messages;
                    return ListView(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        _hPad,
                        AppSizes.sm,
                        _hPad,
                        AppSizes.xl,
                      ),
                      children: [
                        if (msgs.isEmpty) ...[
                          const SizedBox(height: AppSizes.xl),
                          const Center(child: _HeroIcon()),
                          const SizedBox(height: AppSizes.lg),
                          Text(
                            l10n.aiHeroTitle,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                            child: Text(
                              l10n.aiHeroSubtitle,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.xl),
                          // Quick Suggestion Chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: quickChips.map((chip) {
                              return ActionChip(
                                label: Text(chip),
                                onPressed: () => controller.submitText(quickText: chip),
                                backgroundColor: AppColors.surface,
                                labelStyle: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                side: BorderSide(
                                  color: AppColors.secondary.withValues(alpha: 0.4),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        for (final msg in msgs) ...[
                          const SizedBox(height: AppSizes.md),
                          _buildBubble(context, msg),
                        ],
                      ],
                    );
                  }),
                ),

                // Bottom Input & Recorder Bar
                Container(
                  padding: const EdgeInsets.all(_hPad),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Recorder Bar or Text Input
                      Obx(() {
                        if (controller.isRecording) {
                          return VoiceRecorderBar(
                            isRecording: true,
                            enabled: true,
                            elapsedSeconds: controller.elapsed.value,
                            level: controller.level.value,
                            idleLabel: l10n.aiVoiceStart,
                            recordingLabel: l10n.aiVoiceListening,
                            stopTooltip: l10n.aiStop,
                            cancelTooltip: l10n.aiCancel,
                            onToggle: controller.toggleRecording,
                            onCancel: controller.cancelRecording,
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.textController,
                                minLines: 1,
                                maxLines: 4,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => controller.submitText(),
                                decoration: InputDecoration(
                                  hintText: l10n.aiInputHint,
                                  hintStyle: const TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 14,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            // Send or Mic button
                            ValueListenableBuilder(
                              valueListenable: controller.textController,
                              builder: (context, value, _) {
                                final hasText = value.text.trim().isNotEmpty;
                                return IconButton.filled(
                                  onPressed: controller.isAnalyzing
                                      ? null
                                      : () {
                                    if (hasText) {
                                      controller.submitText();
                                    } else {
                                      controller.toggleRecording();
                                    }
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(48, 48),
                                  ),
                                  icon: Icon(
                                    hasText ? Icons.send_rounded : Icons.mic_rounded,
                                    size: 22,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context, ChatMessage msg) {
    switch (msg.type) {
      case ChatMessageType.userText:
        return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              msg.text ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        );

      case ChatMessageType.userAudio:
        return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mic, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'تسجيل صوتي (${msg.audioDuration?.inSeconds ?? 0} ثانية)',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        );

      case ChatMessageType.assistantThinking:
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Obx(() {
              final step = controller.analyzingStep.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLoading(size: 18),
                      const SizedBox(width: 12),
                      Text(
                        'جاري معالجة الطلب...',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStepRow(0, step, context.l10n.aiStepListening),
                  const SizedBox(height: 6),
                  _buildStepRow(1, step, context.l10n.aiStepUnderstanding),
                  const SizedBox(height: 6),
                  _buildStepRow(2, step, context.l10n.aiStepSearching),
                ],
              );
            }),
          ),
        );

      case ChatMessageType.assistantResult:
        final count = msg.items?.where((i) => i.isIncluded).length ?? 0;
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.85,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'لقيت لك $count منتجات مقترحة!',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  controller.transcript.value,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: context.l10n.aiSheetTitle,
                  onPressed: () => controller.retry(), // Or re-open sheet
                ),
              ],
            ),
          ),
        );

      case ChatMessageType.assistantError:
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        msg.errorMessage ?? context.l10n.errorGeneral,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: controller.retry,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(context.l10n.aiRetry),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildStepRow(int stepIndex, int currentStep, String label) {
    final isDone = currentStep > stepIndex;
    final isCurrent = currentStep == stepIndex;

    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: isDone
              ? const Icon(Icons.check_circle, color: AppColors.success, size: 18)
              : isCurrent
              ? const AppLoading(size: 14)
              : const Icon(Icons.radio_button_unchecked, color: AppColors.textHint, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDone || isCurrent ? AppColors.textPrimary : AppColors.textHint,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: const Icon(Icons.auto_awesome, color: AppColors.sand, size: 34),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_back_rounded, color: AppColors.primary),
        ),
      ),
    );
  }
}
