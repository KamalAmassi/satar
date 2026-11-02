import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/app/bindings/app_binding.dart';
import 'package:project/app/router.dart';
import 'package:project/core/config/app_env.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/shell.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);
  runApp(SatrApp(initialLocale: prefs.getString('locale') ?? AppEnv.locale));
}

class SatrApp extends StatelessWidget {
  const SatrApp({super.key, required this.initialLocale});
  final String initialLocale;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'سطر',
      theme: SatrTheme.build(Brightness.light),
      darkTheme: SatrTheme.build(Brightness.dark),
      themeMode: ThemeMode.system,
      locale: Locale(initialLocale),
      fallbackLocale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      initialBinding: AppBinding(),
      initialRoute: '/',
      getPages: AppRouter.pages,
      unknownRoute: AppRouter.unknown,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 260),
      builder: (context, child) => MediaQuery.withClampedTextScaling(minScaleFactor: 1.0, maxScaleFactor: 1.3, child: OfflineBanner(child: child ?? const SizedBox())),
    );
  }
}

/// بنر علوي دائم عند انقطاع الإنترنت (لا يخفي المحتوى المخزّن).
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child});
  final Widget child;
  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool offline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then(_set);
    _sub = Connectivity().onConnectivityChanged.listen(_set);
  }

  void _set(List<ConnectivityResult> r) {
    final off = r.isEmpty || r.every((e) => e == ConnectivityResult.none);
    if (off != offline && mounted) setState(() => offline = off);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<SatrColors>() ?? SatrColors.light;
    return Column(children: [
      if (offline)
        Material(
          color: c.amberSoft,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                SIcon('wifiOff', size: 18, color: c.amberInk),
                const SizedBox(width: 10),
                Expanded(child: Text('لا يوجد اتصال بالإنترنت. تُعرض آخر بيانات محفوظة.', style: TextStyle(fontFamily: Fonts.ui, fontSize: 13, fontWeight: FontWeight.w600, color: c.amberInk, decoration: TextDecoration.none))),
              ]),
            ),
          ),
        ),
      Expanded(child: widget.child),
    ]);
  }
}
