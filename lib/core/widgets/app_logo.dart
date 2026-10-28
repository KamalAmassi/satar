import 'package:flutter/material.dart';
import 'package:project/core/constants/app_assets.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.fallbackColor});

  final double size;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          child: Text(
            'سطر',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: fallbackColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}