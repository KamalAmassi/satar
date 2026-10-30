import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_button.dart';

/// عناصر بسيطة مشتركة لشاشات الشراء، مبنية على ألوان وقياسات المشروع فقط.

/// عزل اتجاه النص (أسماء الملفات والأرقام والرموز) داخل واجهة RTL أو LTR.
String isolate(String text) =>
    '${String.fromCharCode(0x2068)}$text${String.fromCharCode(0x2069)}';

/// نص اتجاهه ثابت من اليسار لليمين (أرقام هواتف، حسابات، رموز طلبات).
class LtrText extends StatelessWidget {
  const LtrText(this.text, {super.key, this.style, this.maxLines});

  final String text;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textDirection: TextDirection.ltr,
        style: style,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
      );
}

/// رأس الصفحة: رجوع، عنوان في المنتصف، وعدّاد السلة اختياري.
class PurchaseHeader extends StatelessWidget implements PreferredSizeWidget {
  const PurchaseHeader({
    super.key,
    required this.title,
    this.cartCount,
    this.onCartTap,
    this.onBack,
  });

  final String title;

  /// يُقرأ داخل Obx ليبقى العدّاد محدّثًا.
  final int Function()? cartCount;
  final VoidCallback? onCartTap;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      backgroundColor: AppColors.cream,
      toolbarHeight: AppSizes.appBarHeight + 8,
      automaticallyImplyLeading: false,
      leadingWidth: 64,
      leading: (onBack != null || canPop)
          ? Padding(
              padding: const EdgeInsetsDirectional.only(start: AppSizes.lg),
              child: _CircleButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: Icons.arrow_back,
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
              ),
            )
          : null,
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [
        if (cartCount != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSizes.lg),
            child: Obx(() {
              final count = cartCount!();
              return Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                backgroundColor: AppColors.primary,
                child: _CircleButton(
                  tooltip: context.l10n.cartTitle,
                  icon: Icons.shopping_bag_outlined,
                  onTap: onCartTap,
                  filled: true,
                ),
              );
            }),
          ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: filled
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          shape: CircleBorder(
            side: filled
                ? BorderSide.none
                : const BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child:
                  Icon(icon, size: AppSizes.iconMd, color: AppColors.primary),
            ),
          ),
        ),
      );
}

/// شريط سفلي ثابت: المبلغ في جهة والزر في الأخرى، فوق لوحة المفاتيح.
class PurchaseBottomBar extends StatelessWidget {
  const PurchaseBottomBar({
    super.key,
    required this.actionLabel,
    required this.onAction,
    this.amountLabel,
    this.amount,
    this.isLoading = false,
    this.secondary,
  });

  final String actionLabel;
  final VoidCallback? onAction;
  final String? amountLabel;
  final String? amount;
  final bool isLoading;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: AppColors.cream,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePadding,
            AppSizes.md,
            AppSizes.pagePadding,
            AppSizes.md,
          ),
          child: Row(
            children: [
              // المبلغ يتصغّر ليناسب (FittedBox)، فالزر يأخذ المساحة الأكبر
              // حتى لا تُقص نصوص مثل "Continue to delivery".
              if (amount != null)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (amountLabel != null)
                        Text(
                          amountLabel!,
                          style: text.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          amount!,
                          style: text.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              if (secondary != null) Expanded(child: secondary!),
              if (amount != null || secondary != null)
                const SizedBox(width: AppSizes.md),
              Expanded(
                flex: secondary != null && amount == null ? 1 : 2,
                child: AppButton(
                  label: actionLabel,
                  onPressed: onAction,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// مجموعة اختيارات (حجم الورق، اللون، التجليد…).
class ChoiceGroup<T> extends StatelessWidget {
  const ChoiceGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: [
            for (final o in options)
              ChoiceChip(
                label: Text(labelOf(o)),
                selected: o == selected,
                showCheckmark: false,
                onSelected: enabled ? (_) => onSelected(o) : null,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: o == selected ? Colors.white : AppColors.textPrimary,
                ),
                side: BorderSide(
                  color: o == selected ? AppColors.primary : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
              ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSizes.xs),
          Text(errorText!,
              style: text.bodySmall?.copyWith(color: AppColors.error)),
        ],
      ],
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.lg),
    this.highlighted = false,
    this.tinted = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;
  final bool tinted;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: tinted
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: tinted
              ? null
              : Border.all(
                  color: highlighted ? AppColors.primary : AppColors.border,
                  width: highlighted ? 1.5 : 1,
                ),
        ),
        child: child,
      );
}

/// صفوف ملخّص المبالغ.
class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium;
    final style = emphasized
        ? base?.copyWith(fontWeight: FontWeight.w700, fontSize: 16)
        : base;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: AppSizes.md),
          // يملأ نصيبه ويُحاذى للطرف: لا تتجاوز القيم الطويلة الحافة مع
          // الخط الكبير، وتبقى القيم القصيرة على الحافة.
          Expanded(
            child: Text(value, style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.decrementLabel,
    this.incrementLabel,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String? decrementLabel;
  final String? incrementLabel;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.outlined(
            tooltip: incrementLabel,
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton.outlined(
            tooltip: decrementLabel,
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
        ],
      );
}

enum BannerTone { info, warning, error, success }

class PurchaseBanner extends StatelessWidget {
  const PurchaseBanner({
    super.key,
    required this.message,
    this.tone = BannerTone.info,
    this.icon,
    this.action,
  });

  final String message;
  final BannerTone tone;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      BannerTone.info => AppColors.primary,
      BannerTone.warning => const Color(0xFF8A5A00),
      BannerTone.error => AppColors.error,
      BannerTone.success => const Color(0xFF0F7A55),
    };
    final background = switch (tone) {
      BannerTone.warning => AppColors.sand.withValues(alpha: 0.6),
      _ => color.withValues(alpha: 0.08),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.iconSm, color: color),
            const SizedBox(width: AppSizes.sm),
          ],
          Expanded(
            child: Text(
              message,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// حالة كاملة الشاشة (تحميل، خطأ، فراغ، نجاح…) كما في إطارات C3.
class PurchaseStateView extends StatelessWidget {
  const PurchaseStateView({
    super.key,
    required this.title,
    this.body,
    this.icon,
    this.tone = BannerTone.info,
    this.loading = false,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.child,
  });

  final String title;
  final String? body;
  final IconData? icon;
  final BannerTone tone;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = switch (tone) {
      BannerTone.error => AppColors.error,
      BannerTone.warning => const Color(0xFF8A5A00),
      BannerTone.success => const Color(0xFF0F7A55),
      BannerTone.info => AppColors.primary,
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSizes.xl),
          Center(
            child: loading
                ? const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : CircleAvatar(
                    radius: 36,
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Icon(icon ?? Icons.info_outline,
                        color: color, size: 36),
                  ),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (body != null) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: AppSizes.lg),
            child!,
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: AppSizes.xl),
            AppButton(label: actionLabel!, onPressed: onAction),
          ],
          if (secondaryLabel != null) ...[
            const SizedBox(height: AppSizes.sm),
            AppButton(
              label: secondaryLabel!,
              onPressed: onSecondary,
              variant: AppButtonVariant.outlined,
            ),
          ],
        ],
      ),
    );
  }
}

/// حجم الملف بصيغة مقروءة (KB / MB)، معزول LTR حتى لا ينقلب داخل نص عربي.
String formatBytes(int bytes) {
  String ltr(String s) =>
      '${String.fromCharCode(0x2066)}$s${String.fromCharCode(0x2069)}';
  if (bytes < 1024) return ltr('$bytes B');
  final kb = bytes / 1024;
  if (kb < 1024) return ltr('${kb.toStringAsFixed(0)} KB');
  return ltr('${(kb / 1024).toStringAsFixed(1)} MB');
}
