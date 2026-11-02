import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:project/core/constants/app_colors.dart';
import 'package:project/driver/shared/presentation/driver_ui.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/widgets/app_button.dart';
import 'package:project/driver/features/auth/presentation/controllers/auth_controller.dart';
import 'package:project/driver/features/auth/presentation/widgets/field_label.dart';
import 'package:project/driver/features/auth/presentation/widgets/header_driver.dart';

class DriverLoginView extends GetView<DriverAuthController> {
  const DriverLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBFA), // خلفية الفيجما العاجية الناعمة
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerDriver(l10n),
                const SizedBox(height: 24),
                _buildTopCard(),
                const SizedBox(height: 32),

                Text(
                  l10n.welcomeBack,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1B20)),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.loginSubtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                FieldLabel(l10n.phoneNumberLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: AppInputDecoration.loginStyle(
                    hintText: '5X XXX XXXX',
                    prefixIcon: _buildCountryPicker(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.phoneValidationError
                      : null,
                ),
                const SizedBox(height: 24),

                FieldLabel(l10n.passwordLabel),
                const SizedBox(height: 8),
                Obx(() => TextFormField(
                      controller: controller.passwordController,
                      obscureText: !controller.isPasswordVisible.value,
                      decoration: AppInputDecoration.loginStyle(
                        hintText: l10n.enterPasswordHint,
                        suffixIcon: _buildPasswordVisibilityToggle(l10n),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? l10n.passwordValidationError
                              : null,
                    )),
                const SizedBox(
                    height: 24), // مسافة عمودية دقيقة متناسقة مع الصور

                Obx(() {
                  if (!controller.hasError.value) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: DriverUi.dangerBg, // وردي فاتح مطابق لكرت الخطأ بالتصميم
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      controller.errorMessage.value ?? l10n.authInvalidCredentialsError,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.error, // لون نص أحمر تحذيري متناسق
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  );
                }),

                // ⏳ زر تسجيل الدخول التفاعلي التلقائي بحالتيه العادية والتحميل (D02) داخل الزر نفسه
                Obx(() {
                  if (controller.isLoading.value) {
                    // حالة التحميل (D02): زر بلون رمادي مطفأ وبداخله نص جاري التحميل مع الـ Loader الدائري
                    return Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark.withOpacity(
                            0.38), // لون رمادي مطفأ معطل عن اللمس للتحميل
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.loggingInStatus,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // الحالة الطبيعية للزر باللون الباذنجاني الداكن
                    return AppButton(
                      label: l10n.loginButton,
                      onPressed: () => controller.login(),
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(28)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined,
                size: 42, color: AppColors.border),
            const SizedBox(height: 8),
            Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 4),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10))),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryPicker() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.border, width: 1))),
      child: CountryCodePicker(
        onChanged: (_) {},
        initialSelection: 'PS',
        favorite: const ['PS', 'JO', 'EG'],
        showCountryOnly: false,
        showOnlyCountryWhenClosed: false,
        alignLeft: false,
        textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D1B20)),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildPasswordVisibilityToggle(AppLocalizations l10n) {
    return TextButton(
      onPressed: () => controller.isPasswordVisible.toggle(),
      style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16)),
      child: Text(
        controller.isPasswordVisible.value
            ? l10n.hidePassword
            : l10n.showPassword,
        style: const TextStyle(
            color: Color(0xFF1D1B20),
            fontWeight: FontWeight.w500,
            fontSize: 14),
      ),
    );
  }
}

/// كلاس مخصص لتوحيد تصميم الحقول (Input Decoration) لمنع التكرار
class AppInputDecoration {
  static InputDecoration loginStyle(
      {required String hintText, Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: _buildBorder(AppColors.border),
      enabledBorder: _buildBorder(AppColors.border),
      focusedBorder: _buildBorder(AppColors.primaryLight),
    );
  }

  static OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}
