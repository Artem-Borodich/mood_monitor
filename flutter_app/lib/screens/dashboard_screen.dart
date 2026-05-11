import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/forecast_payload.dart';
import '../models/mood_entry.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/serenity_card.dart';
import '../widgets/serenity_section_header.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  List<MoodEntry> _entries = [];
  double? _wellbeingIndex;
  ForecastPayload? _forecast;
  String? _forecastError;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
      _forecastError = null;
    });
    try {
      final lang =
          Localizations.localeOf(context).languageCode == 'ru' ? 'ru' : 'en';
      final entries = await _api.fetchMoodEntries();
      final wellbeing = await _api.fetchWellbeingIndex();
      ForecastPayload? fc;
      try {
        fc = await _api.fetchForecast(lang: lang);
      } catch (e) {
        _forecastError = e.toString();
      }
      if (!mounted) return;
      setState(() {
        _entries = entries.reversed.toList();
        _wellbeingIndex = wellbeing;
        _forecast = fc;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (_loading) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.screenTop,
          AppSpacing.screenHorizontal,
          AppSpacing.screenBottom,
        ),
        children: const [
          LoadingShimmer(
            padding: EdgeInsets.zero,
            child: DashboardSkeleton(),
          ),
        ],
      );
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final latest = _entries.isNotEmpty ? _entries.first : null;
    final wellbeing = _wellbeingIndex ?? latest?.wellbeingIndex ?? 0;
    final wellbeingScore = ((wellbeing / 10) * 100).clamp(0, 100).toDouble();

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
          if (latest != null) ...[
            _quickLogCard(context, latest, loc),
            const SizedBox(height: AppSpacing.betweenSections),
          ],
          _wellbeingCard(context, wellbeingScore),
          const SizedBox(height: AppSpacing.betweenSections),
          _riskCard(context, latest),
          const SizedBox(height: AppSpacing.betweenSections),
          _trendChart(context, loc),
          const SizedBox(height: AppSpacing.betweenSections),
          const SerenitySectionHeader(title: 'Daily Tips', actionLabel: 'VIEW ALL'),
          const SizedBox(height: 10),
          _tipsScroller(context),
        ],
      ),
    );
  }

  Widget _quickLogCard(BuildContext context, MoodEntry last, AppLocalizations loc) {
    final theme = Theme.of(context);
    return SerenityCard(
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.08),
          theme.colorScheme.tertiaryContainer.withValues(alpha: 0.45),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SerenitySectionHeader(
            title: 'Quick Log',
            actionLabel: 'Use Last',
            onActionTap: () => _quickLogFromLast(last, loc),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _metricPill(context, '😊', loc.moodLabel, last.mood),
              const SizedBox(width: 10),
              _metricPill(context, '🔥', loc.stressLabel, last.stress),
              const SizedBox(width: 10),
              _metricPill(context, '⚡', loc.energyLabel, last.energy),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _quickLogFromLast(last, loc),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: Text("Log Today's Mood"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricPill(BuildContext context, String icon, String label, int value) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon),
            const SizedBox(height: 3),
            Text(label, style: theme.textTheme.labelSmall),
            Text(
              value.toString(),
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wellbeingCard(BuildContext context, double score) {
    final theme = Theme.of(context);
    return SerenityCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF6D35FF), Color(0xFF8A53FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        children: [
          Text(
            'Well-being Index',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your mental clarity is trending upwards.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 128,
            height: 128,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 45,
                    sections: [
                      PieChartSectionData(
                        value: score,
                        color: Colors.white,
                        radius: 9,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: 100 - score,
                        color: Colors.white.withValues(alpha: 0.25),
                        radius: 9,
                        title: '',
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    '${score.round()}\n/ 100',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskCard(BuildContext context, MoodEntry? latest) {
    final theme = Theme.of(context);
    final f = _forecast;
    final hasForecast = f != null && f.status == 'ok';
    final riskPct = hasForecast
        ? ((f.risk ?? 0) * 100).round()
        : _fallbackRiskFromLatest(latest);
    final isHigh = riskPct >= 60;
    final explanation = hasForecast
        ? (f.explanation ?? 'Based on your recent patterns')
        : (_forecastError ?? 'Based on sleep and stress patterns');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3FD),
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(
            color: isHigh ? theme.colorScheme.error : theme.colorScheme.primary,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Next Day Risk',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Icon(
                Icons.warning_amber_rounded,
                color: isHigh ? theme.colorScheme.error : theme.colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            explanation,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$riskPct%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  isHigh ? 'HIGH RISK' : 'MODERATE',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isHigh ? theme.colorScheme.error : theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: riskPct / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDE7F4),
              color: isHigh ? theme.colorScheme.error : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isHigh
                ? '"Consider a 10-minute meditation before bed to lower this risk."'
                : '"Keep your current routine and finish the day gently."',
            style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _trendChart(BuildContext context, AppLocalizations loc) {
    if (_entries.length < 2) {
      return StatCard(
        title: loc.dashboardMoodOverTime,
        value: loc.dashboardMoodNotEnough,
        subtitle: loc.dashboardMoodNotEnoughSubtitle,
      );
    }
    final theme = Theme.of(context);
    final sorted = [..._entries]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
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
                label: const Text('Last 7 Days'),
                visualDensity: VisualDensity.compact,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
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

  Widget _tipsScroller(BuildContext context) {
    final theme = Theme.of(context);
    final labels = const [
      'Morning sunlight exposure',
      'Try 10 min meditation',
      'Reduce evening caffeine',
    ];
    return SizedBox(
      height: 146,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.tertiaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                labels[index],
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _quickLogFromLast(MoodEntry last, AppLocalizations loc) async {
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
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.entrySaved)),
    );
    _loadData();
  }

  int _fallbackRiskFromLatest(MoodEntry? latest) {
    if (latest == null) return 50;
    final stress = latest.stress * 8;
    final sleepPenalty = ((7 - (latest.sleepHours ?? 7)).clamp(0, 7) * 6).round();
    return (stress + sleepPenalty).clamp(20, 90);
  }
}

