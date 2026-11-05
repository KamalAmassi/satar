import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/animations/fly_to_cart/cart_target.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/extensions/context_extensions.dart';
import 'package:project/core/widgets/common_widgets.dart';

/// زر السلة مع شارة العدد؛ وجهة «الطيران إلى السلة». منقول من
/// d1d6084:lib/features/catalog/catalog.dart (CartBadgeButton).
class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({super.key});
  @override
  Widget build(BuildContext context) => CartTargetAnchor(
        child: Obx(() {
          cartCtl.revision.value;
          final n = cartCtl.itemCount;
          return Semantics(
            label: context.l10n.cartBadgeLabel(n),
            button: true,
            excludeSemantics: true,
            child: SIconBtn('bag', badge: n > 0 ? '$n' : null, onTap: () => Get.toNamed('/cart')),
          );
        }),
      );
}
