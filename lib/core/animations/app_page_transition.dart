import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppPageTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final incoming =
    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final outgoing = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
    );

    return FadeTransition(
      opacity: outgoing,
      child: FadeTransition(
        opacity: incoming,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(isRtl ? -0.06 : 0.06, 0),
            end: Offset.zero,
          ).animate(incoming),
          child: child,
        ),
      ),
    );
  }
}