import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  const FieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1D1B20)),
    );
  }
}