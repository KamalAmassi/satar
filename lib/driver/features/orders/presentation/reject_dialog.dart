import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/widgets/common_widgets.dart';

void showRejectDialog(BuildContext context, int orderId) {
  showDlg(context, icon: 'x', title: 'إخفاء الطلب؟', text: 'لن يظهر لك هذا الطلب مرة أخرى.', foot: [
    SBtn('إخفاء', kind: BtnKind.danger, full: true, onTap: () async {
      Get.back();
      await backend.driverReject(orderId);
      showToast('تـم إخفاء الطلب');
    }),
    SBtn('إلغاء', kind: BtnKind.ghost, full: true, onTap: () => Get.back()),
  ]);
}
