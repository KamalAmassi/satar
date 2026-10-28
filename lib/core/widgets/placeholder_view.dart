import 'package:flutter/material.dart';

/// شاشة مؤقتة لحين بناء الشاشة الحقيقية.
class PlaceholderView extends StatelessWidget {
  const PlaceholderView({super.key, required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(routeName)),
      body: Center(child: Text(routeName)),
    );
  }
}