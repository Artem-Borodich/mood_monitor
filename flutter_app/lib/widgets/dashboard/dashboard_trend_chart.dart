import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
    if (entries.length < 2) {
      return StatCard(
        title: loc.dashboardMoodOverTime,
        value: loc.dashboardMoodNotEnough,
        subtitle: loc.dashboardMoodNotEnoughSubtitle,
      );
    }
    final theme = Theme.of(context);
    final sorted = [...entries]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final show = sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;

    final moodSpots = <FlSpot>[];
    final stressSpots = <FlSpot>[];
    for (var i = 0; i < show.length; i++) {
      moodSpots.add(FlSpot(i.toDouble(), show[i].mood.toDouble()));
      stressSpots.add(FlSpot(i.toDouble(), show[i].stress.toDouble()));
    }

    return SerenityCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(loc.dashboardMoodOverTime, style: theme.textTheme.titleMedium),
              const Spacer(),
              Chip(
                label: Text(loc.tipsChipWeek),
                visualDensity: VisualDensity.compact,
                side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                elevation: 1,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 210,
            child: LineChart(
              LineChartData(
                minY: 1,
                maxY: 10,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    strokeWidth: 0.6,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 != 0) return const SizedBox.shrink();
                        return Text(value.toInt().toString(), style: theme.textTheme.labelSmall);
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= show.length) return const SizedBox.shrink();
                        return Text('${show[i].createdAt.day}', style: theme.textTheme.labelSmall);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: moodSpots,
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          theme.colorScheme.primary.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: stressSpots,
                    isCurved: true,
                    color: theme.colorScheme.error.withValues(alpha: 0.8),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
