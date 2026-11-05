import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/design/widgets.dart';
import 'package:project/core/extensions/context_extensions.dart';

/// كود التسليم للزبون: أرقام كبيرة + نسخ + تنبيه بإعطائه للسائق عند الاستلام فقط.
class DeliveryCodePanel extends StatelessWidget {
  const DeliveryCodePanel(this.code, {super.key});
  final String code;
  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = context.l10n;
    return Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(l.orderDeliveryCodeTitle, style: T.h3(c.tx, size: 15))),
        SBtn(l.copy, kind: BtnKind.sec, size: BtnSize.xs, icon: 'copy', onTap: () {
          Clipboard.setData(ClipboardData(text: code));
          showToast(l.copied, icon: 'copy');
        }),
      ]),
      const SizedBox(height: 8),
      CodeBox(code, bg: c.sf, size: 34),
      const SizedBox(height: 8),
      Text(l.orderDeliveryCodeCaption, style: T.cap(c.tx2)),
    ]));
  }
}
