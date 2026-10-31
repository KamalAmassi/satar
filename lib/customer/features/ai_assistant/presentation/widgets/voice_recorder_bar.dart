import 'package:flutter/material.dart';
import 'package:project/core/animations/app_motion.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

class VoiceRecorderBar extends StatelessWidget {
  const VoiceRecorderBar({
    super.key,
    required this.isRecording,
    required this.enabled,
    required this.elapsedSeconds,
    required this.level,
    required this.idleLabel,
    required this.recordingLabel,
    required this.stopTooltip,
    required this.cancelTooltip,
    required this.onToggle,
    required this.onCancel,
  });

  final bool isRecording;
  final bool enabled;
  final int elapsedSeconds;
  final double level;
  final String idleLabel;
  final String recordingLabel;
  final String stopTooltip;
  final String cancelTooltip;
  final VoidCallback onToggle;
  final VoidCallback onCancel;

  static String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: AppMotion.fast,
      opacity: enabled ? 1 : 0.5,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.emphasized,
        height: 64,
        decoration: BoxDecoration(
          color: isRecording ? AppColors.primary : AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: isRecording ? AppColors.primary : AppColors.border,
          ),
        ),
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          child: isRecording ? _buildRecording() : _buildIdle(),
        ),
      ),
    );
  }

  Widget _buildIdle() {
    return Material(
      key: const ValueKey('idle'),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: enabled ? onToggle : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mic_none_rounded,
                color: AppColors.primary, size: AppSizes.iconMd),
            const SizedBox(width: AppSizes.sm),
            Text(
              idleLabel,
              style: const TextStyle(color: AppColors.primary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecording() {
    return Padding(
      key: const ValueKey('recording'),
      padding: const EdgeInsetsDirectional.only(
        start: AppSizes.md,
        end: AppSizes.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 120),
                  scale: 1 + level * 0.7,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.sand.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Icon(Icons.mic_rounded,
                    color: AppColors.sand, size: AppSizes.iconMd),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _format(elapsedSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  recordingLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: cancelTooltip,
            onPressed: onCancel,
            icon: Icon(Icons.close_rounded,
                color: Colors.white.withValues(alpha: 0.85)),
          ),
          Tooltip(
            message: stopTooltip,
            child: Material(
              color: AppColors.sand,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onToggle,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.stop_rounded, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}