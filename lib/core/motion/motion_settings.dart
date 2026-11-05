import 'package:flutter/widgets.dart';

/// إعدادات الحركة المستخلصة من النظام.
/// [reduceMotion] يتبع MediaQuery.disableAnimations، و[intensity] (0..1)
/// يُضرب في سعة أي تأثير حركي (0 = بلا حركة).
@immutable
class MotionSettings {
  const MotionSettings({required this.reduceMotion, this.intensity = 1});

  final bool reduceMotion;
  final double intensity;

  static MotionSettings of(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return MotionSettings(reduceMotion: reduce, intensity: reduce ? 0 : 1);
  }
}
