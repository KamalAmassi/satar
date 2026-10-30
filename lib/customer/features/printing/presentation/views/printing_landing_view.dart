import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_messages.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/widgets/purchase_widgets.dart';
import 'package:project/customer/features/printing/presentation/controllers/printing_controller.dart';

/// خدمات الطباعة (إطار 20). الأسعار من الإعداد وليست من التصميم.
class PrintingLandingView extends GetView<PrintingController> {
  const PrintingLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: PurchaseHeader(
        title: l10n.printingServicesTitle,
        cartCount: () => controller.cart.itemCount,
        onCartTap: () => Get.toNamed(CustomerRoutes.cart),
      ),
      bottomNavigationBar: PurchaseBottomBar(
        actionLabel: l10n.printingStart,
        onAction: () => Get.toNamed(CustomerRoutes.printPreview),
      ),
      body: Obx(() {
        final config = controller.printing.value;
        final currency = controller.remoteConfig.value?.currency;
        return ListView(
          children: [
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.printingHeroEyebrow,
                          style:
                              text.bodySmall?.copyWith(color: AppColors.sand),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          l10n.printingHeroTitle,
                          style: text.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          l10n.printingHeroBody,
                          style: text.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.lg),
                  const Icon(Icons.print_outlined,
                      color: AppColors.sand, size: 56),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.printingServicesTitle, style: text.titleMedium),
                  const SizedBox(height: AppSizes.md),
                  if (controller.configLoading.value && config == null)
                    const Center(child: CircularProgressIndicator())
                  else if (config == null)
                    PurchaseBanner(
                      tone: BannerTone.error,
                      message:
                          controller.configFailure.value?.describe(context) ??
                              l10n.errorGeneral,
                      action: TextButton(
                        onPressed: () => controller.load(refresh: true),
                        child: Text(l10n.retry),
                      ),
                    )
                  else
                    Builder(builder: (context) {
                      final paper = config.paperSizes.first;
                      final binding = config.bindings
                          .where((b) => b.price.amount > 0)
                          .firstOrNull;
                      final cards = [
                        _ServiceCard(
                          icon: Icons.description_outlined,
                          title: l10n.printingServiceBw(paper.label),
                          price: l10n.perPrintedSide(
                            paper.bwSidePrice.display(currency!),
                          ),
                        ),
                        _ServiceCard(
                          icon: Icons.palette_outlined,
                          title: l10n.printingServiceColor(paper.label),
                          price: l10n.perPrintedSide(
                            paper.colorSidePrice.display(currency),
                          ),
                        ),
                        if (binding != null)
                          _ServiceCard(
                            icon: Icons.menu_book_outlined,
                            title: binding.label,
                            price:
                                l10n.perCopy(binding.price.display(currency)),
                          ),
                      ];
                      return LayoutBuilder(
                        builder: (context, c) {
                          final perRow = c.maxWidth < 330 ? 2 : 3;
                          final w = (c.maxWidth - AppSizes.sm * (perRow - 1)) /
                              perRow;
                          return Wrap(
                            spacing: AppSizes.sm,
                            runSpacing: AppSizes.sm,
                            children: [
                              for (final card in cards)
                                SizedBox(width: w, child: card),
                            ],
                          );
                        },
                      );
                    }),
                  const SizedBox(height: AppSizes.lg),
                  PurchaseBanner(
                    icon: Icons.auto_awesome_outlined,
                    message: l10n.printingFinalPriceNote,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.price,
  });

  final IconData icon;
  final String title;
  final String price;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SectionCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            price,
            textAlign: TextAlign.center,
            style: text.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
