import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const Duration tap = Duration(milliseconds: 120);
  static const Duration transition = Duration(milliseconds: 240);
  static const Duration ambient = Duration(milliseconds: 480);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Honors [MediaQuery.disableAnimations]. Use this everywhere instead of
  /// the raw [Duration] constants to make reduce-motion mode collapse cleanly.
  static Duration effectiveDuration(BuildContext context, Duration d) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;
  }

  static Curve effectiveCurve(BuildContext context, Curve c) {
    return MediaQuery.disableAnimationsOf(context) ? Curves.linear : c;
  }
}
