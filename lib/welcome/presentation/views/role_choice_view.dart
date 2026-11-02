import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:project/core/animations/entrance.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/app_wordmark.dart';
import 'package:project/welcome/presentation/controllers/role_choice_controller.dart';
import 'package:project/welcome/presentation/widgets/paper_background.dart';
import 'package:project/welcome/presentation/widgets/paper_sheet.dart';
import 'package:project/welcome/presentation/widgets/welcome_vector_art.dart';

class RoleChoiceView extends GetView<RoleChoiceController> {
  const RoleChoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: PaperBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                children: [
                  const AppWordmark(size: 24),
                  const SizedBox(height: AppSizes.xl * 2),
                  Text(l10n.roleWelcomeTitle, style: textTheme.headlineMedium?.copyWith(color: AppColors.ink)),
                  const SizedBox(height: AppSizes.sm),
                  Text(l10n.roleWelcomeSubtitle, style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSizes.xl),
                  _RoleCard(
                    title: l10n.roleCustomer,
                    art: const BookStackArt(),
                    onTap: controller.continueAsCustomer,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _RoleCard(
                    title: l10n.roleDriver,
                    art: const NotebookArt(), // Reusing notebook art for driver
                    onTap: controller.continueAsDriver,
                  ),
                  const Spacer(),
                  Text(l10n.roleTermsNote, textAlign: TextAlign.center, style: textTheme.labelSmall?.copyWith(color: AppColors.textHint)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.title, required this.art, required this.onTap});

  final String title;
  final Widget art;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Entrance(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: PaperSheet(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
          child: Row(
            children: [
              SizedBox(width: 60, height: 60, child: FittedBox(child: art)),
              const SizedBox(width: AppSizes.lg),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.inkFaded),
            ],
          ),
        ),
      ),
    );
  }
}
