import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../serenity_card.dart';

enum DailyCheckInMood { calm, tired, stressed, motivated }

class DashboardDailyCheckIn extends StatelessWidget {
  const DashboardDailyCheckIn({
    super.key,
    required this.onSelected,
    required this.busy,
  });

  final ValueChanged<DailyCheckInMood> onSelected;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    IconData iconFor(DailyCheckInMood m) {
      switch (m) {
        case DailyCheckInMood.calm:
          return Icons.self_improvement_rounded;
        case DailyCheckInMood.tired:
          return Icons.bedtime_rounded;
        case DailyCheckInMood.stressed:
          return Icons.spa_rounded;
        case DailyCheckInMood.motivated:
          return Icons.auto_graph_rounded;
      }
    }

    String labelFor(DailyCheckInMood m) {
      switch (m) {
        case DailyCheckInMood.calm:
          return loc.checkInOptionCalm;
        case DailyCheckInMood.tired:
          return loc.checkInOptionTired;
        case DailyCheckInMood.stressed:
          return loc.checkInOptionStressed;
        case DailyCheckInMood.motivated:
          return loc.checkInOptionMotivated;
      }
    }

    return SerenityCard(
      borderRadius: 28,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.dashboardCheckInTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.25,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final mood in DailyCheckInMood.values)
                  OutlinedButton(
                    onPressed: busy ? null : () => onSelected(mood),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(iconFor(mood), size: 18),
                        const SizedBox(width: 8),
                        Text(labelFor(mood)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

