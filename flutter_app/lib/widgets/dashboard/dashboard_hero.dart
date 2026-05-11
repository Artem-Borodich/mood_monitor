import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../design_system/aura_card.dart';
import '../../design_system/design_tokens.dart';
import '../../l10n/app_localizations.dart';

class DashboardHero extends StatelessWidget {
  const DashboardHero({
    super.key,
    required this.loc,
    this.lastMood,
    this.hasEntries = true,
  });

  final AppLocalizations loc;
  final int? lastMood;
  final bool hasEntries;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return loc.dashboardGreetingEvening;
    if (h < 12) return loc.dashboardGreetingMorning;
    if (h < 17) return loc.dashboardGreetingAfternoon;
    return loc.dashboardGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = Localizations.localeOf(context).languageCode;
    final dateLine = DateFormat.yMMMMEEEEd(code).format(DateTime.now());

    return AuraCard(
      borderRadius: DsRadii.xl,
      glassBorder: true,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.95),
          theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
          theme.colorScheme.surface.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.45, 1.0],
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateLine,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (lastMood != null && hasEntries)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(DsRadii.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('😊', style: theme.textTheme.titleMedium),
                      const SizedBox(width: 6),
                      Text(
                        '${loc.moodLabel} $lastMood',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            loc.dashboardHeroSub,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
