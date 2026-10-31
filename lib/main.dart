import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/routes/app_router.dart';
import 'package:project/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);

  // مؤقت: يُستبدل بـ core/network عند بنائه.
  Get.put<Dio>(
    Dio(
      BaseOptions(
        baseUrl: 'https://masar.toldpath.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'ar',
          'X-Project-Key': 'pk_test_fFiQyTDZSHzrbtj9O2uz9yHo0FMYOS4XG1MBbYwa',
          'X-Dev-Member': 'postman',
        },
      ),
    ),
    permanent: true,
  );
  await dotenv.load(fileName: '.env');

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
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      initialRoute: AppRouter.initial,
      getPages: AppRouter.pages,
      unknownRoute: AppRouter.unknown,
    );
  }
}