import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/errors/failure.dart';
import 'package:project/core/routes/app_routes.dart';
import 'package:project/driver/features/auth/domain/usecases/login_driver_usecase.dart';
import 'package:project/driver/features/auth/domain/usecases/logout_driver_usecase.dart';

class DriverAuthController extends GetxController {
  DriverAuthController({
    required this.loginDriverUseCase,
    required this.logoutDriverUseCase,
  });

  final LoginDriverUseCase loginDriverUseCase;
  final LogoutDriverUseCase logoutDriverUseCase;

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final hasError = false.obs;

  /// رسالة الخطأ الفعلية من السيرفر/الشبكة (null = استخدم الرسالة الافتراضية).
  final errorMessage = RxnString();
  final isPasswordVisible = false.obs;

  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    hasError.value = false;
    errorMessage.value = null;

    if (loginFormKey.currentState?.validate() != true) return;

    isLoading.value = true;
    try {
      final result = await loginDriverUseCase.call(
        LoginDriverParams(
          phone: phoneController.text.trim(),
          password: passwordController.text,
        ),
      );

      result.fold(
        (failure) {
          hasError.value = true;
          // بيانات خاطئة (401/422) = رسالة بيانات الدخول الافتراضية؛ غير ذلك رسالة السيرفر/الشبكة.
          final credentials = failure is UnauthorizedFailure || failure is ValidationFailure;
          errorMessage.value = credentials ? null : failure.message;
        },
        (success) {
          if (success) Get.offAllNamed(DriverRoutes.home);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// يُستدعى من زر تسجيل الخروج في واجهة السائق.
  Future<void> logout() async {
    isLoading.value = true;
    try {
      final result = await logoutDriverUseCase.call();
      result.fold(
        (failure) {
          // المستودع يمسح التوكن محلياً حتى لو فشل الاتصال بالسيرفر.
          Get.snackbar('تنبيه', failure.message ?? 'تم تسجيل الخروج محلياً.');
        },
        (_) {},
      );
      Get.offAllNamed(DriverRoutes.login);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
