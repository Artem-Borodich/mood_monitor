import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Serenity design system with Manrope typography.
class AppTheme {
  AppTheme._();

  static const Color _seed = AppColors.primary;

  static ThemeData lightTheme(ColorScheme? scheme) {
    final cs = scheme ??
        ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.light,
          surface: AppColors.background,
        );

    final base = ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      brightness: Brightness.light,
    );

    final manrope = GoogleFonts.manropeTextTheme(base.textTheme);
    final textTheme = manrope.copyWith(
      headlineLarge: manrope.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: manrope.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: manrope.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: manrope.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: manrope.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );

    return _components(base.copyWith(textTheme: textTheme), cs);
  }

  static ThemeData darkTheme(ColorScheme? scheme) {
    final cs = scheme ??
        ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        );

    final base = ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    final manrope = GoogleFonts.manropeTextTheme(base.textTheme);
    final textTheme = manrope.copyWith(
      headlineLarge: manrope.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: manrope.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: manrope.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: manrope.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: manrope.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );

    return _components(base.copyWith(textTheme: textTheme), cs);
  }

  static ThemeData _components(ThemeData base, ColorScheme cs) {
    return base.copyWith(
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 4,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        indicatorColor: cs.primaryContainer,
        backgroundColor: cs.surface,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
      listTileTheme: base.listTileTheme.copyWith(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant.withValues(alpha: 0.5)),
    );
  }
}
