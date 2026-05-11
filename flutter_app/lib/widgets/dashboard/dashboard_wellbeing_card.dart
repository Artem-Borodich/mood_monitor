import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_decoration.dart';
import '../../utils/wellbeing_math.dart';
import '../illustrations/soft_bloom_painter.dart';

class DashboardWellbeingCard extends StatelessWidget {
  const DashboardWellbeingCard({
    super.key,
    required this.title,
    required this.score,
    required this.hasWellbeingData,
    this.wellbeingIndex,
  });

  final String title;
  final double score;
  final bool hasWellbeingData;
  final double? wellbeingIndex;

  static double _ringDiameter(double cardWidth) {
    return (cardWidth * 0.42).clamp(132.0, 188.0);
  }

  static double _typeLayoutScale(double cardWidth) {
    return (cardWidth / 360).clamp(0.9, 1.08);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final clamped = score.clamp(0, 100).toDouble();
    final r = BorderRadius.circular(28);
    final displayPct = formatWellbeingPercentDisplay(clamped, hasWellbeingData);

    late final String headline;
    late final String hint;
    if (!hasWellbeingData || wellbeingIndex == null) {
      headline = loc.dashboardWellbeingEmptyHeadline;
      hint = loc.dashboardWellbeingSubtitleEmpty;
    } else {
      switch (wellbeingTierFromIndex(wellbeingIndex!)) {
        case WellbeingTier.high:
          headline = loc.wellbeingStateHigh;
          hint = loc.wellbeingHintHigh;
        case WellbeingTier.medium:
          headline = loc.wellbeingStateMedium;
          hint = loc.wellbeingHintMedium;
        case WellbeingTier.low:
          headline = loc.wellbeingStateLow;
          hint = loc.wellbeingHintLow;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = constraints.maxWidth;
        final ring = _ringDiameter(cardW);
        final tScale = _typeLayoutScale(cardW);
        final hPad = (18 + cardW * 0.02).clamp(16.0, 26.0);
        final vPad = (18 + cardW * 0.015).clamp(16.0, 24.0);
        final centerSpace = ring * 0.33;
        final sectionRadius = ring * 0.065;

        final titleFs = ((theme.textTheme.titleMedium?.fontSize ?? 16) * tScale)
            .clamp(14.0, 19.0);
        final headlineFs = ((theme.textTheme.titleLarge?.fontSize ?? 22) * tScale)
            .clamp(17.0, 26.0);
        final hintFs = ((theme.textTheme.bodyMedium?.fontSize ?? 14) * tScale)
            .clamp(12.5, 16.5);
        final bigNumFs = (42 * tScale).clamp(30.0, 48.0);
        final ringLabelFs = ((theme.textTheme.titleSmall?.fontSize ?? 14) * tScale)
            .clamp(11.5, 15.0);
        final scaleTitleFs = ((theme.textTheme.labelLarge?.fontSize ?? 14) * tScale)
            .clamp(11.0, 14.5);
        final footnoteFs = ((theme.textTheme.bodySmall?.fontSize ?? 12) * tScale)
            .clamp(10.5, 13.5);

        final content = Padding(
          padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad - 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _scaledFittedText(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.15,
                  fontSize: titleFs,
                  height: 1.2,
                ),
              ),
              SizedBox(height: (8 * tScale).clamp(6.0, 12.0)),
              _scaledFittedText(
                headline,
                textAlign: TextAlign.center,
                maxLines: 3,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  height: 1.15,
                  fontSize: headlineFs,
                ),
              ),
              SizedBox(height: (6 * tScale).clamp(4.0, 10.0)),
              _scaledFittedText(
                hint,
                textAlign: TextAlign.center,
                maxLines: 5,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.38,
                  fontWeight: FontWeight.w600,
                  fontSize: hintFs,
                ),
              ),
              SizedBox(height: (16 * tScale).clamp(12.0, 22.0)),
              SizedBox(
                width: ring,
                height: ring,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: (20 * tScale).clamp(16.0, 28.0),
                            offset: Offset(0, (8 * tScale).clamp(6.0, 12.0)),
                          ),
                        ],
                      ),
                      child: PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 0,
                          centerSpaceRadius: centerSpace,
                          sections: [
                            PieChartSectionData(
                              value: hasWellbeingData ? clamped : 0.01,
                              color: Colors.white,
                              radius: sectionRadius,
                              title: '',
                            ),
                            PieChartSectionData(
                              value: hasWellbeingData ? (100 - clamped) : 99.99,
                              color: Colors.white.withValues(alpha: 0.22),
                              radius: sectionRadius,
                              title: '',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            displayPct,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              fontSize: bigNumFs,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 2 * tScale),
                        _scaledFittedText(
                          loc.dashboardWellbeingRingLabel,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                            fontSize: ringLabelFs,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasWellbeingData) ...[
                SizedBox(height: (14 * tScale).clamp(10.0, 18.0)),
                _scaledFittedText(
                  loc.dashboardWellbeingScaleTitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w800,
                    fontSize: scaleTitleFs,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: (7 * tScale).clamp(5.0, 10.0)),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: (7 * tScale).clamp(5.0, 10.0),
                  runSpacing: (5 * tScale).clamp(4.0, 8.0),
                  children: [
                    _ZoneChip(
                      label: loc.dashboardWellbeingZoneLowShort,
                      active: clamped <= 33,
                      fontSize: ((theme.textTheme.labelSmall?.fontSize ?? 11) * tScale)
                          .clamp(9.5, 12.5),
                    ),
                    _ZoneChip(
                      label: loc.dashboardWellbeingZoneMidShort,
                      active: clamped > 33 && clamped <= 66,
                      fontSize: ((theme.textTheme.labelSmall?.fontSize ?? 11) * tScale)
                          .clamp(9.5, 12.5),
                    ),
                    _ZoneChip(
                      label: loc.dashboardWellbeingZoneHighShort,
                      active: clamped > 66,
                      fontSize: ((theme.textTheme.labelSmall?.fontSize ?? 11) * tScale)
                          .clamp(9.5, 12.5),
                    ),
                  ],
                ),
                SizedBox(height: (8 * tScale).clamp(6.0, 12.0)),
                _scaledFittedText(
                  loc.dashboardWellbeingScaleFootnote,
                  textAlign: TextAlign.center,
                  maxLines: 8,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.38,
                    fontSize: footnoteFs,
                  ),
                ),
              ],
            ],
          ),
        );

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: r,
            gradient: AppDecorations.wellbeingOrbGradient(),
            border: AppDecorations.glassBorderOnGradient(context),
            boxShadow: AppDecorations.cardFloating(context),
          ),
          child: ClipRRect(
            borderRadius: r,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: SoftBloomPainter(
                      color: Colors.white,
                      spread: 0.85 + 0.05 * tScale,
                    ),
                  ),
                ),
                Positioned(
                  right: -40 * tScale,
                  top: -28 * tScale,
                  child: Container(
                    width: (150 * tScale).clamp(120.0, 170.0),
                    height: (150 * tScale).clamp(120.0, 170.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  left: -18 * tScale,
                  bottom: -36 * tScale,
                  child: Container(
                    width: (115 * tScale).clamp(90.0, 130.0),
                    height: (115 * tScale).clamp(90.0, 130.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: MediaQuery.textScalerOf(context).clamp(
                      minScaleFactor: 0.88,
                      maxScaleFactor: 1.28,
                    ),
                  ),
                  child: content,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Keeps long localized strings readable on narrow / scaled text.
  static Widget _scaledFittedText(
    String text, {
    required TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    int maxLines = 1,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w <= 0) {
          return Text(text, style: style, textAlign: textAlign, maxLines: maxLines);
        }
        return SizedBox(
          width: w,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: w),
              child: Text(
                text,
                textAlign: textAlign,
                maxLines: maxLines,
                softWrap: true,
                style: style,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ZoneChip extends StatelessWidget {
  const _ZoneChip({
    required this.label,
    required this.active,
    required this.fontSize,
  });

  final String label;
  final bool active;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      constraints: const BoxConstraints(maxWidth: 118),
      padding: EdgeInsets.symmetric(
        horizontal: math.max(7, fontSize * 0.75),
        vertical: math.max(5, fontSize * 0.45),
      ),
      decoration: BoxDecoration(
        color: active
            ? Colors.white.withValues(alpha: 0.28)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? Colors.white.withValues(alpha: 0.65)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: active ? 1 : 0.85),
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}
