import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
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

  String? _formatTargetDate(BuildContext context, String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    final lang = Localizations.localeOf(context).languageCode;
    return DateFormat.yMMMMd(lang).format(d);
  }

  String _levelLabel(AppLocalizations loc, ForecastPayload f) {
    return switch (f.label) {
      'elevated' => loc.dashboardRiskLevelHigh,
      'moderate' => loc.dashboardRiskLevelModerate,
      'low' => loc.dashboardRiskLevelLow,
      _ => loc.dashboardRiskLevelModerate,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final fp = forecast;
    final insufficient =
        fp != null && fp.status == 'insufficient_data';
    final hasForecast =
        fp != null && fp.status == 'ok' && fp.risk != null;
    final riskPct = hasForecast
        ? ((fp.risk ?? 0) * 100).round()
        : dashboardFallbackRiskPercent(latest);
    final isHigh = insufficient
        ? false
        : (hasForecast
            ? (fp.risk ?? 0) >= 0.55
            : riskPct >= 60);

    final explanation = insufficient
        ? (fp.explanation ?? loc.dashboardRiskExtraHeuristic)
        : hasForecast
            ? (fp.explanation ?? loc.dashboardRiskExtraForecast)
            : (forecastError ?? loc.dashboardRiskExtraHeuristic);

    final gradient = AppDecorations.riskCardGradient(context, high: isHigh);
    final accent = isHigh ? theme.colorScheme.error : theme.colorScheme.primary;

    final targetLine = hasForecast && fp.targetDate != null
        ? loc.dashboardRiskForDate(
            _formatTargetDate(context, fp.targetDate) ?? fp.targetDate!,
          )
        : null;

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
                              loc.dashboardRiskTitle,
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.88),
                          height: 1.45,
                        ),
                      ),
                      if (targetLine != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          targetLine,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (hasForecast &&
                          fp.factors != null &&
                          fp.factors!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          loc.dashboardRiskSignalsTitle,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...fp.factors!.map(
                          (factor) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    loc.dashboardRiskFactorLine(
                                      factor.name,
                                      factor.impact,
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        loc.dashboardRiskMethodNote,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (!insufficient) ...[
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
                                hasForecast
                                    ? _levelLabel(loc, fp)
                                    : (isHigh
                                        ? loc.dashboardRiskLevelHigh
                                        : (riskPct >= 35
                                            ? loc.dashboardRiskLevelModerate
                                            : loc.dashboardRiskLevelLow)),
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
                      ],
                      const SizedBox(height: 12),
                      Text(
                        insufficient
                            ? loc.dashboardRiskSuggestionInsufficient
                            : isHigh
                                ? loc.dashboardRiskSuggestionHigh
                                : loc.dashboardRiskSuggestionLow,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                          height: 1.4,
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
