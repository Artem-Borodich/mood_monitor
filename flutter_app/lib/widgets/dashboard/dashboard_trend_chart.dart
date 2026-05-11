import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/mood_entry.dart';
import '../serenity_card.dart';
import '../stat_card.dart';

class DashboardTrendChart extends StatelessWidget {
  const DashboardTrendChart({
    super.key,
    required this.entries,
    required this.loc,
  });

  final List<MoodEntry> entries;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (entries.length < 2) {
      return StatCard(
        title: loc.dashboardMoodOverTime,
        value: loc.dashboardMoodNotEnough,
        subtitle: loc.dashboardMoodNotEnoughSubtitle,
      );
    }

    final sorted =
        [...entries]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final show = sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;

    if (show.length < 2) {
      return StatCard(
        title: loc.dashboardMoodOverTime,
        value: loc.dashboardMoodNotEnough,
        subtitle: loc.dashboardMoodNotEnoughSubtitle,
      );
    }

    final first = show.first;
    final last = show.last;

    final moodDelta = last.mood - first.mood;
    final trendText = moodDelta >= 2
        ? loc.moodJourneyTrendUp
        : moodDelta <= -2
            ? loc.moodJourneyTrendDown
            : loc.moodJourneyTrendSteady;

    final hasLowStressPattern = show.where((e) => e.stress <= 4).length >= 2;
    final hasActivityPattern = show.where((e) => (e.activityMinutes ?? 0) >= 15).length >= 2;

    final primaryInsight = hasLowStressPattern ? loc.moodJourneyStressHint : null;
    final secondaryInsight = hasActivityPattern ? loc.moodJourneyActivityHint : null;

    String dayLabel(DateTime d) {
      final code = Localizations.localeOf(context).languageCode;
      final fmt = DateFormat.E(code);
      final raw = fmt.format(d);
      return raw.length > 2 ? raw.substring(0, 2) : raw;
    }

    Color moodColor(int mood) {
      final t = ((mood - 1) / 9).clamp(0.0, 1.0);
      return Color.lerp(theme.colorScheme.primary, theme.colorScheme.tertiary, t) ??
          theme.colorScheme.primary;
    }

    Color stressBorderColor(int stress) {
      final t = ((stress - 1) / 9).clamp(0.0, 1.0);
      return Color.lerp(theme.colorScheme.outlineVariant, theme.colorScheme.error, t) ??
          theme.colorScheme.outlineVariant;
    }

    return SerenityCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                loc.moodJourneyTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              ),
              const Spacer(),
              Chip(
                label: Text(loc.tipsChipWeek),
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                backgroundColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.9),
                elevation: 1,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            loc.moodJourneySubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: show.map((e) {
              final moodT = ((e.mood - 1) / 9).clamp(0.0, 1.0);
              final stressT =
                  ((e.stress - 1) / 9).clamp(0.0, 1.0);
              final mc = moodColor(e.mood);
              final bc = stressBorderColor(e.stress).withValues(alpha: 0.8);
              final soft = mc.withValues(alpha: 0.16 + (moodT * 0.1));

              return Expanded(
                child: Tooltip(
                  message:
                      '${dayLabel(e.createdAt)} • ${loc.moodLabel} ${e.mood} • ${loc.stressLabel} ${e.stress}',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          dayLabel(e.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: soft,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: bc),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 10 + (moodT * 26),
                              width: double.infinity,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    mc.withValues(alpha: 0.5 + stressT * 0.2),
                                    mc,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            trendText,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.15,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              if (primaryInsight != null)
                _MiniInsight(
                  icon: Icons.self_improvement_rounded,
                  text: primaryInsight,
                ),
              if (secondaryInsight != null)
                _MiniInsight(
                  icon: Icons.directions_run_rounded,
                  text: secondaryInsight,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            loc.moodJourneyReflectionPrompt,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInsight extends StatelessWidget {
  const _MiniInsight({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
