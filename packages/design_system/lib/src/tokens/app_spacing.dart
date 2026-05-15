/// Legacy 8-pt base used by the staff apps.
const double kspacing = 8.0;

/// 4-pt spacing scale per design.md §3.4: `2, 4, 8, 12, 16, 20, 24, 32, 40, 56, 80`.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double s = 8;
  static const double sm = 12;
  static const double m = 16;
  static const double ml = 20;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 56;
  static const double huge = 80;
}

class AppRadii {
  AppRadii._();

  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}
