import 'package:flutter/material.dart';

class WelcomeSuccessScreen extends StatelessWidget {
  const WelcomeSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(
          0xFF2D1F2B,
        ), // لون الخلفية الداكن المطابق للصورة
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // دائرة الأيقونة التي تحتوي على علامة الصح
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3E5D8), // لون بيج فاتح للدائرة
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 45,
                      color: Color(0xFF2D1F2B), // لون علامة الصح ليطابق الخلفية
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // العنوان الرئيسي
                const Text(
                  'نورت سطر!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // النص التوضيحي
                const Text(
                  'جاهز نبدأ؟',
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const Spacer(),
                // زر التالي السفلي
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFF3E5D8,
                      ), // لون الزر البيج
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1F2B), // لون النص الداكن داخل الزر
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
