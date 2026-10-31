import 'package:flutter/material.dart';
import 'package:project/core/animations/app_motion.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/quantity_stepper.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggested_product.dart';
import 'package:project/customer/features/ai_assistant/domain/entities/suggestion_item.dart';

class SuggestionTile extends StatelessWidget {
  const SuggestionTile({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onUseAlternative,
    required this.onOpenPrinting,
  });

  final SuggestionItem item;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<SuggestedProduct> onUseAlternative;
  final VoidCallback onOpenPrinting;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: switch (item.status) {
        SuggestionStatus.notFound => _NotFound(query: item.requestText),
        SuggestionStatus.printJob => _PrintRow(
          title: item.requestText,
          actionLabel: l10n.aiOpenPrinting,
          onPressed: onOpenPrinting,
        ),
        _ => _productContent(context, l10n, textTheme),
      },
    );
  }

  Widget _productContent(
      BuildContext context,
      dynamic l10n,
      TextTheme textTheme,
      ) {
    final product = item.product!;
    final dimmed = item.status == SuggestionStatus.outOfStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: AppMotion.fast,
          child: KeyedSubtree(
            key: ValueKey(product.id),
            child: Row(
              children: [
                Opacity(
                  opacity: dimmed ? 0.5 : 1,
                  child: _ProductImage(url: product.imageUrl, size: 60),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Opacity(
                    opacity: dimmed ? 0.55 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.priceLabel,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (product.optionLabels.isNotEmpty)
                          Text(
                            product.optionLabels.join(' • '),
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (item.isSelectable) ...[
                  const SizedBox(width: AppSizes.sm),
                  QuantityStepper(
                    value: item.quantity,
                    max: item.maxQuantity,
                    onChanged: onQuantityChanged,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        switch (item.status) {
          SuggestionStatus.available => _StatusLine(
            icon: Icons.check_circle_rounded,
            text: l10n.aiAvailable as String,
            color: AppColors.success,
          ),
          SuggestionStatus.limited => _StatusLine(
            icon: Icons.warning_amber_rounded,
            text: l10n.aiLimitedStock(item.maxQuantity, item.requestedQty)
            as String,
            color: AppColors.warning,
          ),
          _ => _StatusLine(
            icon: Icons.cancel_rounded,
            text: l10n.aiUnavailable as String,
            color: AppColors.error,
          ),
        },
        if (item.alternatives.isNotEmpty) ...[
          const SizedBox(height: AppSizes.md),
          Text(
            l10n.aiAlternatives as String,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: item.alternatives.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
              itemBuilder: (_, i) => _AlternativeCard(
                product: item.alternatives[i],
                label: l10n.aiUseAlternative as String,
                onUse: () => onUseAlternative(item.alternatives[i]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrintRow extends StatelessWidget {
  const _PrintRow({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceTint,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: const Icon(Icons.print_outlined, color: AppColors.primary),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceTint,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: const Icon(Icons.search_off_rounded, color: AppColors.textHint),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aiNotFound(query),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                l10n.aiNotFoundHint,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({
    required this.product,
    required this.label,
    required this.onUse,
  });

  final SuggestedProduct product;
  final String label;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 172,
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProductImage(url: product.imageUrl, size: 36),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.priceLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                height: 32,
                child: FilledButton(
                  onPressed: onUse,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: Text(label),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: AppColors.surfaceTint,
      child: Icon(
        Icons.inventory_2_outlined,
        size: size * 0.45,
        color: AppColors.textHint,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: url == null || url!.isEmpty
          ? placeholder
          : Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}