import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/route_nav.dart';

Widget _page(String name) => Scaffold(body: Text(name));

void main() {
  tearDown(Get.reset);

  testWidgets('leaving the purchase flow drops its screens from the back stack',
      (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: '/hub',
      getPages: [
        for (final n in ['/hub', '/cart', '/checkout', '/review', '/order'])
          GetPage(name: n, page: () => _page(n)),
      ],
    ));
    for (final r in ['/cart', '/checkout', '/review']) {
      Get.toNamed(r);
      await tester.pumpAndSettle();
    }

    leaveFlowTo('/order', {'/cart', '/checkout', '/review'},
        arguments: {'order_id': 73});
    await tester.pumpAndSettle();
    expect(find.text('/order'), findsOneWidget);
    expect(Get.arguments, {'order_id': 73});

    Get.back();
    await tester.pumpAndSettle();
    expect(find.text('/hub'), findsOneWidget,
        reason: 'Back must not return into the finished checkout');
  });
}
