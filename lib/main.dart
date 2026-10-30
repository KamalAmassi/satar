import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/app/bindings/app_binding.dart';
import 'package:project/core/config/app_env.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/routes/app_router.dart';
import 'package:project/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);
  runApp(const SatrApp());
}

class SatrApp extends StatelessWidget {
  const SatrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'سطر',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      locale: Locale(AppEnv.locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      initialBinding: AppBinding(),
      initialRoute: AppRouter.initial,
      getPages: AppRouter.pages,
      unknownRoute: AppRouter.unknown,
    );
  }
}