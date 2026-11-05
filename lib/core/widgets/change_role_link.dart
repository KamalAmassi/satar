import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/l10n/app_localizations.dart';
import 'package:project/core/storage/session_store.dart';

/// رابط صغير «تغيير الدور» في صفحات الدخول: لا طريق مسدود.
class ChangeRoleLink extends StatelessWidget {
  const ChangeRoleLink({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Center(
      child: TextButton(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48), foregroundColor: c.tx2),
        onPressed: () async {
          await Get.find<SessionStore>().setChosenRole(null);
          Get.offAllNamed('/role');
        },
        child: Text(AppLocalizations.of(context)!.changeRole, style: T.sm(c.tx2).copyWith(decoration: TextDecoration.underline)),
      ),
    );
  }
}
