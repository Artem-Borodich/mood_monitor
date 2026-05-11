import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/mood_entry.dart';
import '../../theme/app_decoration.dart';
import '../serenity_card.dart';

class DashboardQuickLogCard extends StatelessWidget {
  const DashboardQuickLogCard({
    super.key,
    required this.last,
    required this.loc,
    required this.onOpenSheet,
  });

  final MoodEntry last;
  final AppLocalizations loc;
  final VoidCallback onOpenSheet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mixSurface =
        theme.brightness == Brightness.dark ? theme.colorScheme.surface : Colors.white;
    return SerenityCard(
      glassBorder: true,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(theme.colorScheme.primaryContainer, mixSurface, 0.12)!,
          Color.lerp(theme.colorScheme.tertiaryContainer, theme.colorScheme.surface, 0.08)!,
          theme.colorScheme.surface.withValues(alpha: theme.brightness == Brightness.dark ? 0.88 : 0.94),
        ],
        stops: const [0.0, 0.55, 1.0],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppDecorations.primaryHeroGradient(),
                  boxShadow: AppDecorations.cardSubtle(context),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.flash_on_rounded, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.quickLogTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      loc.quickLogSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetricPill(
                icon: Icons.sentiment_satisfied_rounded,
                label: loc.moodLabel,
                value: last.mood,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              _MetricPill(
                icon: Icons.local_fire_department_rounded,
                label: loc.stressLabel,
                value: last.stress,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 10),
              _MetricPill(
                icon: Icons.bolt_rounded,
                label: loc.energyLabel,
                value: last.energy,
                color: theme.colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: AppDecorations.primaryHeroGradient(),
              boxShadow: AppDecorations.cardSubtle(context),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpenSheet,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          loc.quickLogPrimaryCta,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
