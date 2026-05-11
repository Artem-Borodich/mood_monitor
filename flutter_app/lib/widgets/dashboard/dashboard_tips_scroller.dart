import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/tips_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tip.dart';
import '../../screens/recommendation_details_screen.dart';
import '../../theme/app_decoration.dart';
import '../../theme/app_spacing.dart';

/// Horizontal "today" tips: opens full recommendation steps on tap.
class DashboardTipsScroller extends StatelessWidget {
  const DashboardTipsScroller({super.key});

  static const int _visibleCount = 6;

  IconData _iconFor(String iconName) {
    return switch (iconName) {
      'air' => Icons.air_rounded,
      'directions_walk' => Icons.directions_walk_rounded,
      'bedtime' => Icons.bedtime_rounded,
      'psychology' => Icons.psychology_rounded,
      'coffee' => Icons.local_cafe_rounded,
      _ => Icons.spa_rounded,
    };
  }

  Future<void> _openTip(BuildContext context, Tip tip) async {
    HapticFeedback.lightImpact();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RecommendationDetailsScreen(tip: tip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final lang = loc.locale.languageCode == 'ru' ? 'ru' : 'en';
    final tips = getTips(lang).take(_visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.tipsDashboardTapHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 168,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: tips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => _openTip(context, tip),
                  child: Ink(
                    width: 236,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(
                                theme.colorScheme.primaryContainer,
                                theme.colorScheme.surface,
                                0.05,
                              ) ??
                              theme.colorScheme.primaryContainer,
                          Color.lerp(
                                theme.colorScheme.tertiaryContainer,
                                theme.colorScheme.primaryContainer,
                                0.25,
                              ) ??
                              theme.colorScheme.tertiaryContainer,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: theme.brightness == Brightness.dark ? 0.08 : 0.45,
                        ),
                      ),
                      boxShadow: AppDecorations.cardSubtle(context),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -24,
                          top: -24,
                          child: Icon(
                            _iconFor(tip.iconName),
                            size: 88,
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: theme.colorScheme.primary.withValues(alpha: 0.55),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: theme.colorScheme.surface.withValues(alpha: 0.9),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  tip.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.3,
                                    fontWeight: FontWeight.w600,
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
            },
          ),
        ),
      ],
    );
  }
}
