import 'package:flutter/material.dart';
import 'package:project/core/constants/app_assets.dart';
import 'package:project/core/constants/app_colors.dart';

class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 96, this.framed = false});

  final double size;

  /// يضع الشعار داخل مربع رملي (للخلفيات الغامقة مثل Splash).
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final inner = framed ? size * 0.66 : size;

    final content = Image.asset(
      AppAssets.logo,
      width: inner,
      height: inner,
      fit: BoxFit.fill,
      errorBuilder: (_, __, ___) => SizedBox(
        width: inner,
        height: inner,
        child: FittedBox(
          child: Text(
            'سطر',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: framed ? AppColors.primary : AppColors.sand,
              height: 1,
            ),
          ),
        ),
      ),
    );

    if (!framed) return content;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: content,
    );
  }
}