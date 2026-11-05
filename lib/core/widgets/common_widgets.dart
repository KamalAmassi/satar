import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/errors/failure_messages.dart';
import 'package:project/core/data/backend.dart';
import 'package:project/customer/features/cart/presentation/controllers/cart_controller.dart';

Backend get backend => Get.find<Backend>();
CartController get cartCtl => Get.find<CartController>();

String failureText(Failure f) => FailureMessages.localizedMessage(Get.context!, f);

void showToast(String message, {String? actionLabel, VoidCallback? onAction, String? icon}) {
  final ctx = Get.context;
  if (ctx == null) return;
  final c = ctx.sc;
  Get.rawSnackbar(
    messageText: Row(children: [
      if (icon != null) ...[SIcon(icon, size: 20, color: c.onPri), const SizedBox(width: 10)],
      Expanded(child: Text(message, style: TextStyle(fontFamily: Fonts.ui, fontSize: 14.5, fontWeight: FontWeight.w600, color: c.onPri))),
      if (actionLabel != null && onAction != null) ...[
        const SizedBox(width: 8),
        InkWell(onTap: () {
          Get.closeCurrentSnackbar();
          onAction();
        }, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text(actionLabel, style: TextStyle(fontFamily: Fonts.ui, fontSize: 14, fontWeight: FontWeight.w700, color: c.amber, decoration: TextDecoration.underline)))),
      ],
    ]),
    backgroundColor: c.pri,
    borderRadius: Rad.m,
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 3),
  );
}

void showSheet(BuildContext context, {required String title, required Widget body, List<Widget>? foot}) {
  final c = context.sc;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: c.sf,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.xl))),
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: T.h2(c.tx)), SIconBtn('x', size: 20, box: 36, onTap: () => Navigator.pop(context))]),
            const SizedBox(height: 16),
            Flexible(child: SingleChildScrollView(child: body)),
            if (foot != null && foot.isNotEmpty) ...[
              const SizedBox(height: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: foot),
            ],
          ]),
        ),
      ),
    ),
  );
}

void showDlg(BuildContext context, {required String title, required String text, String? icon, String kind = 'plum', bool dismissible = true, List<Widget>? foot}) {
  final c = context.sc;
  showDialog<void>(
    context: context,
    barrierDismissible: dismissible,
    builder: (_) => PopScope(
      canPop: dismissible,
      child: AlertDialog(
        backgroundColor: c.sf,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.xl)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (icon != null) Center(child: Padding(padding: const EdgeInsets.only(bottom: 16), child: SIcon(icon, size: 40, color: kind == 'err' ? c.errInk : c.plumInk))),
          Text(title, textAlign: TextAlign.center, style: T.h2(c.tx)),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center, style: T.bd(c.tx2)),
          if (foot != null && foot.isNotEmpty) ...[
            const SizedBox(height: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: foot),
          ],
        ]),
      ),
    ),
  );
}

void goTab(String route) {
  Get.until((r) => r.settings.name == '/home' || r.isFirst);
  if (route != '/home') Get.toNamed(route);
}
