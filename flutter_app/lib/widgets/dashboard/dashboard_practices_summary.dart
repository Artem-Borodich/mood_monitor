import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_decoration.dart';
import '../illustrations/soft_bloom_painter.dart';

/// Tracks check-in + five quick actions (same keys as [DashboardQuickWellnessScroller]).
const int kDashboardPracticeSlotCount = 6;

int countDashboardPracticeSlotsDone(Set<String> keys) {
  var n = 0;
  if (keys.any((k) => k.startsWith('checkin:'))) n++;
  const quick = [
    'quick:breathing',
    'quick:journal',
    'quick:stretch',
    'quick:water',
    'quick:walk',
  ];
  for (final q in quick) {
    if (keys.contains(q)) n++;
  }
  return n;
}

class _Slot {
  const _Slot({
    required this.match,
    required this.icon,
    required this.label,
  });

  final bool Function(Set<String> keys) match;
  final IconData icon;
  final String Function(AppLocalizations loc) label;
}

class DashboardPracticesSummary extends StatelessWidget {
  const DashboardPracticesSummary({
    super.key,
    required this.completedKeysToday,
    required this.streakDays,
    required this.loc,
  });

  final Set<String> completedKeysToday;
  final int streakDays;
  final AppLocalizations loc;

  static final List<_Slot> _slots = [
    _Slot(
      match: (k) => k.any((e) => e.startsWith('checkin:')),
      icon: Icons.favorite_rounded,
      label: (l) => l.dashboardPracticeCheckin,
    ),
    _Slot(
      match: (k) => k.contains('quick:breathing'),
      icon: Icons.air_rounded,
      label: (l) => l.quickActionBreathing,
    ),
    _Slot(
      match: (k) => k.contains('quick:journal'),
      icon: Icons.edit_note_rounded,
      label: (l) => l.quickActionJournal,
    ),
    _Slot(
      match: (k) => k.contains('quick:stretch'),
      icon: Icons.self_improvement_rounded,
      label: (l) => l.quickActionStretch,
    ),
    _Slot(
      match: (k) => k.contains('quick:water'),
      icon: Icons.water_drop_rounded,
      label: (l) => l.quickActionWater,
    ),
    _Slot(
      match: (k) => k.contains('quick:walk'),
      icon: Icons.directions_walk_rounded,
      label: (l) => l.quickActionWalk,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final done = countDashboardPracticeSlotsDone(completedKeysToday);
    final progress = done / kDashboardPracticeSlotCount;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: SoftBloomPainter(color: cs.primary, spread: 1.05),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primaryContainer.withValues(alpha: 0.55),
                  cs.surfaceContainerLow.withValues(alpha: 0.92),
                  cs.tertiaryContainer.withValues(alpha: 0.35),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.45),
              ),
              boxShadow: AppDecorations.cardFloating(context),
            ),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: cs.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.dashboardPracticesTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.dashboardPracticesTracking,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          loc.dashboardPracticesProgress(done, kDashboardPracticeSlotCount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.primary,
                          ),
                        ),
                        if (streakDays > 0) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade400.withValues(alpha: 0.9),
                                  Colors.deepOrange.shade400.withValues(alpha: 0.85),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  loc.dashboardPracticesStreak(streakDays),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.85),
                        color: cs.primary,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _slots.map((s) {
                    final ok = s.match(completedKeysToday);
                    return _PracticeChip(
                      icon: s.icon,
                      label: s.label(loc),
                      done: ok,
                    );
                  }).toList(),
                ),
                if (done == 0 && streakDays == 0) ...[
                  const SizedBox(height: 10),
                  Text(
                    loc.dashboardPracticesEncourage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeChip extends StatelessWidget {
  const _PracticeChip({
    required this.icon,
    required this.label,
    required this.done,
  });

  final IconData icon;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 72, maxWidth: 104),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: done
              ? cs.primary.withValues(alpha: 0.22)
              : cs.surfaceContainerHighest.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: done
                ? cs.primary.withValues(alpha: 0.55)
                : cs.outlineVariant.withValues(alpha: 0.5),
            width: done ? 2 : 1,
          ),
          boxShadow: done
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: done ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.72),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: done ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
