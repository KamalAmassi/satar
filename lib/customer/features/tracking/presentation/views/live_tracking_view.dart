import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/core/constants/app_sizes.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/customer/features/tracking/presentation/controllers/live_tracking_controller.dart';

class LiveTrackingView extends GetView<LiveTrackingController> {
  const LiveTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LiveTrackingController());
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'التتبع المباشر',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                onPressed: () => Get.toNamed(CustomerRoutes.cart),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Map Mock Area with Dotted Path and Expand Button
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFECE9),
                ),
                child: Stack(
                  children: [
                    // Mock Dotted Path & Map Graphics
                    Center(
                      child: CustomPaint(
                        size: const Size(300, 200),
                        painter: _MapPathPainter(),
                      ),
                    ),
                    // Expand Map Button
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.fullscreen, size: 16, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text('توسيع الخريطة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Driver & Order Cards Bottom Sheet Area
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(AppSizes.pagePadding),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Estimated Arrival Card
                      Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: AppSizes.sm),
                                Text('حسب بيانات التتبع: 12 دقيقة', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ],
                            ),
                            Text('وقت الوصول المتوقع', style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Driver Card
                      Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_outline, color: AppColors.primary),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('السائق المعين', style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text('محمد • مركبة بيضاء', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ],
                              ),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                              ),
                              onPressed: controller.callDriver,
                              child: const Text('اتصال', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Destination Card
                      Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: AppColors.primary),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('وجهة التوصيل', style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text('البيت • تفاصيل العنوان محفوظة', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Order Card
                      Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ST-2048', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                                const SizedBox(height: 2),
                                const Text('6 عناصر • 104.00 ₪', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                              ),
                              child: const Text(
                                'في الطريق',
                                style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
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

class _MapPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(40, 150);
    path.quadraticBezierTo(120, 20, 260, 120);

    // Draw dotted line
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
