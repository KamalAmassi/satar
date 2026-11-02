import 'package:flutter/material.dart';
import 'package:ui_poject/screens/CategoriesScreen.dart';
import 'package:ui_poject/screens/CategoryProductsScreen.dart';
import 'package:ui_poject/screens/SearchScreen.dart';
import 'package:ui_poject/screens/completeprofile.dart';
import 'package:ui_poject/screens/homescreen.dart';
import 'package:ui_poject/screens/phonescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدم GetMaterialApp بدلاً من MaterialApp لتفعيل ميزات GetX
    return MaterialApp(
      title: 'سطر',
      debugShowCheckedModeBanner: false,
      home: const SearchScreen(),
    );
  }
}
