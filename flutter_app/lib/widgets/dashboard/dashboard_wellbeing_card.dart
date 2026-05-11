import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_decoration.dart';

class DashboardWellbeingCard extends StatelessWidget {
  const DashboardWellbeingCard({
    super.key,
    required this.title,
    required this.score,
    required this.subtitle,
    this.rawWellbeingIndex,
  });

  /// 0–100 ring fill (normalized from backend linear index).
  final String title;
  final double score;
  final String subtitle;
  final double? rawWellbeingIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final clamped = score.clamp(0, 100).toDouble();
    final r = BorderRadius.circular(28);

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
            Positioned(
              right: -40,
              top: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 168,
                      height: 168,
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
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: PieChart(
                              PieChartData(
                                startDegreeOffset: -90,
                                sectionsSpace: 0,
                                centerSpaceRadius: 56,
                                sections: [
                                  PieChartSectionData(
                                    value: clamped,
                                    color: Colors.white,
                                    radius: 11,
                                    title: '',
                                  ),
                                  PieChartSectionData(
                                    value: 100 - clamped,
                                    color: Colors.white.withValues(alpha: 0.22),
                                    radius: 11,
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
                              Text(
                                '${clamped.round()}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                  fontSize: 40,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '/ 100',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (rawWellbeingIndex != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        loc.dashboardWellbeingRawFormat(
                          rawWellbeingIndex!.toStringAsFixed(2),
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
