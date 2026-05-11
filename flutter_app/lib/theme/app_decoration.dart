import 'package:flutter/material.dart';

import 'colors.dart';

/// Shared gradients and shadows for a more polished, production-like UI.
abstract final class AppDecorations {
  static LinearGradient scaffoldGradientLight(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(cs.surface, cs.primaryContainer, 0.22)!,
        Color.lerp(cs.surface, cs.secondaryContainer, 0.1)!,
        cs.surface,
      ],
      stops: const [0.0, 0.42, 1.0],
    );
  }

  static LinearGradient scaffoldGradientDark(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(cs.surface, cs.primary, 0.08)!,
        cs.surface,
        Color.lerp(cs.surface, cs.tertiary, 0.05)!,
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  static LinearGradient scaffoldGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? scaffoldGradientDark(context)
        : scaffoldGradientLight(context);
  }

  /// Layered soft shadow used under elevated cards.
  static List<BoxShadow> cardFloating(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ambient = dark
        ? Colors.black.withValues(alpha: 0.45)
        : const Color(0xFF2D1B69).withValues(alpha: 0.07);
    final tint = AppColors.seed.withValues(alpha: dark ? 0.2 : 0.1);
    return [
      BoxShadow(
        color: ambient,
        blurRadius: dark ? 28 : 22,
        offset: const Offset(0, 10),
        spreadRadius: dark ? 1 : 0,
      ),
      BoxShadow(
        color: tint,
        blurRadius: dark ? 40 : 36,
        offset: const Offset(0, 18),
        spreadRadius: -4,
      ),
    ];
  }

  static List<BoxShadow> cardSubtle(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (dark ? Colors.black : AppColors.textPrimary).withValues(alpha: dark ? 0.35 : 0.06),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ];
  }

  static Border? glassBorderLight(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) return null;
    return Border.all(
      color: Colors.white.withValues(alpha: 0.55),
      width: 1,
    );
  }

  static Border? glassBorderOnGradient(BuildContext context) {
    return Border.all(
      color: Colors.white.withValues(alpha: 0.28),
      width: 1.2,
    );
  }

  static LinearGradient primaryHeroGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF5B21F6),
        Color(0xFF7C3AED),
        Color(0xFFA78BFA),
      ],
      stops: [0.0, 0.45, 1.0],
    );
  }

  static LinearGradient wellbeingOrbGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF4C1D95),
        Color(0xFF6D28D9),
        Color(0xFF8B5CF6),
        Color(0xFFC4B5FD),
      ],
      stops: [0.0, 0.35, 0.7, 1.0],
    );
  }

  static LinearGradient riskCardGradient(BuildContext context, {required bool high}) {
    final cs = Theme.of(context).colorScheme;
    if (high) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(cs.errorContainer, cs.surface, 0.15)!,
          cs.surface,
        ],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(cs.primaryContainer, cs.surface, 0.2)!,
        Color.lerp(cs.tertiaryContainer, cs.surface, 0.35)!,
      ],
    );
  }
}
