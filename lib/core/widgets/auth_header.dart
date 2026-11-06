import 'package:flutter/material.dart';
import 'package:project/core/design/icons.dart';
import 'package:project/core/design/tokens.dart';
import 'package:project/core/motion/entrance.dart';

/// هوية الدور في صفحات الدخول: نفس بطاقة صفحة اختيار الدور (لون ناعم + إطار + رمز)
/// ثم عنوان ووصف قصير. الزبون = حقيبة/برقوق، السائق = شاحنة/عنبر.
enum AuthRole { customer, driver }

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.role, required this.title, required this.subtitle});
  final AuthRole role;
  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final driver = role == AuthRole.driver;
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Entrance(
        index: 0,
        child: Center(
          child: ExcludeSemantics(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: driver ? c.amberSoft : c.plumSoft,
                borderRadius: BorderRadius.circular(Rad.l),
                border: Border.all(color: driver ? c.amber : c.pri, width: 1.5),
              ),
              child: Center(child: SIcon(driver ? 'truck' : 'bag', size: 34, color: driver ? c.amberInk : c.plumInk)),
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Entrance(index: 1, child: Semantics(header: true, child: Text(title, textAlign: TextAlign.center, style: T.d2(c.tx)))),
      const SizedBox(height: 8),
      Entrance(index: 1, child: Text(subtitle, textAlign: TextAlign.center, style: T.bd(c.tx2))),
    ]);
  }
}

/// بطاقة الحقول المشتركة بين صفحتي الدخول.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(Rad.l), border: Border.all(color: c.ln)),
      child: child,
    );
  }
}
