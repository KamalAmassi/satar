import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/animations/app_motion.dart';
import 'package:project/core/animations/entrance.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/customer/features/ai_assistant/presentation/controllers/ai_assistant_controller.dart';
import 'package:project/customer/features/ai_assistant/presentation/widgets/suggestion_tile.dart';

class SuggestionsSheet extends GetView<AiAssistantController> {
  const SuggestionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.cream,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.xl,
                AppSizes.lg,
                AppSizes.xl,
                AppSizes.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.aiSheetTitle,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Obx(
                            () => _CountChip(
                          label: l10n.aiItemsCount(controller.items.length),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.aiSheetSubtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Obx(() {
                    final text = controller.transcript.value;
                    if (text.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSizes.md),
                      child: _TranscriptCard(
                        title: l10n.aiUnderstood,
                        transcript: text,
                        editLabel: l10n.aiEditRequest,
                        onEdit: controller.editRequest,
                      ),
                    );
                  }),
                ],
              ),
            ),
            Flexible(
              child: Obx(
                    () => ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.xs,
                  ),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSizes.md),
                  itemBuilder: (_, i) {
                    final item = controller.items[i];
                    return Entrance(
                      key: ValueKey('${i}_${item.requestText}'),
                      delay: AppMotion.delayFor(
                        i,
                        base: const Duration(milliseconds: 150),
                      ),
                      duration: AppMotion.normal,
                      offset: const Offset(0, 16),
                      child: SuggestionTile(
                        item: item,
                        onQuantityChanged: (q) =>
                            controller.changeQuantity(i, q),
                        onUseAlternative: (p) =>
                            controller.useAlternative(i, p),
                        onOpenPrinting: controller.openPrinting,
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.cream,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.xl,
                    AppSizes.md,
                    AppSizes.xl,
                    AppSizes.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                            () => AppButton(
                          label: l10n.aiAddToCart(controller.includedCount),
                          icon: Icons.shopping_bag_outlined,
                          isLoading: controller.isAdding.value,
                          onPressed: controller.includedCount > 0
                              ? controller.addToCart
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        l10n.aiFinalPricesNote,
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.sand,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TranscriptCard extends StatefulWidget {
  const _TranscriptCard({
    required this.title,
    required this.transcript,
    required this.editLabel,
    required this.onEdit,
  });

  final String title;
  final String transcript;
  final String editLabel;
  final VoidCallback onEdit;

  @override
  State<_TranscriptCard> createState() => _TranscriptCardState();
}

class _TranscriptCardState extends State<_TranscriptCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceTint,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: AnimatedSize(
            duration: AppMotion.normal,
            curve: AppMotion.emphasized,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hearing_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.transcript,
                  maxLines: _expanded ? null : 1,
                  overflow: _expanded ? null : TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                if (_expanded)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(widget.editLabel),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}