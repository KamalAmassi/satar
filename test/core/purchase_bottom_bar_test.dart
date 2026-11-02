import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/core/theme/app_theme.dart';
import 'package:project/core/widgets/purchase_widgets.dart';

// Live case (English build, 360 dp phone): the cart button read
// "Continue to d…". The action must stay readable next to the amount.
void main() {
  // Real glyph widths: the default test font makes every glyph a 1em square.
  setUpAll(() async {
    final loader = FontLoader('IBMPlexSansArabic');
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(Future(() async => ByteData.sublistView(
          await File('assets/fonts/IBMPlexSansArabic-$w.ttf').readAsBytes())));
    }
    await loader.load();
  });

  for (final label in [
    'Continue to delivery',
    'Accept the new price',
    'Confirm order',
  ]) {
    testWidgets('"$label" is not truncated next to an amount', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          bottomNavigationBar: PurchaseBottomBar(
            actionLabel: label,
            onAction: () {},
            amountLabel: 'Total before delivery',
            amount: '128.00 ₪',
          ),
        ),
      ));
      final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
      expect(paragraph.didExceedMaxLines, isFalse);
    });
  }
}
