import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester, Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  Get.put<SharedPreferences>(
    await SharedPreferences.getInstance(),
    permanent: true,
  );
  await tester.pumpWidget(const SatrApp());
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);

  testWidgets('App starts on the splash screen', (tester) async {
    await _pumpApp(tester, {});

    expect(Get.currentRoute, SharedRoutes.splash);
    expect(find.text('كل احتياجاتك، بسطر واحد'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
  });

  testWidgets('Continue opens onboarding on first launch', (tester) async {
    await _pumpApp(tester, {});

    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, SharedRoutes.onboarding);
  });

  testWidgets('Continue skips to role choice once onboarding was seen',
      (tester) async {
    await _pumpApp(tester, {'onboarding_seen': true});

    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, SharedRoutes.roleChoice);
  });
}
