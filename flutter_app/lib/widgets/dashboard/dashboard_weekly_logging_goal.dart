import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/mood_entry.dart';
import '../../design_system/aura_card.dart';
import '../../theme/app_spacing.dart';

/// Monday–Sunday week: count distinct local days with at least one mood entry.
class DashboardWeeklyLoggingGoal extends StatelessWidget {
  const DashboardWeeklyLoggingGoal({
    super.key,
    required this.entries,
    required this.loc,
  });

  final List<MoodEntry> entries;
  final AppLocalizations loc;

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static DateTime _mondayOfWeekContaining(DateTime d) {
    final day = _dateOnly(d);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final now = DateTime.now();
    final monday = _mondayOfWeekContaining(now);
    final sunday = monday.add(const Duration(days: 6));

    final daysWithEntry = <DateTime>{};
    for (final e in entries) {
      final local = e.createdAt.toLocal();
      final d = _dateOnly(local);
      if (!d.isBefore(monday) && !d.isAfter(sunday)) {
        daysWithEntry.add(d);
      }
    }

    var filled = 0;
    for (var i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      if (daysWithEntry.contains(day)) filled++;
    }

    final isComplete = filled >= 7;

    return AuraCard(
      borderRadius: AppSpacing.radiusCard,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.dashboardWeeklyGoalTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.dashboardWeeklyGoalProgress(filled),
            style: theme.textTheme.bodySmall?.copyWith(
              color: muted,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(7, (i) {
              final day = monday.add(Duration(days: i));
              final has = daysWithEntry.contains(day);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 6 ? 4 : 0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: has
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (isComplete) ...[
            const SizedBox(height: 8),
            Text(
              loc.dashboardWeeklyGoalComplete,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
