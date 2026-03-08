import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/mood_entry.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/stat_card.dart';
import '../widgets/wellbeing_ring.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  List<MoodEntry> _entries = [];
  double? _wellbeingIndex;
  bool _loading = true;
  String? _error;
  int _streakDays = 0;
  bool _weeklyStressBelowTarget = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final entries = await _api.fetchMoodEntries();
      final wellbeing = await _api.fetchWellbeingIndex();
      setState(() {
        _entries = entries.reversed.toList();
        _wellbeingIndex = wellbeing;
        _recalculateGoals();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _recalculateGoals() {
    if (_entries.isEmpty) {
      _streakDays = 0;
      _weeklyStressBelowTarget = true;
      return;
    }

    // Streak: consecutive days with at least one entry, going backwards from today.
    final dates = _entries
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet();
    var current = DateTime.now();
    var streak = 0;
    while (dates.contains(DateTime(current.year, current.month, current.day))) {
      streak += 1;
      current = current.subtract(const Duration(days: 1));
    }
    _streakDays = streak;

    // Weekly stress goal: average stress of last 7 days below threshold.
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recent = _entries.where((e) => e.createdAt.isAfter(oneWeekAgo)).toList();
    if (recent.isEmpty) {
      _weeklyStressBelowTarget = true;
    } else {
      final avgStress =
          recent.map((e) => e.stress).reduce((a, b) => a + b) / recent.length;
      _weeklyStressBelowTarget = avgStress < 6;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
        ),
      );
    }

    final latest = _entries.isNotEmpty ? _entries.last : null;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.screenTop,
          AppSpacing.screenHorizontal,
          AppSpacing.screenBottom,
        ),
        children: [
          if (latest != null) _buildQuickAddCard(context, latest, loc),
          if (latest != null) const SizedBox(height: AppSpacing.betweenSections),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard + 8),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                const SizedBox(width: 4),
                WellbeingRing(value: _wellbeingIndex ?? 0),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.dashboardWellbeingTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _entries.isEmpty
                            ? loc.dashboardWellbeingSubtitleEmpty
                            : loc.dashboardWellbeingSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          _buildChartCard(context),
          const SizedBox(height: AppSpacing.betweenSections),
          _sectionTitle(context, loc.goalsTitle),
          const SizedBox(height: AppSpacing.titleToContent),
          _buildGoalsCard(context),
          const SizedBox(height: AppSpacing.betweenSections),
          _sectionTitle(context, loc.compareTitle),
          const SizedBox(height: AppSpacing.titleToContent),
          _buildWeekComparisonCard(context),
          const SizedBox(height: AppSpacing.betweenSections),
          if (latest != null) ...[
            _sectionTitle(context, loc.dashboardLatestEntry),
            const SizedBox(height: AppSpacing.titleToContent),
            _buildLatestEntryCard(context, latest),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    if (_entries.length < 2) {
      final loc = AppLocalizations.of(context);
      return StatCard(
        title: loc.dashboardMoodOverTime,
        value: loc.dashboardMoodNotEnough,
        subtitle: loc.dashboardMoodNotEnoughSubtitle,
      );
    }

    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final spots = <FlSpot>[];
    for (var i = 0; i < _entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), _entries[i].mood.toDouble()));
    }

    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  loc.dashboardMoodOverTime,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 1,
                  maxY: 10,
                  // Use default touch behavior to keep compatibility
                  // with a broad range of fl_chart versions.
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value % 2 != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= _entries.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '${_entries[index].createdAt.day}',
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestEntryCard(BuildContext context, MoodEntry entry) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final dateString =
        '${entry.createdAt.year}-${entry.createdAt.month.toString().padLeft(2, '0')}-${entry.createdAt.day.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wb_sunny_rounded),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.dashboardLatestEntry,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateString,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricChip(
                context: context,
                icon: '😊',
                label: loc.moodLabel,
                value: entry.mood,
                color: theme.colorScheme.primary,
              ),
              _metricChip(
                context: context,
                icon: '🔥',
                label: loc.stressLabel,
                value: entry.stress,
                color: theme.colorScheme.error,
              ),
              _metricChip(
                context: context,
                icon: '⚡',
                label: loc.energyLabel,
                value: entry.energy,
                color: theme.colorScheme.tertiary,
              ),
            ],
          ),
          if (entry.note != null && entry.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                entry.note!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricChip({
    required BuildContext context,
    required String icon,
    required String label,
    required int value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddCard(BuildContext context, MoodEntry last, AppLocalizations loc) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        onTap: () async {
          await _api.createMoodEntry(
            mood: last.mood,
            stress: last.stress,
            energy: last.energy,
            note: last.note,
            date: DateTime.now(),
            category: last.category,
            sleepHours: last.sleepHours,
            activityMinutes: last.activityMinutes,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.entrySaved)),
          );
          _loadData();
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.add_circle_rounded, color: theme.colorScheme.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.quickAddTitle,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.quickAddSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekComparisonCard(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final now = DateTime.now();
    final thisWeekStart = now.subtract(const Duration(days: 7));
    final lastWeekStart = now.subtract(const Duration(days: 14));
    final thisWeekEntries = _entries.where((e) => e.createdAt.isAfter(thisWeekStart)).toList();
    final lastWeekEntries = _entries.where((e) => e.createdAt.isAfter(lastWeekStart) && !e.createdAt.isAfter(thisWeekStart)).toList();

    if (thisWeekEntries.isEmpty && lastWeekEntries.isEmpty) return const SizedBox.shrink();

    double avgMood(List<MoodEntry> list) => list.isEmpty ? 0 : list.map((e) => e.mood).reduce((a, b) => a + b) / list.length;
    double avgStress(List<MoodEntry> list) => list.isEmpty ? 0 : list.map((e) => e.stress).reduce((a, b) => a + b) / list.length;
    double avgEnergy(List<MoodEntry> list) => list.isEmpty ? 0 : list.map((e) => e.energy).reduce((a, b) => a + b) / list.length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  loc.compareTitle,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(loc.thisWeek, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('${loc.moodLabel}: ${avgMood(thisWeekEntries).toStringAsFixed(1)}', style: theme.textTheme.bodySmall),
                      Text('${loc.stressLabel}: ${avgStress(thisWeekEntries).toStringAsFixed(1)}', style: theme.textTheme.bodySmall),
                      Text('${loc.energyLabel}: ${avgEnergy(thisWeekEntries).toStringAsFixed(1)}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(loc.lastWeek, style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('${loc.moodLabel}: ${avgMood(lastWeekEntries).toStringAsFixed(1)}', style: theme.textTheme.bodySmall),
                      Text('${loc.stressLabel}: ${avgStress(lastWeekEntries).toStringAsFixed(1)}', style: theme.textTheme.bodySmall),
                      Text('${loc.energyLabel}: ${avgEnergy(lastWeekEntries).toStringAsFixed(1)}', style: theme.textTheme.bodySmall),
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

  Widget _buildGoalsCard(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  loc.goalsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${loc.goalsStreak}: $_streakDays ${loc.goalsStreakDays}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _weeklyStressBelowTarget
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  size: 18,
                  color: _weeklyStressBelowTarget
                      ? Colors.green
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _weeklyStressBelowTarget
                        ? loc.goalsStressWeekOk
                        : loc.goalsStressWeekHigh,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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

