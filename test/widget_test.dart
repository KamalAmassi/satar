import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:project/core/routes/app_router.dart';
import 'package:project/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(preferences, permanent: true);
    await GetStorage.init();
  });

  tearDown(() async => Get.reset());

  testWidgets('Satr app starts successfully', (tester) async {
    // await tester.pumpWidget(const SatrApp(initialRoute: AppRouter.initial));
    await tester.pump();
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
