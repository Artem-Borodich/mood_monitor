/// Motion and shape tokens for premium wellness UI.
abstract final class DsMotion {
  static const Duration page = Duration(milliseconds: 320);
  static const Duration tap = Duration(milliseconds: 180);
}

abstract final class DsRadii {
  static const double sm = 14;
  static const double md = 20;
  static const double lg = 28;
  static const double xl = 36;
  static const double pill = 999;
}

abstract final class DsSizes {
  /// Minimum touch target (WCAG-friendly).
  static const double minTap = 48;
  static const double fab = 64;
}
