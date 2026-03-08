import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/mood_entry.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/mood_list_item.dart';
import 'edit_mood_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _api = ApiService();
  late Future<List<MoodEntry>> _future;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _categoryFilter = 'any';
  RangeValues _moodRange = const RangeValues(1, 10);
  RangeValues _stressRange = const RangeValues(1, 10);
  RangeValues _energyRange = const RangeValues(1, 10);

  @override
  void initState() {
    super.initState();
    _future = _api.fetchMoodEntries();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.fetchMoodEntries();
    });
  }

  void _openEdit(MoodEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditMoodScreen(entry: entry),
      ),
    ).then((updated) {
      if (updated == true) _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<MoodEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  child: Text('${loc.errorPrefix}${snapshot.error}'),
                ),
              ],
            );
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.historyEmptyTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.historyEmptySubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          final filtered = _applyFilters(entries);

          if (filtered.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.screenTop, AppSpacing.screenHorizontal, AppSpacing.screenBottom),
              children: [
                _buildFiltersCard(theme, loc),
                const SizedBox(height: AppSpacing.betweenSections),
                Text(
                  loc.historyNoResults,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.screenTop, AppSpacing.screenHorizontal, AppSpacing.screenBottom),
            itemCount: filtered.length + 2,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.betweenListItems),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildFiltersCard(theme, loc);
              }
              if (index == 1) {
                return _buildAnalyticsSection(theme, loc, filtered);
              }
              final item = filtered[index - 2];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 250 + index * 40),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: MoodListItem(
                  entry: item,
                  onEdit: _openEdit,
                  onDelete: (_) => _refresh(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<MoodEntry> _applyFilters(List<MoodEntry> entries) {
    return entries.where((e) {
      final date =
          DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      if (_fromDate != null &&
          date.isBefore(DateTime(
              _fromDate!.year, _fromDate!.month, _fromDate!.day))) {
        return false;
      }
      if (_toDate != null &&
          date.isAfter(
              DateTime(_toDate!.year, _toDate!.month, _toDate!.day))) {
        return false;
      }
      if (_categoryFilter != 'any') {
        if ((e.category ?? 'none') != _categoryFilter) {
          return false;
        }
      }
      if (e.mood < _moodRange.start || e.mood > _moodRange.end) {
        return false;
      }
      if (e.stress < _stressRange.start || e.stress > _stressRange.end) {
        return false;
      }
      if (e.energy < _energyRange.start || e.energy > _energyRange.end) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _buildFiltersCard(ThemeData theme, AppLocalizations loc) {
    final fromText = _fromDate == null
        ? loc.historyFiltersFrom
        : '${_fromDate!.year}-${_fromDate!.month.toString().padLeft(2, '0')}-${_fromDate!.day.toString().padLeft(2, '0')}';
    final toText = _toDate == null
        ? loc.historyFiltersTo
        : '${_toDate!.year}-${_toDate!.month.toString().padLeft(2, '0')}-${_toDate!.day.toString().padLeft(2, '0')}';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.historyFiltersTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.titleToContent),
            Text(
              loc.historyFiltersDate,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDateRange(),
                    child: Text(fromText),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDateRange(),
                    child: Text(toText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.betweenCards),
            Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.betweenCards),
            Text(
              loc.historyFiltersCategory,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _buildCategoryChip(loc.historyFiltersAny, 'any'),
                _buildCategoryChip(loc.addCategoryWork, 'work'),
                _buildCategoryChip(
                    loc.addCategoryRelationships, 'relationships'),
                _buildCategoryChip(loc.addCategoryHealth, 'health'),
              ],
            ),
            const SizedBox(height: AppSpacing.betweenCards),
            Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppSpacing.betweenCards),
            _buildRangeSlider(
              theme: theme,
              label: loc.historyFiltersMoods,
              range: _moodRange,
              onChanged: (v) => setState(() => _moodRange = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildRangeSlider(
              theme: theme,
              label: loc.historyFiltersStress,
              range: _stressRange,
              onChanged: (v) => setState(() => _stressRange = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildRangeSlider(
              theme: theme,
              label: loc.historyFiltersEnergy,
              range: _energyRange,
              onChanged: (v) => setState(() => _energyRange = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final selected = _categoryFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _categoryFilter = value;
        });
      },
    );
  }

  Widget _buildRangeSlider({
    required ThemeData theme,
    required String label,
    required RangeValues range,
    required ValueChanged<RangeValues> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${range.start.round()} - ${range.end.round()}',
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
        RangeSlider(
          min: 1,
          max: 10,
          divisions: 9,
          values: range,
          labels: RangeLabels(
            range.start.round().toString(),
            range.end.round().toString(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final initialRange = DateTimeRange(
      start: _fromDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: _toDate ?? DateTime.now(),
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialRange,
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
  }

  Widget _buildAnalyticsSection(
    ThemeData theme,
    AppLocalizations loc,
    List<MoodEntry> entries,
  ) {
    if (entries.length < 3) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.analyticsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.titleToContent),
        _buildMoodStressChart(theme, entries),
        const SizedBox(height: AppSpacing.betweenListItems),
        _buildMoodSleepChart(theme, entries),
        const SizedBox(height: AppSpacing.betweenListItems),
        _buildWeeklyBarChart(theme, entries),
      ],
    );
  }

  Widget _buildMoodStressChart(
    ThemeData theme,
    List<MoodEntry> entries,
  ) {
    final moodSpots = <FlSpot>[];
    final stressSpots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      moodSpots.add(FlSpot(i.toDouble(), entries[i].mood.toDouble()));
      stressSpots.add(FlSpot(i.toDouble(), entries[i].stress.toDouble()));
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
        child: SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: 1,
              maxY: 10,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: moodSpots,
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: stressSpots,
                  isCurved: true,
                  color: theme.colorScheme.error,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSleepChart(
    ThemeData theme,
    List<MoodEntry> entries,
  ) {
    final moodSpots = <FlSpot>[];
    final sleepSpots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      moodSpots.add(FlSpot(i.toDouble(), e.mood.toDouble()));
      final sleep = (e.sleepHours ?? 0).clamp(0, 12).toDouble();
      sleepSpots.add(FlSpot(i.toDouble(), sleep));
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
        child: SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 12,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: moodSpots,
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: sleepSpots,
                  isCurved: true,
                  color: theme.colorScheme.tertiary,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart(
    ThemeData theme,
    List<MoodEntry> entries,
  ) {
    final now = DateTime.now();
    final Map<int, List<double>> byWeek = {};

    for (final e in entries) {
      final diff = now.difference(e.createdAt).inDays;
      if (diff > 56) continue; // last 8 weeks
      final weekIndex = diff ~/ 7; // 0 = this week
      byWeek.putIfAbsent(weekIndex, () => []);
      byWeek[weekIndex]!.add(e.wellbeingIndex);
    }

    if (byWeek.isEmpty) {
      return const SizedBox.shrink();
    }

    final barGroups = <BarChartGroupData>[];
    final sortedKeys = byWeek.keys.toList()..sort();
    for (final key in sortedKeys) {
      final values = byWeek[key]!;
      final avg = values.reduce((a, b) => a + b) / values.length;
      barGroups.add(
        BarChartGroupData(
          x: -key,
          barRods: [
            BarChartRodData(
              toY: avg,
              color: theme.colorScheme.primary,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
        child: SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: 10,
              titlesData: const FlTitlesData(show: false),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ),
    );
  }
}

