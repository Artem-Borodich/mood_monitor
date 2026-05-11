import 'package:flutter/material.dart';

import '../../models/forecast_payload.dart';
import '../../models/mood_entry.dart';
import '../../theme/app_decoration.dart';

int dashboardFallbackRiskPercent(MoodEntry? latest) {
  if (latest == null) return 50;
  final stress = latest.stress * 8;
  final sleepPenalty = ((7 - (latest.sleepHours ?? 7)).clamp(0, 7) * 6).round();
  return (stress + sleepPenalty).clamp(20, 90);
}

class DashboardRiskCard extends StatelessWidget {
  const DashboardRiskCard({
    super.key,
    required this.forecast,
    this.forecastError,
    required this.latest,
  });

  final ForecastPayload? forecast;
  final String? forecastError;
  final MoodEntry? latest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = forecast;
    final hasForecast = f != null && f.status == 'ok';
    final riskPct = hasForecast
        ? ((f.risk ?? 0) * 100).round()
        : dashboardFallbackRiskPercent(latest);
    final isHigh = riskPct >= 60;
    final explanation = hasForecast
        ? (f.explanation ?? 'Based on your recent patterns')
        : (forecastError ?? 'Based on sleep and stress patterns');

    final gradient = AppDecorations.riskCardGradient(context, high: isHigh);
    final accent = isHigh ? theme.colorScheme.error : theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: gradient,
        border: Border.all(
          color: accent.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: AppDecorations.cardFloating(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accent,
                      accent.withValues(alpha: 0.45),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.55),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.shield_moon_outlined,
                              color: accent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Next Day Risk',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        explanation,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$riskPct%',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              isHigh ? 'HIGH RISK' : 'MODERATE',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: riskPct / 100,
                          minHeight: 10,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.85),
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isHigh
                            ? '"Consider a 10-minute meditation before bed to lower this risk."'
                            : '"Keep your current routine and finish the day gently."',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
