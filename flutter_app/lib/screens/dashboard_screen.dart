import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/mood_entry.dart';
import '../services/api_service.dart';
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
  bool _loading = true;
  String? _error;

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
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(16),
        children: [
          StatCard(
            title: 'Wellbeing Index',
            value: _wellbeingIndex?.toStringAsFixed(2) ?? '--',
            subtitle: _entries.isEmpty
                ? 'No data yet. Add your first mood entry.'
                : 'Based on your latest mood, stress and energy.',
          ),
          const SizedBox(height: 16),
          _buildChartCard(),
          const SizedBox(height: 16),
          if (latest != null) _buildLatestEntryCard(latest),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    if (_entries.length < 2) {
      return const StatCard(
        title: 'Mood Over Time',
        value: 'Not enough data',
        subtitle: 'At least two entries are needed to show the chart.',
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < _entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), _entries[i].mood.toDouble()));
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Over Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 1,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= _entries.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '${_entries[index].createdAt.day}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(),
                      bottom: BorderSide(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestEntryCard(MoodEntry entry) {
    final dateString =
        '${entry.createdAt.year}-${entry.createdAt.month.toString().padLeft(2, '0')}-${entry.createdAt.day.toString().padLeft(2, '0')}';

    return StatCard(
      title: 'Latest Entry',
      value: 'Mood ${entry.mood}, Stress ${entry.stress}, Energy ${entry.energy}',
      subtitle: 'Date: $dateString'
          '${entry.note != null && entry.note!.isNotEmpty ? '\nNote: ${entry.note}' : ''}',
    );
  }
}

