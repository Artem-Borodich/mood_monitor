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
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _wellbeingIndex = wellbeing;
        _forecast = fc;
        _loading = false;
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
        ? ((wellbeing / 10) * 100).clamp(0, 100).toDouble()
        : 0.0;
    final wellbeingSubtitle = latest == null
        ? loc.dashboardWellbeingSubtitleEmpty
        : loc.dashboardWellbeingSubtitle;

    return [
      DashboardHero(
        loc: loc,
        lastMood: latest?.mood,
        hasEntries: _entries.isNotEmpty,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.entrySaved)),
    );
    _loadData();
  }
}
