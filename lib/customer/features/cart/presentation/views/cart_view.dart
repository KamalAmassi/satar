import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/config/remote_config_repository.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_messages.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/utils/money.dart';
import 'package:project/core/widgets/purchase_widgets.dart';
import 'package:project/customer/features/cart/domain/entities/cart_product_line.dart';
import 'package:project/customer/features/cart/domain/entities/product_info.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';
import 'package:project/customer/features/printing/domain/entities/print_estimate.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';

/// السلة (إطار 17 وحالة C3 / Cart / Empty).
class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final cart = Get.find<CartController>();
  final configRepo = Get.find<RemoteConfigRepository>();
  final config = Rxn<RemoteConfig>();
  late final TextEditingController _note =
      TextEditingController(text: cart.note.value);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await cart.ensureLoaded();
    _note.text = cart.note.value;
    final r = await configRepo.load();
    if (!mounted) return;
    r.fold((_) {}, (c) => config.value = c);
    // تحديث الأسعار والمخزون الحالي عند فتح السلة.
    await cart.refreshProductInfo();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: PurchaseHeader(
        title: l10n.cartTitle,
        cartCount: () => cart.itemCount,
      ),
      bottomNavigationBar: Obx(() {
        if (cart.isEmpty) return const SizedBox.shrink();
        final c = config.value;
        final total = _subtotal(c);
        final blocked = cart.hasUploadsInFlight ||
            cart.hasFailedUploads ||
            cart.hasInterruptedUploads ||
            cart.products.any((l) => _needsOptions(l));
        return PurchaseBottomBar(
          amountLabel: l10n.totalBeforeDelivery,
          amount: c == null || total == null ? '—' : total.display(c.currency),
          actionLabel: l10n.continueToDelivery,
          onAction: blocked ? null : () => Get.toNamed(CustomerRoutes.checkout),
        );
      }),
      body: Obx(() {
        if (cart.isEmpty) {
          return PurchaseStateView(
            icon: Icons.shopping_bag_outlined,
            title: l10n.cartEmptyTitle,
            body: l10n.cartEmptyBody,
            actionLabel: l10n.startShopping,
            onAction: () => Get.toNamed(CustomerRoutes.home),
            secondaryLabel: l10n.printingStart,
            onSecondary: () => Get.toNamed(CustomerRoutes.printing),
          );
        }
        final c = config.value;
        final text = Theme.of(context).textTheme;
        return ListView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          children: [
            if (cart.hasUploadsInFlight) ...[
              PurchaseBanner(message: l10n.waitForUploads),
              const SizedBox(height: AppSizes.md),
            ],
            if (cart.hasInterruptedUploads) ...[
              PurchaseBanner(
                tone: BannerTone.warning,
                message: l10n.fixInterruptedUploads,
              ),
              const SizedBox(height: AppSizes.md),
            ],
            if (cart.hasFailedUploads) ...[
              PurchaseBanner(
                tone: BannerTone.error,
                message: l10n.fixFailedUploads,
              ),
              const SizedBox(height: AppSizes.md),
            ],
            if (cart.products.isNotEmpty) ...[
              Text(l10n.productsSection, style: text.titleMedium),
              for (final line in cart.products) ...[
                _ProductLineTile(
                  key: ValueKey(line.id),
                  line: line,
                  cart: cart,
                  config: c,
                ),
                const Divider(height: AppSizes.xl),
              ],
            ],
            if (cart.printJobs.isNotEmpty) ...[
              Text(l10n.printingSection, style: text.titleMedium),
              const SizedBox(height: AppSizes.sm),
              for (final job in cart.printJobs) ...[
                _PrintJobTile(job: job, config: c),
                const Divider(height: AppSizes.xl),
              ],
            ],
            Text(l10n.notesForLibrary, style: text.titleSmall),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 5,
              maxLength: 1000,
              decoration: InputDecoration(hintText: l10n.notesForLibraryHint),
              onChanged: cart.setNote,
            ),
            if (cart.products.isNotEmpty &&
                c != null &&
                c.substitutionOptions.isNotEmpty) ...[
              const SizedBox(height: AppSizes.md),
              Text(l10n.ifOutOfStock, style: text.titleMedium),
              RadioGroup<String>(
                groupValue: cart.substitutionPreference.value,
                onChanged: cart.setSubstitutionPreference,
                child: Column(
                  children: [
                    for (final o in c.substitutionOptions)
                      RadioListTile<String>(
                        value: o.value,
                        contentPadding: EdgeInsets.zero,
                        title: Text(o.label),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSizes.md),
            SectionCard(
              tinted: true,
              child: Column(
                children: [
                  if (cart.products.isNotEmpty)
                    SummaryRow(
                      label: l10n.productsSection,
                      value: c == null
                          ? '—'
                          : cart.displayedProductsTotal?.display(c.currency) ??
                              l10n.pricedByLibrary,
                    ),
                  if (cart.printJobs.isNotEmpty)
                    SummaryRow(
                      label: l10n.printingIllustrative,
                      value: c == null
                          ? '—'
                          : _printTotal(c)?.display(c.currency) ?? '—',
                    ),
                  SummaryRow(
                      label: l10n.deliveryFee, value: l10n.deliveryByAddress),
                  const Divider(),
                  SummaryRow(
                    label: l10n.totalBeforeDelivery,
                    value: c == null
                        ? '—'
                        : _subtotal(c)?.display(c.currency) ?? '—',
                    emphasized: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              l10n.finalPriceAtReview,
              style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        );
      }),
    );
  }

  bool _needsOptions(CartProductLine line) {
    final info = cart.productInfo[line.productId];
    if (info == null) return false;
    return info.options.any(
      (o) => o.required && (line.options[o.key]?.isEmpty ?? true),
    );
  }

  Money? _printTotal(RemoteConfig c) {
    final printing = c.printing;
    if (printing == null) return null;
    var total = Money.zero;
    for (final j in cart.printJobs) {
      final e = PrintEstimate.forJob(j, printing);
      if (e == null) return null;
      total = total + e;
    }
    return total;
  }

  Money? _subtotal(RemoteConfig? c) {
    if (c == null) return null;
    final products =
        cart.products.isEmpty ? Money.zero : cart.displayedProductsTotal;
    final printing = cart.printJobs.isEmpty ? Money.zero : _printTotal(c);
    if (products == null || printing == null) return null;
    return products + printing;
  }
}

class _ProductLineTile extends StatelessWidget {
  const _ProductLineTile({
    super.key,
    required this.line,
    required this.cart,
    required this.config,
  });

  final CartProductLine line;
  final CartController cart;
  final RemoteConfig? config;

  // Obx هنا لأن معلومات المنتج تُقرأ داخل البطاقة لا داخل Obx الشاشة.
  @override
  Widget build(BuildContext context) => Obx(() => _tile(context));

  Widget _tile(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final info = cart.productInfo[line.productId];
    final infoFailure = cart.productInfoFailures[line.productId];
    final stock = info?.stock;
    final maxQty = [
      config?.cartMaxQty ?? 99,
      if (stock != null && stock > 0) stock,
    ].reduce((a, b) => a < b ? a : b);
    final stockWarning = info == null
        ? null
        : !info.inStock || stock == 0
            ? l10n.productUnavailable
            : stock != null && line.quantity > stock
                ? l10n.onlyAvailable(stock)
                : null;

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(url: info?.imageUrl),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info?.name ?? l10n.productNumber(line.productId),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (info != null && line.options.isNotEmpty)
                      Text(
                        _optionsSummary(info, line),
                        style: text.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    const SizedBox(height: AppSizes.xs),
                    if (info != null && config != null)
                      Text(
                        info.isInspectionPriced
                            ? l10n.pricedByLibrary
                            : info.price.display(config!.currency),
                        style: text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    if (infoFailure != null)
                      Text(
                        infoFailure.describe(context),
                        style: text.bodySmall?.copyWith(color: AppColors.error),
                      ),
                  ],
                ),
              ),
              QuantityStepper(
                value: line.quantity,
                max: maxQty,
                incrementLabel: l10n.increase,
                decrementLabel: l10n.decrease,
                onChanged: (v) => cart.setQuantity(line.id, v, maxQty: maxQty),
              ),
            ],
          ),
          if (info != null)
            for (final option in info.options)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.md),
                child: _OptionPicker(line: line, option: option, cart: cart),
              ),
          if (stockWarning != null) ...[
            const SizedBox(height: AppSizes.sm),
            PurchaseBanner(tone: BannerTone.warning, message: stockWarning),
          ],
          for (final e in line.fieldErrors.entries)
            if (!e.key.startsWith('options.'))
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.xs),
                child: Text(
                  e.value,
                  style: text.bodySmall?.copyWith(color: AppColors.error),
                ),
              ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => cart.removeProduct(line.id),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(l10n.remove),
            ),
          ),
        ],
      ),
    );
  }

  String _optionsSummary(ProductInfo info, CartProductLine line) => [
        for (final e in line.options.entries)
          for (final c in e.value)
            info
                    .option(e.key)
                    ?.choices
                    .where((x) => x.key == c)
                    .firstOrNull
                    ?.label ??
                c,
      ].join(' · ');
}

class _OptionPicker extends StatelessWidget {
  const _OptionPicker({
    required this.line,
    required this.option,
    required this.cart,
  });

  final CartProductLine line;
  final ProductOptionInfo option;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = line.options[option.key] ?? const [];
    final serverError = line.fieldErrors['options.${option.key}'];
    final missing = option.required && current.isEmpty;
    return ChoiceGroup<ProductChoiceInfo>(
      label: option.required ? '${option.label} *' : option.label,
      options: option.choices,
      selected: option.multi
          ? null
          : option.choices.where((c) => current.contains(c.key)).firstOrNull,
      labelOf: (c) => c.label,
      errorText:
          serverError ?? (missing ? l10n.chooseOption(option.label) : null),
      onSelected: (choice) {
        final next = Map<String, List<String>>.from(line.options);
        if (option.multi) {
          final set = [...current];
          set.contains(choice.key)
              ? set.remove(choice.key)
              : set.add(choice.key);
          set.isEmpty ? next.remove(option.key) : next[option.key] = set;
        } else {
          next[option.key] = [choice.key];
        }
        cart.setOptions(line.id, next);
      },
    );
  }
}

class _PrintJobTile extends StatelessWidget {
  const _PrintJobTile({required this.job, required this.config});

  final PrintJob job;
  final RemoteConfig? config;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final printing = config?.printing;
    final paper =
        printing?.paper(job.spec.paperSize)?.label ?? job.spec.paperSize;
    final binding =
        printing?.binding(job.spec.binding)?.label ?? job.spec.binding;
    final estimate =
        printing == null ? null : PrintEstimate.forJob(job, printing);
    final pages = PrintEstimate.selectedPages(job);
    return InkWell(
      onTap: () => Get.toNamed(CustomerRoutes.printPreview),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: const Icon(Icons.description_outlined,
                color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isolate(job.fileName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  [
                    paper,
                    _colorLabel(l10n, job.spec.color),
                    _sidesLabel(l10n, job.spec.sides),
                    binding,
                  ].join(' · '),
                  style:
                      text.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                if (pages != null)
                  Text(
                    l10n.pagesTimesCopies(pages, job.spec.copies),
                    style: text.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                if (job.status == UploadStatus.uploading)
                  Text(l10n.uploadingPercent((job.progress * 100).round()),
                      style: text.bodySmall),
                if (job.status == UploadStatus.failed)
                  Text(l10n.uploadFailed,
                      style: text.bodySmall?.copyWith(color: AppColors.error)),
                if (job.status == UploadStatus.interrupted)
                  Text(l10n.uploadInterruptedShort,
                      style: text.bodySmall?.copyWith(color: AppColors.error)),
                for (final e in job.fieldErrors.values)
                  Text(e,
                      style: text.bodySmall?.copyWith(color: AppColors.error)),
                if (estimate != null && config != null)
                  Text(
                    '${estimate.display(config!.currency)} · ${l10n.illustrativePrice}',
                    style: text.bodySmall?.copyWith(
                      color: const Color(0xFF8A5A00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, size: AppSizes.iconSm),
        ],
      ),
    );
  }

  String _colorLabel(AppLocalizations l10n, String v) => v == 'color'
      ? l10n.printColorColor
      : v == 'bw'
          ? l10n.printColorBw
          : v;
  String _sidesLabel(AppLocalizations l10n, String v) => v == 'double'
      ? l10n.printSidesDouble
      : v == 'single'
          ? l10n.printSidesSingle
          : v;
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          width: 64,
          height: 64,
          color: AppColors.sand.withValues(alpha: 0.5),
          child: url == null
              ? const Icon(Icons.menu_book_outlined, color: AppColors.primary)
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.primary),
                ),
        ),
      );
}
