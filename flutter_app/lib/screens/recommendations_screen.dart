import 'package:flutter/material.dart';

import '../data/tips_data.dart';
import '../l10n/app_localizations.dart';
import '../locale_store.dart';
import '../models/tip.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import 'breathing_timer_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>> _future;
  String? _lastLang;
  String _categoryFilter = 'all';
  Set<String> _savedIds = {};

  @override
  void initState() {
    super.initState();
    _future = Future.value(<String, dynamic>{});
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final ids = await getSavedTipIds();
    if (mounted) setState(() => _savedIds = ids);
  }

  Future<void> _refresh() async {
    final lang = _lastLang ?? 'en';
    setState(() => _future = _api.fetchRecommendations(lang: lang));
    await _loadSaved();
  }

  Future<Map<String, dynamic>> _fetch(String lang) =>
      _api.fetchRecommendations(lang: lang);

  IconData _iconFor(String iconName) {
    switch (iconName) {
      case 'air':
        return Icons.air_rounded;
      case 'directions_walk':
        return Icons.directions_walk_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode == 'ru' ? 'ru' : 'en';
    if (_lastLang != lang) {
      _lastLang = lang;
      _future = _fetch(lang);
    }

    final allTips = getTips(lang);
    final filtered = _categoryFilter == 'saved'
        ? allTips.where((t) => _savedIds.contains(t.id)).toList()
        : _categoryFilter == 'all'
            ? allTips
            : allTips.where((t) => t.category == _categoryFilter).toList();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          final apiData = snapshot.data ?? {};
          final index = apiData['wellbeing_index'] as num?;
          final message = apiData['message'] as String? ??
              (lang == 'ru'
                  ? 'Добавьте запись о настроении, чтобы получить совет.'
                  : 'Add a mood entry to get a personal tip.');

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.screenTop,
              AppSpacing.screenHorizontal,
              AppSpacing.screenBottom,
            ),
            children: [
              Text(
                loc.tipsTodayTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.titleToContent),
              Text(
                loc.tipsTodaySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.betweenSections),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    _chip(loc.tipsCategoryAll, 'all'),
                    _chip(loc.tipsCategoryBreathing, 'breathing'),
                    _chip(loc.tipsCategoryMovement, 'movement'),
                    _chip(loc.tipsCategorySleep, 'sleep'),
                    _chip(loc.tipsCategoryMindset, 'mindset'),
                    _chip(loc.tipsCategoryQuickBreaks, 'quick_breaks'),
                    _chip(loc.tipsMyTips, 'saved'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.betweenSections),
              Text(
                loc.tipsForYou,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.titleToContent),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '${loc.errorPrefix}${snapshot.error}',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else ...[
                if (index != null)
                  _buildIndexCard(context, index.toDouble(), loc),
                const SizedBox(height: AppSpacing.betweenListItems),
                _buildApiMessageCard(context, message, loc),
              ],
              const SizedBox(height: AppSpacing.section),
              ...filtered.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.betweenListItems),
                    child: _buildTipCard(context, tip, loc, theme),
                  )),
              if (filtered.isEmpty && _categoryFilter == 'saved')
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      loc.tipsSaved,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _categoryFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _categoryFilter = value),
      ),
    );
  }

  Widget _buildIndexCard(
      BuildContext context, double index, AppLocalizations loc) {
    final theme = Theme.of(context);
    Color bg;
    IconData icon;
    String title;
    if (index >= 7.5) {
      bg = Colors.greenAccent.withValues(alpha: 0.25);
      icon = Icons.sentiment_very_satisfied_rounded;
      title = loc.tipsIndexHigh;
    } else if (index >= 5) {
      bg = Colors.amberAccent.withValues(alpha: 0.25);
      icon = Icons.sentiment_satisfied_rounded;
      title = loc.tipsIndexMedium;
    } else {
      bg = Colors.redAccent.withValues(alpha: 0.25);
      icon = Icons.sentiment_dissatisfied_rounded;
      title = loc.tipsIndexLow;
    }
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusCard)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 26, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${loc.tipsIndexPrefix}${index.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiMessageCard(
      BuildContext context, String message, AppLocalizations loc) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusCard)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.lightbulb_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.tipsPersonalTip,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(
      BuildContext context, Tip tip, AppLocalizations loc, ThemeData theme) {
    final isSaved = _savedIds.contains(tip.id);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusCard)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _iconFor(tip.iconName),
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isSaved
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () async {
                    await toggleSavedTipId(tip.id);
                    await _loadSaved();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.betweenListItems),
            Text(
              loc.tipsWhyHelp,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              tip.whyItHelps,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              loc.tipsHowToDo,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            ...tip.howToDo.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${e.key + 1}. ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.value,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
            if (tip.action != TipAction.none) ...[
              const SizedBox(height: AppSpacing.betweenListItems),
              if (tip.action == TipAction.breathingTimer)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BreathingTimerScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.timer_rounded, size: 20),
                    label: Text(loc.tipsStartBreathing),
                  ),
                )
              else if (tip.action == TipAction.logWalk)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _logWalk(context, loc),
                    icon: const Icon(Icons.directions_walk_rounded, size: 20),
                    label: Text(loc.tipsLogWalk),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _logWalk(BuildContext context, AppLocalizations loc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.tipsLogWalk),
        content: Text(loc.tipsLogWalkConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.addSave),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final last = await _api.fetchLastMoodEntry();
      await _api.createMoodEntry(
        mood: last?.mood ?? 5,
        stress: last?.stress ?? 5,
        energy: last?.energy ?? 5,
        date: DateTime.now(),
        activityMinutes: 15,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.tipsLogWalkDone)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.errorPrefix}$e')),
      );
    }
  }
}
