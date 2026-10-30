import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/config/remote_config.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/errors/failure_messages.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/core/utils/money.dart';
import 'package:project/core/widgets/purchase_widgets.dart';
import 'package:project/customer/features/printing/domain/entities/file_check.dart';
import 'package:project/customer/features/printing/domain/entities/page_range.dart';
import 'package:project/customer/features/printing/domain/entities/print_estimate.dart';
import 'package:project/customer/features/printing/domain/entities/print_job.dart';
import 'package:project/customer/features/printing/presentation/controllers/printing_controller.dart';

/// اختيار الملفات ومواصفات كل ملف (إطارات 22 و 46 وحالات C3 / 21A / 21B).
class PrintSpecsView extends GetView<PrintingController> {
  const PrintSpecsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: PurchaseHeader(
        title: l10n.printSpecsTitle,
        cartCount: () => controller.cart.itemCount,
        onCartTap: () => Get.toNamed(CustomerRoutes.cart),
      ),
      bottomNavigationBar: Obx(() {
        final config = controller.printing.value;
        final jobs = controller.cart.printJobs;
        if (config == null || jobs.isEmpty) return const SizedBox.shrink();
        final currency = controller.remoteConfig.value!.currency;
        Money? total = Money.zero;
        for (final j in jobs) {
          final e = PrintEstimate.forJob(j, config);
          total = (total == null || e == null) ? null : total + e;
        }
        final blocked = controller.cart.hasUploadsInFlight ||
            controller.cart.hasFailedUploads ||
            controller.cart.hasInterruptedUploads ||
            jobs.any((j) =>
                !PageRange.isValid(j.spec.pageRange, totalPages: j.knownPages));
        return PurchaseBottomBar(
          amountLabel: l10n.estimateLabel,
          amount: total?.display(currency) ?? '—',
          actionLabel: l10n.reviewPrice,
          onAction: blocked ? null : () => Get.toNamed(CustomerRoutes.cart),
        );
      }),
      body: Obx(() {
        final config = controller.printing.value;
        if (config == null) {
          if (controller.configFailure.value != null) {
            return PurchaseStateView(
              tone: BannerTone.error,
              icon: Icons.cloud_off_outlined,
              title: l10n.errorGeneral,
              body: controller.configFailure.value!.describe(context),
              actionLabel: l10n.retry,
              onAction: () => controller.load(refresh: true),
            );
          }
          return PurchaseStateView(title: l10n.loading, loading: true);
        }
        final jobs = controller.cart.printJobs;
        return ListView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          children: [
            if (controller.limitReached.value) ...[
              PurchaseBanner(
                tone: BannerTone.warning,
                icon: Icons.block_outlined,
                message: l10n.fileLimitBody(config.maxJobs),
                action: IconButton(
                  tooltip: l10n.dismiss,
                  onPressed: controller.dismissLimit,
                  icon: const Icon(Icons.close, size: AppSizes.iconSm),
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],
            for (final r in controller.rejected) ...[
              _RejectedFileCard(
                  file: r, config: config, controller: controller),
              const SizedBox(height: AppSizes.md),
            ],
            if (jobs.isEmpty)
              _FileSelectionPanel(config: config, controller: controller)
            else ...[
              PurchaseBanner(
                tone: BannerTone.warning,
                message: l10n.printSpecsHint,
              ),
              const SizedBox(height: AppSizes.md),
              for (final job in jobs) ...[
                _PrintJobCard(
                  key: ValueKey(job.id),
                  job: job,
                  config: config,
                  currency: controller.remoteConfig.value!.currency,
                  controller: controller,
                ),
                const SizedBox(height: AppSizes.md),
              ],
              _AddFileButton(controller: controller),
            ],
            const SizedBox(height: AppSizes.xl),
          ],
        );
      }),
    );
  }
}

class _FileSelectionPanel extends StatelessWidget {
  const _FileSelectionPanel({required this.config, required this.controller});

  final PrintingConfig config;
  final PrintingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.whatToPrint, style: text.titleLarge),
        const SizedBox(height: AppSizes.md),
        SectionCard(
          tinted: true,
          child: Column(
            children: [
              SummaryRow(
                  label: l10n.supportedFiles, value: l10n.supportedFileTypes),
              SummaryRow(
                label: l10n.maxFileSize,
                value: l10n.maxPerFile(formatBytes(config.maxFileBytes)),
              ),
              SummaryRow(label: l10n.maxFiles, value: '${config.maxJobs}'),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Obx(() => InkWell(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              onTap: controller.picking.value ? null : controller.pickFiles,
              child: SectionCard(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.xxl,
                  horizontal: AppSizes.lg,
                ),
                child: Column(
                  children: [
                    controller.picking.value
                        ? const CircularProgressIndicator()
                        : const Icon(
                            Icons.upload_file_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                    const SizedBox(height: AppSizes.md),
                    Text(l10n.tapToChooseFile, style: text.titleSmall),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _AddFileButton extends StatelessWidget {
  const _AddFileButton({required this.controller});

  final PrintingController controller;

  @override
  Widget build(BuildContext context) => Obx(() => OutlinedButton.icon(
        onPressed: controller.picking.value ? null : controller.pickFiles,
        icon: const Icon(Icons.add),
        label: Text(context.l10n.addAnotherFile),
      ));
}

class _RejectedFileCard extends StatelessWidget {
  const _RejectedFileCard({
    required this.file,
    required this.config,
    required this.controller,
  });

  final RejectedFile file;
  final PrintingConfig config;
  final PrintingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final tooLarge = file.reason == FileRejection.tooLarge;
    return SectionCard(
      highlighted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  tooLarge
                      ? l10n.uploadTooLargeTitle
                      : l10n.uploadUnsupportedTitle,
                  style: text.titleSmall?.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            tooLarge
                ? l10n.uploadTooLargeBody(formatBytes(config.maxFileBytes))
                : file.reason == FileRejection.empty
                    ? l10n.uploadEmptyBody
                    : l10n.uploadUnsupportedBody,
            style: text.bodySmall,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            '${isolate(file.name)} · ${formatBytes(file.size)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Wrap(
              spacing: AppSizes.sm,
              children: [
                TextButton(
                  onPressed: controller.dismissRejections,
                  child: Text(l10n.dismiss),
                ),
                TextButton(
                  onPressed: controller.pickFiles,
                  child: Text(l10n.chooseAnotherFile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrintJobCard extends StatefulWidget {
  const _PrintJobCard({
    super.key,
    required this.job,
    required this.config,
    required this.currency,
    required this.controller,
  });

  final PrintJob job;
  final PrintingConfig config;
  final CurrencyFormat currency;
  final PrintingController controller;

  @override
  State<_PrintJobCard> createState() => _PrintJobCardState();
}

class _PrintJobCardState extends State<_PrintJobCard> {
  late final TextEditingController _range =
      TextEditingController(text: widget.job.spec.pageRange);
  late final TextEditingController _notes =
      TextEditingController(text: widget.job.spec.notes);

  @override
  void dispose() {
    _range.dispose();
    _notes.dispose();
    super.dispose();
  }

  String _colorLabel(AppLocalizations l10n, String v) => switch (v) {
        'bw' => l10n.printColorBw,
        'color' => l10n.printColorColor,
        _ => v,
      };

  String _sidesLabel(AppLocalizations l10n, String v) => switch (v) {
        'single' => l10n.printSidesSingle,
        'double' => l10n.printSidesDouble,
        _ => v,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final job = widget.job;
    final config = widget.config;
    final c = widget.controller;
    final pages = job.knownPages;
    final selected = PrintEstimate.selectedPages(job);
    final estimate = PrintEstimate.forJob(job, config);
    final rangeValid = PageRange.isValid(job.spec.pageRange, totalPages: pages);
    final server = job.fieldErrors;
    final editable = !job.needsAttention;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  job.isImage
                      ? Icons.image_outlined
                      : Icons.description_outlined,
                  color: AppColors.primary,
                ),
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
                      style: text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      pages == null
                          ? formatBytes(job.size)
                          : '${l10n.pagesCount(pages)} · ${formatBytes(job.size)}',
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => c.cart.removePrintJob(job.id),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(l10n.remove),
              ),
            ],
          ),
          if (job.status == UploadStatus.uploading) ...[
            const SizedBox(height: AppSizes.sm),
            LinearProgressIndicator(
                value: job.progress > 0 ? job.progress : null),
            const SizedBox(height: AppSizes.xs),
            Text(
              l10n.uploadingPercent((job.progress * 100).round()),
              style: text.bodySmall,
            ),
          ],
          if (job.status == UploadStatus.interrupted) ...[
            const SizedBox(height: AppSizes.sm),
            PurchaseBanner(
              tone: BannerTone.warning,
              message: l10n.uploadInterrupted,
              action: TextButton(
                onPressed: () => c.reselect(job.id),
                child: Text(l10n.chooseFileAgain),
              ),
            ),
          ],
          if (job.status == UploadStatus.failed) ...[
            const SizedBox(height: AppSizes.sm),
            PurchaseBanner(
              tone: BannerTone.error,
              message: job.failure?.describe(context) ?? l10n.uploadFailed,
              action: TextButton(
                onPressed: () => c.cart.retryUpload(job.id),
                child: Text(l10n.retry),
              ),
            ),
          ],
          const Divider(height: AppSizes.xl),
          ChoiceGroup<PaperSizeOption>(
            label: l10n.paperSize,
            options: config.paperSizes,
            selected: config.paper(job.spec.paperSize),
            labelOf: (p) => p.label,
            enabled: editable,
            errorText: server['paper_size'],
            onSelected: (p) =>
                c.updateSpec(job.id, (s) => s.copyWith(paperSize: p.key)),
          ),
          const SizedBox(height: AppSizes.lg),
          ChoiceGroup<String>(
            label: l10n.printColor,
            options: config.colors,
            selected: job.spec.color,
            labelOf: (v) => _colorLabel(l10n, v),
            enabled: editable,
            errorText: server['print_color'],
            onSelected: (v) =>
                c.updateSpec(job.id, (s) => s.copyWith(color: v)),
          ),
          const SizedBox(height: AppSizes.lg),
          ChoiceGroup<String>(
            label: l10n.printSides,
            options: config.sides,
            selected: job.spec.sides,
            labelOf: (v) => _sidesLabel(l10n, v),
            enabled: editable,
            errorText: server['print_sides'],
            onSelected: (v) =>
                c.updateSpec(job.id, (s) => s.copyWith(sides: v)),
          ),
          const SizedBox(height: AppSizes.lg),
          ChoiceGroup<BindingOption>(
            label: l10n.binding,
            options: config.bindings,
            selected: config.binding(job.spec.binding),
            labelOf: (b) => b.label,
            enabled: editable,
            errorText: server['binding_type'],
            onSelected: (b) =>
                c.updateSpec(job.id, (s) => s.copyWith(binding: b.key)),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(l10n.pageRange, style: text.titleSmall),
          const SizedBox(height: AppSizes.sm),
          TextField(
            controller: _range,
            enabled: editable,
            keyboardType: TextInputType.text,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: l10n.pageRangeAllHint,
              helperText: pages == null ? null : l10n.pageRangeHelper(pages),
              errorText: server['print_page_range'] ??
                  (rangeValid ? null : l10n.pageRangeInvalid),
              errorMaxLines: 3,
              helperMaxLines: 2,
            ),
            onChanged: (v) =>
                c.updateSpec(job.id, (s) => s.copyWith(pageRange: v)),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.copies, style: text.titleSmall),
                    if (selected != null)
                      Text(
                        l10n.pagesTimesCopies(selected, job.spec.copies),
                        style: text.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    if (server['print_copies'] != null)
                      Text(
                        server['print_copies']!,
                        style: text.bodySmall?.copyWith(color: AppColors.error),
                      ),
                  ],
                ),
              ),
              QuantityStepper(
                value: job.spec.copies,
                max: config.maxCopies,
                incrementLabel: l10n.increase,
                decrementLabel: l10n.decrease,
                onChanged: editable
                    ? (v) => c.updateSpec(job.id, (s) => s.copyWith(copies: v))
                    : (_) {},
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Text(l10n.fileNotes, style: text.titleSmall),
          const SizedBox(height: AppSizes.sm),
          TextField(
            controller: _notes,
            enabled: editable,
            minLines: 2,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: l10n.fileNotesHint,
              errorText: server['print_specifications'],
            ),
            onChanged: (v) => c.updateSpec(job.id, (s) => s.copyWith(notes: v)),
          ),
          SummaryRow(
            label: l10n.estimateForFile,
            value: estimate?.display(widget.currency) ?? '—',
            emphasized: true,
          ),
        ],
      ),
    );
  }
}
