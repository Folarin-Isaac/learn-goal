import 'package:flutter/services.dart';

// selection = small choices, success = a step completing, error = a
// failed attempt. Primary CTA buttons skip haptics so it stays meaningful.
class AppHaptics {
  const new();

  static void selection() => HapticFeedback.selectionClick();
  static void success() => HapticFeedback.lightImpact();
  static void error() => HapticFeedback.mediumImpact();
}
