import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/design_tokens.dart';
import 'colors.dart';

/// Premium wellness Material 3 theme — [Plus Jakarta Sans] for modern app-store feel.
class AppTheme {
  AppTheme._();

  static ThemeData lightTheme(ColorScheme? scheme) {
    final cs = scheme ??
        ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          brightness: Brightness.light,
        ).copyWith(
          surface: AppColors.background,
          surfaceContainerLowest: const Color(0xFFFFFFFF),
          surfaceContainerLow: const Color(0xFFEEECF6),
          surfaceContainer: const Color(0xFFE8E5F2),
          surfaceContainerHigh: const Color(0xFFE0DCEC),
          surfaceContainerHighest: const Color(0xFFD7D2E4),
          outlineVariant: const Color(0xFFC9C4D8),
        );

    final base = ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      brightness: Brightness.light,
      splashFactory: InkSparkle.splashFactory,
    );

    final pj = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    final textTheme = pj.copyWith(
      displayLarge: pj.displayLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displayMedium: pj.displayMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
      displaySmall: pj.displaySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      headlineLarge: pj.headlineLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.25),
      headlineMedium: pj.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      headlineSmall: pj.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.15),
      titleLarge: pj.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: pj.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: pj.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: pj.bodyLarge?.copyWith(height: 1.45, fontWeight: FontWeight.w500),
      bodyMedium: pj.bodyMedium?.copyWith(height: 1.45),
      bodySmall: pj.bodySmall?.copyWith(height: 1.35),
      labelLarge: pj.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
    );

    return _components(base.copyWith(textTheme: textTheme), cs);
  }

  static ThemeData darkTheme(ColorScheme? scheme) {
    final cs = scheme ??
        ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF16141F),
          surfaceContainerLowest: const Color(0xFF0E0C14),
          surfaceContainerLow: const Color(0xFF1C1A26),
          surfaceContainer: const Color(0xFF24222F),
          surfaceContainerHigh: const Color(0xFF2C2938),
          surfaceContainerHighest: const Color(0xFF353244),
        );

    final base = ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      brightness: Brightness.dark,
      splashFactory: InkSparkle.splashFactory,
    );

    final pj = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    final textTheme = pj.copyWith(
      displayLarge: pj.displayLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displayMedium: pj.displayMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
      displaySmall: pj.displaySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      headlineLarge: pj.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: pj.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: pj.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: pj.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: pj.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: pj.bodyLarge?.copyWith(height: 1.45, fontWeight: FontWeight.w500),
      bodyMedium: pj.bodyMedium?.copyWith(height: 1.45),
      labelLarge: pj.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    return _components(base.copyWith(textTheme: textTheme), cs);
  }

  static ThemeData _components(ThemeData base, ColorScheme cs) {
    return base.copyWith(
      scaffoldBackgroundColor: cs.surface,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        indicatorColor: cs.primary.withValues(alpha: 0.18),
        backgroundColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((s) {
          return IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected) ? cs.primary : cs.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          return base.textTheme.labelMedium?.copyWith(
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? cs.primary : cs.onSurfaceVariant,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadii.pill)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadii.pill)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DsRadii.pill)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      sliderTheme: SliderThemeData(
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13, elevation: 2),
        trackHeight: 5,
        activeTrackColor: cs.primary,
        inactiveTrackColor: cs.surfaceContainerHighest,
        thumbColor: cs.primary,
        overlayColor: cs.primary.withValues(alpha: 0.12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerLow.withValues(alpha: 0.85),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: cs.primary, width: 1.8),
        ),
      ),
      listTileTheme: base.listTileTheme.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant.withValues(alpha: 0.45)),
    );
  }
}
