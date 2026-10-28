import 'package:flutter/material.dart';
import 'package:project/core/animations/floating_effect.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';

class OnboardingPageItem extends StatelessWidget {
  const OnboardingPageItem({
    super.key,
    required this.pageController,
    required this.index,
    required this.imageAsset,
    required this.title,
    required this.body,
    required this.counter,
    this.imageFit = BoxFit.cover,
  });

  final PageController pageController;
  final int index;
  final String imageAsset;
  final String title;
  final String body;
  final String counter;
  final BoxFit imageFit;

  double _delta() {
    if (pageController.hasClients && pageController.position.haveDimensions) {
      return (pageController.page ?? index.toDouble()) - index;
    }
    return pageController.initialPage.toDouble() - index;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final textTheme = Theme.of(context).textTheme;
    final dir = Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;
    final cardHeight = (size.height * 0.42).clamp(260.0, 420.0);

    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final delta = _delta();
        final progress = delta.abs().clamp(0.0, 1.0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(dir * delta * size.width * 0.25, 0),
                child: Transform.scale(
                  scale: 1 - progress * 0.06,
                  child: Opacity(
                    opacity: 1 - progress * 0.5,
                    child: FloatingEffect(
                      distance: 6,
                      duration: const Duration(seconds: 4),
                      child: Container(
                        width: double.infinity,
                        height: cardHeight,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.sand.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Image.asset(
                          imageAsset,
                          width: double.infinity,
                          height: cardHeight,
                          fit: BoxFit.fill,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl * 1.5),
              Transform.translate(
                offset: Offset(-dir * delta * size.width * 0.12, 0),
                child: Opacity(
                  opacity: (1 - progress * 1.4).clamp(0.0, 1.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            counter,
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 24,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
