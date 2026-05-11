import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/forecast_payload.dart';
import '../models/mood_entry.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_error_view.dart';
import '../widgets/dashboard/dashboard_empty_state.dart';
import '../widgets/dashboard/dashboard_hero.dart';
import '../widgets/dashboard/dashboard_quick_log_card.dart';
import '../widgets/dashboard/dashboard_risk_card.dart';
import '../widgets/dashboard/dashboard_tips_scroller.dart';
import '../widgets/dashboard/dashboard_trend_chart.dart';
import '../widgets/dashboard/dashboard_wellbeing_card.dart';
import '../widgets/dashboard/quick_log_bottom_sheet.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/serenity_section_header.dart';
import '../widgets/dashboard/dashboard_daily_check_in.dart';
import '../widgets/dashboard/dashboard_quick_wellness_scroller.dart';
import '../widgets/serenity_card.dart';
import '../widgets/serenity_messenger.dart';
import '../locale_store.dart';
import '../screens/breathing_timer_screen.dart';
import '../services/api_exception.dart';
import '../utils/wellbeing_math.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onAddMoodTap});

  final VoidCallback? onAddMoodTap;

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
  Object? _error;

  int _todayCompletedActions = 0;
  int _streakDays = 0;
  Set<String> _completedActionKeysToday = {};

  bool _checkInBusy = false;
  bool _journalBusy = false;
  bool _walkBusy = false;

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
        _forecastError = e is Exception ? e.toString() : '$e';
      }

      final now = DateTime.now();
      final completedKeys = await getCompletedActionKeysForDate(now);
      final streak = await getWellnessCompletionStreakDays(now);
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _wellbeingIndex = wellbeing;
        _forecast = fc;
        _loading = false;
        _completedActionKeysToday = completedKeys;
        _todayCompletedActions = completedKeys.length;
        _streakDays = streak;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  List<Widget> _bodyChildren(AppLocalizations loc, MoodEntry? latest) {
    final wellbeing = _wellbeingIndex ?? latest?.wellbeingIndex;
    final wellbeingScore = wellbeing != null
        ? wellbeingIndexToDisplayPercent(wellbeing)
        : 0.0;
    final wellbeingSubtitle = latest == null
        ? loc.dashboardWellbeingSubtitleEmpty
        : loc.dashboardWellbeingSubtitle;

    final prev = _entries.length > 1 ? _entries[1] : null;
    String? insight;
    if (latest != null && prev != null) {
      if (latest.stress < prev.stress) {
        insight = loc.dashboardInsightStressDown;
      } else if (latest.mood > prev.mood) {
        insight = loc.dashboardInsightMoodUp;
      } else if (latest.mood == prev.mood && latest.stress == prev.stress) {
        insight = loc.dashboardInsightSteady;
      } else {
        insight = loc.dashboardInsightConsistency;
      }
    } else if (_streakDays >= 2) {
      insight = loc.dashboardInsightConsistency;
    }

    return [
      DashboardHero(
        loc: loc,
        lastMood: latest?.mood,
        hasEntries: _entries.isNotEmpty,
      ),
      if (insight != null) ...[
        const SizedBox(height: 12),
        Text(
          insight,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
        ),
        SizedBox(height: AppSpacing.betweenSections),
      ],
      if (_todayCompletedActions > 0)
        SerenityCard(
          borderRadius: 28,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Text(
            '${loc.todayCompletedActions}$_todayCompletedActions${loc.todayCompletedActionsSuffix} • $_streakDays${loc.todayStreakSuffix}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      if (_todayCompletedActions > 0) SizedBox(height: AppSpacing.betweenSections),
      DashboardDailyCheckIn(
        busy: _checkInBusy,
        onSelected: (mood) => _submitDailyCheckIn(mood),
      ),
      SizedBox(height: AppSpacing.betweenSections),
      DashboardQuickWellnessScroller(
        completedActionKeysToday: _completedActionKeysToday,
        busyWalk: _walkBusy,
        busyJournal: _journalBusy,
        onSelected: (a) => _onQuickWellnessAction(a),
      ),
      SizedBox(height: AppSpacing.betweenSections),
      if (latest != null) ...[
        DashboardQuickLogCard(
          last: latest,
          loc: loc,
          onOpenSheet: () => _openQuickLogSheet(latest, loc),
        ),
        SizedBox(height: AppSpacing.betweenSections),
      ],
      if (_entries.isEmpty) ...[
        DashboardEmptyState(onAddMood: widget.onAddMoodTap),
        SizedBox(height: AppSpacing.betweenSections),
      ],
      DashboardWellbeingCard(
        title: loc.dashboardWellbeingTitle,
        score: wellbeingScore,
        subtitle: wellbeingSubtitle,
        rawWellbeingIndex: wellbeing,
      ),
      SizedBox(height: AppSpacing.betweenSections),
      DashboardRiskCard(
        forecast: _forecast,
        forecastError: _forecastError,
        latest: latest,
      ),
      SizedBox(height: AppSpacing.betweenSections),
      DashboardTrendChart(entries: _entries, loc: loc),
      SizedBox(height: AppSpacing.betweenSections),
      SerenitySectionHeader(title: loc.tipsTodayTitle),
      SizedBox(height: AppSpacing.md),
      const DashboardTipsScroller(),
      SizedBox(height: AppSpacing.section),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
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
      return AppErrorView(
        error: _error!,
        onRetry: _loadData,
      );
    }

    final latest = _entries.isNotEmpty ? _entries.first : null;
    final children = _bodyChildren(loc, latest);

    return RefreshIndicator(
      edgeOffset: 8,
      onRefresh: _loadData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.screenTop,
              AppSpacing.screenHorizontal,
              AppSpacing.screenBottom,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(children),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuickLogSheet(MoodEntry last, AppLocalizations loc) async {
    final ok = await showQuickLogBottomSheet(
      context,
      template: last,
      api: _api,
      loc: loc,
    );
    if (!mounted || !ok) return;
    HapticFeedback.lightImpact();
    SerenityMessenger.show(context, loc.entrySaved);
    _loadData();
  }

  Future<void> _submitDailyCheckIn(DailyCheckInMood mood) async {
    if (_checkInBusy) return;
    setState(() => _checkInBusy = true);
    final loc = AppLocalizations.of(context);
    try {
      final last = await _api.fetchLastMoodEntry();
      final baseSleep = last?.sleepHours ?? 7;
      final baseActivity = last?.activityMinutes ?? 20;

      final values = switch (mood) {
        DailyCheckInMood.calm => (mood: 8, stress: 3, energy: 7),
        DailyCheckInMood.tired => (mood: 4, stress: 5, energy: 3),
        DailyCheckInMood.stressed => (mood: 4, stress: 8, energy: 4),
        DailyCheckInMood.motivated => (mood: 8, stress: 4, energy: 8),
      };

      await _api.createMoodEntry(
        mood: values.mood,
        stress: values.stress,
        energy: values.energy,
        date: DateTime.now(),
        category: null,
        sleepHours: baseSleep,
        activityMinutes:
            values.energy >= 7 ? baseActivity : (baseActivity > 20 ? 20 : baseActivity),
      );

      await markActionCompletedForDate(
        'checkin:${mood.name}',
        DateTime.now(),
      );

      if (!mounted) return;
      SerenityMessenger.show(context, loc.checkInSaved);
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? e.userMessage : '${loc.errorPrefix}$e';
      SerenityMessenger.show(context, msg, kind: SerenitySnackKind.error);
    } finally {
      if (!mounted) return;
      setState(() => _checkInBusy = false);
    }
  }

  Future<void> _onQuickWellnessAction(QuickWellnessAction action) async {
    final loc = AppLocalizations.of(context);
    final now = DateTime.now();

    String actionKey = switch (action) {
      QuickWellnessAction.breathing => 'quick:breathing',
      QuickWellnessAction.journal => 'quick:journal',
      QuickWellnessAction.stretch => 'quick:stretch',
      QuickWellnessAction.water => 'quick:water',
      QuickWellnessAction.walk => 'quick:walk',
    };

    if (action == QuickWellnessAction.walk) setState(() => _walkBusy = true);
    if (action == QuickWellnessAction.journal) setState(() => _journalBusy = true);

    try {
      if (action == QuickWellnessAction.breathing) {
        final done = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const BreathingTimerScreen()),
        );
        if (done == true && !_completedActionKeysToday.contains(actionKey)) {
          await markActionCompletedForDate(actionKey, now);
        }
        if (done == true && mounted) await _loadData();
        return;
      }

      if (action == QuickWellnessAction.walk) {
        final last = await _api.fetchLastMoodEntry();
        await _api.createMoodEntry(
          mood: last?.mood ?? 5,
          stress: last?.stress ?? 5,
          energy: last?.energy ?? 5,
          date: now,
          activityMinutes: 15,
        );
        if (!_completedActionKeysToday.contains(actionKey)) {
          await markActionCompletedForDate(actionKey, now);
        }
        if (!mounted) return;
        await _loadData();
        return;
      }

      // Local-only actions (journal/stretch/water). No backend changes.
      if (action == QuickWellnessAction.journal) {
        final saved = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (ctx) {
            final controller = TextEditingController();
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.screenHorizontal,
                right: AppSpacing.screenHorizontal,
                top: 10,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    loc.quickActionJournal,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.25,
                        ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: loc.addOptionalNoteHint,
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(ctx, true),
                    icon: const Icon(Icons.check_rounded),
                    label: Text(loc.addSave),
                  ),
                ],
              ),
            );
          },
        );
        if (saved == true) {
          if (!_completedActionKeysToday.contains(actionKey)) {
            await markActionCompletedForDate(actionKey, now);
          }
          if (!mounted) return;
          SerenityMessenger.show(context, loc.checkInSaved);
          await _loadData();
        }
        return;
      }

      if (action == QuickWellnessAction.stretch ||
          action == QuickWellnessAction.water) {
        final finished = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (ctx) => Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.screenHorizontal,
              right: AppSpacing.screenHorizontal,
              top: 10,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  action == QuickWellnessAction.stretch ? loc.quickActionStretch : loc.quickActionWater,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.25,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  action == QuickWellnessAction.stretch
                      ? 'A few gentle moves for your neck and shoulders.'
                      : 'Drink a glass slowly and reset your posture.',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(ctx, true),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(loc.recDoneBadge),
                ),
              ],
            ),
          ),
        );

        if (finished == true) {
          if (!_completedActionKeysToday.contains(actionKey)) {
            await markActionCompletedForDate(actionKey, now);
          }
          if (!mounted) return;
          await _loadData();
        }
        return;
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? e.userMessage : '${loc.errorPrefix}$e';
      SerenityMessenger.show(context, msg, kind: SerenitySnackKind.error);
    } finally {
      if (!mounted) return;
      setState(() {
        _walkBusy = false;
        _journalBusy = false;
      });
    }
  }
}
