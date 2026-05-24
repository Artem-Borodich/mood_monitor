import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/mood_entry.dart';

/// Month grid (7×6), Monday-first. Colors by max mood per day; data from [entries] only.
class MoodCalendarHeatmap extends StatefulWidget {
  const MoodCalendarHeatmap({
    super.key,
    required this.entries,
    required this.loc,
    required this.onOpenDayWithEntries,
    required this.onShowNoData,
  });

  final List<MoodEntry> entries;
  final AppLocalizations loc;
  /// Local calendar date (date-only semantics).
  final void Function(DateTime day) onOpenDayWithEntries;
  final VoidCallback onShowNoData;

  @override
  State<MoodCalendarHeatmap> createState() => _MoodCalendarHeatmapState();
}

class _MoodCalendarHeatmapState extends State<MoodCalendarHeatmap> {
  late DateTime _month;

  static const int _rows = 6;
  static const int _cols = 7;
  static const int _cells = _rows * _cols;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Map<DateTime, int> _maxMoodByDay() {
    final map = <DateTime, int>{};
    for (final e in widget.entries) {
      final local = e.createdAt.toLocal();
      final d = _dateOnly(local);
      map[d] = math.max(map[d] ?? 0, e.mood);
    }
    return map;
  }

  Color _cellFill(int? maxMood, {required bool inCurrentMonth}) {
    if (!inCurrentMonth) {
      return Colors.grey.shade200;
    }
    if (maxMood == null) {
      return Colors.grey.shade300;
    }
    if (maxMood <= 2) return const Color(0xFFB71C1C);
    if (maxMood <= 4) return Colors.orange.shade800;
    if (maxMood <= 6) return Colors.amber.shade700;
    if (maxMood <= 8) return Colors.lightGreen.shade500;
    return Colors.green.shade700;
  }

  Color _textOnFill(Color fill) {
    if (fill == Colors.grey.shade200 || fill == Colors.grey.shade300) {
      return Colors.grey.shade800;
    }
    if (fill.computeLuminance() > 0.55) return Colors.black87;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final maxMood = _maxMoodByDay();
    final today = _dateOnly(DateTime.now());

    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final lead = (first.weekday - DateTime.monday + 7) % 7;

    final prevMonthLast = DateTime(_month.year, _month.month, 0).day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
              onPressed: () {
                setState(() {
                  _month = DateTime(_month.year, _month.month - 1);
                });
              },
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                DateFormat.yMMMM(locale).format(first),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
              onPressed: () {
                setState(() {
                  _month = DateTime(_month.year, _month.month + 1);
                });
              },
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(_cols, (i) {
            final d = DateTime(2023, 11, 27).add(Duration(days: i));
            return Expanded(
              child: Text(
                DateFormat.E(locale).format(d),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _cols,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            childAspectRatio: 1.05,
          ),
          itemCount: _cells,
          itemBuilder: (context, i) {
            final offset = i - lead;
            late int dayNum;
            late bool inCurrent;
            late DateTime cellDate;

            if (offset < 0) {
              dayNum = prevMonthLast + offset + 1;
              inCurrent = false;
              cellDate = DateTime(_month.year, _month.month - 1, dayNum);
            } else if (offset >= daysInMonth) {
              dayNum = offset - daysInMonth + 1;
              inCurrent = false;
              cellDate = DateTime(_month.year, _month.month + 1, dayNum);
            } else {
              dayNum = offset + 1;
              inCurrent = true;
              cellDate = DateTime(_month.year, _month.month, dayNum);
            }

            final key = _dateOnly(cellDate);
            final mood = inCurrent ? maxMood[key] : null;
            final fill = _cellFill(mood, inCurrentMonth: inCurrent);
            final isToday = inCurrent && key == today;
            final hasData = inCurrent && mood != null;

            return Material(
              color: fill,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: !inCurrent
                    ? null
                    : () {
                        if (hasData) {
                          widget.onOpenDayWithEntries(key);
                        } else {
                          widget.onShowNoData();
                        }
                      },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: Colors.blue.shade700, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _textOnFill(fill).withValues(
                          alpha: inCurrent ? 1 : 0.45,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          widget.loc.historyCalendarLegend,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}
