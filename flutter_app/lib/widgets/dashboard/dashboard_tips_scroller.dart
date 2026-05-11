import 'package:flutter/material.dart';

import '../../theme/app_decoration.dart';

class DashboardTipsScroller extends StatelessWidget {
  const DashboardTipsScroller({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const labels = [
      'Morning sunlight exposure',
      'Try 10 min meditation',
      'Reduce evening caffeine',
    ];
    return SizedBox(
      height: 152,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return Container(
            width: 228,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(theme.colorScheme.primaryContainer, theme.colorScheme.surface, 0.05)!,
                  Color.lerp(theme.colorScheme.tertiaryContainer, theme.colorScheme.primaryContainer, 0.25)!,
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: theme.brightness == Brightness.dark ? 0.08 : 0.45),
              ),
              boxShadow: AppDecorations.cardSubtle(context),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -24,
                  top: -24,
                  child: Icon(
                    Icons.spa_rounded,
                    size: 88,
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      labels[index],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: theme.colorScheme.surface.withValues(alpha: 0.9),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
