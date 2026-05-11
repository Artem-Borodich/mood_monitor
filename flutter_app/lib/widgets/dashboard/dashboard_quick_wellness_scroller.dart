import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../design_system/aura_card.dart';

enum QuickWellnessAction { breathing, journal, stretch, water, walk }

class DashboardQuickWellnessScroller extends StatelessWidget {
  const DashboardQuickWellnessScroller({
    super.key,
    required this.onSelected,
    required this.completedActionKeysToday,
    this.busyWalk = false,
    this.busyJournal = false,
  });

  final ValueChanged<QuickWellnessAction> onSelected;
  final Set<String> completedActionKeysToday;
  final bool busyWalk;
  final bool busyJournal;

  String _actionKey(QuickWellnessAction a) {
    return switch (a) {
      QuickWellnessAction.breathing => 'quick:breathing',
      QuickWellnessAction.journal => 'quick:journal',
      QuickWellnessAction.stretch => 'quick:stretch',
      QuickWellnessAction.water => 'quick:water',
      QuickWellnessAction.walk => 'quick:walk',
    };
  }

  IconData _iconFor(QuickWellnessAction a) {
    return switch (a) {
      QuickWellnessAction.breathing => Icons.air_rounded,
      QuickWellnessAction.journal => Icons.edit_note_rounded,
      QuickWellnessAction.stretch => Icons.self_improvement_rounded,
      QuickWellnessAction.water => Icons.water_drop_rounded,
      QuickWellnessAction.walk => Icons.directions_walk_rounded,
    };
  }

  String _labelFor(BuildContext context, QuickWellnessAction a) {
    final loc = AppLocalizations.of(context);
    return switch (a) {
      QuickWellnessAction.breathing => loc.quickActionBreathing,
      QuickWellnessAction.journal => loc.quickActionJournal,
      QuickWellnessAction.stretch => loc.quickActionStretch,
      QuickWellnessAction.water => loc.quickActionWater,
      QuickWellnessAction.walk => loc.quickActionWalk,
    };
  }

  bool _busyFor(QuickWellnessAction a) {
    return switch (a) {
      QuickWellnessAction.walk => busyWalk,
      QuickWellnessAction.journal => busyJournal,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final actions = QuickWellnessAction.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.dashboardQuickActionsTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.25,
              ),
        ),
        const SizedBox(height: AppSpacing.titleToContent),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (ctx, idx) {
              final a = actions[idx];
              final key = _actionKey(a);
              final done = completedActionKeysToday.contains(key);

              return AuraCard(
                borderRadius: 26,
                padding: const EdgeInsets.all(16),
                onTap: _busyFor(a) ? null : () => onSelected(a),
                glassBorder: true,
                child: SizedBox(
                  width: 156,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _iconFor(a),
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          if (done)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _labelFor(ctx, a),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

