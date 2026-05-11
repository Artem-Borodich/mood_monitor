import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/tips_data.dart';
import '../design_system/aura_card.dart';
import '../l10n/app_localizations.dart';
import '../locale_store.dart';
import '../models/tip.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../utils/wellbeing_math.dart';
import '../widgets/app_error_view.dart';
import '../widgets/loading_shimmer.dart';
import '../utils/api_message_localizer.dart';
import '../widgets/serenity_messenger.dart';
import '../widgets/serenity_section_header.dart';
import 'breathing_timer_screen.dart';
import 'recommendation_details_screen.dart';

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
  Set<String> _dismissedIds = {};
  Set<String> _completedTipIdsToday = {};
  Set<String> _helpfulTipIds = {};
  Set<String> _notHelpfulTipIds = {};
  bool _quickBreathingDone = false;
  bool _quickWalkDone = false;

  @override
  void initState() {
    super.initState();
    _future = Future.value(<String, dynamic>{});
    _loadSaved();
    _loadDismissedAndCompleted();
    _loadTipFeedback();
  }

  Future<void> _loadSaved() async {
    final ids = await getSavedTipIds();
    if (mounted) setState(() => _savedIds = ids);
  }

  Future<void> _loadDismissedAndCompleted() async {
    final dismissed = await getDismissedTipIds();
    final todayKeys = await getCompletedActionKeysForDate(DateTime.now());
    final completedTips = todayKeys
        .where((k) => k.startsWith('rec:'))
        .map((k) => k.substring('rec:'.length))
        .toSet();

    final quickBreathingDone = todayKeys.contains('quick:breathing');
    final quickWalkDone = todayKeys.contains('quick:walk');

    if (!mounted) return;
    setState(() {
      _dismissedIds = dismissed;
      _completedTipIdsToday = completedTips;
      _quickBreathingDone = quickBreathingDone;
      _quickWalkDone = quickWalkDone;
    });
  }

  Future<void> _loadTipFeedback() async {
    final helpful = await getHelpfulTipIds();
    final notHelpful = await getNotHelpfulTipIds();
    if (!mounted) return;
    setState(() {
      _helpfulTipIds = helpful;
      _notHelpfulTipIds = notHelpful;
    });
  }

  Future<void> _refresh() async {
    final lang = _lastLang ?? 'en';
    setState(() => _future = _api.fetchRecommendations(lang: lang));
    await _loadSaved();
    await _loadDismissedAndCompleted();
  }

  Tip _tipById(String lang, String id) {
    final tips = getTips(lang);
    for (final t in tips) {
      if (t.id == id) return t;
    }
    return tips.first;
  }

  Future<void> _openRecommendationDetail(
    BuildContext context,
    String lang,
    String tipId,
  ) async {
    HapticFeedback.lightImpact();
    final tip = _tipById(lang, tipId);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RecommendationDetailsScreen(tip: tip),
      ),
    );
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

    final visibleFiltered = _categoryFilter == 'saved'
        ? filtered
        : filtered.where((t) => !_dismissedIds.contains(t.id)).toList();

    final dismissedByCategory = <String, int>{};
    for (final tip in allTips) {
      if (!_dismissedIds.contains(tip.id)) continue;
      dismissedByCategory[tip.category] = (dismissedByCategory[tip.category] ?? 0) + 1;
    }

    final ordered = [...visibleFiltered]
      ..sort((a, b) {
        final sb = _tipScore(b, dismissedByCategory);
        final sa = _tipScore(a, dismissedByCategory);
        return sb.compareTo(sa);
      });

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          final apiData = snapshot.data ?? {};
          final index = apiData['wellbeing_index'] as num?;
          final message =
              apiData['message'] as String? ?? loc.tipsPersonalizeHint;

          return ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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
              SerenitySectionHeader(title: loc.tipsForYou),
              const SizedBox(height: AppSpacing.titleToContent),
              if (snapshot.connectionState == ConnectionState.waiting)
                const LoadingShimmer(
                  padding: EdgeInsets.only(top: 8, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTileSkeleton(),
                      SizedBox(height: AppSpacing.betweenListItems),
                      ListTileSkeleton(),
                    ],
                  ),
                )
              else if (snapshot.hasError)
                AppErrorView(
                  error: snapshot.error!,
                  scrollable: false,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onRetry: _refresh,
                )
              else ...[
                if (index != null) ...[
                  Builder(
                    builder: (ctx) {
                      final ix = index.toDouble();
                      final tier = wellbeingTierFromIndex(ix);
                      final tipId = switch (tier) {
                        WellbeingTier.low => 'sleep_wind_down',
                        WellbeingTier.medium => 'quick_break_water',
                        WellbeingTier.high => 'breath_478',
                      };
                      return _buildIndexCard(
                        ctx,
                        ix,
                        loc,
                        onOpenDetail: () =>
                            _openRecommendationDetail(ctx, lang, tipId),
                      );
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.betweenListItems),
                Builder(
                  builder: (ctx) => _buildApiMessageCard(
                    ctx,
                    message,
                    loc,
                    onOpenDetails: () =>
                        _openRecommendationDetail(ctx, lang, 'mindset_pause'),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.section),
              ...ordered.map((tip) => _buildTipCard(context, tip, loc, theme)),
              if (ordered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: AuraCard(
                    borderRadius: 28,
                    glassBorder: true,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.tipsEmptyTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.tipsEmptySubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () async {
                            final done = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BreathingTimerScreen(),
                              ),
                            );
                            if (done == true) {
                              await markActionCompletedForDate(
                                'quick:breathing',
                                DateTime.now(),
                              );
                              await _loadDismissedAndCompleted();
                            }
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(loc.tipsBreathStart),
                        ),
                      ],
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
        onSelected: (_) {
          HapticFeedback.selectionClick();
          setState(() => _categoryFilter = value);
        },
      ),
    );
  }

  Widget _buildIndexCard(
    BuildContext context,
    double index,
    AppLocalizations loc, {
    VoidCallback? onOpenDetail,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tier = wellbeingTierFromIndex(index);
    final Color bg;
    final Color iconColor;
    final IconData icon;
    final String title;
    switch (tier) {
      case WellbeingTier.high:
        bg = cs.tertiaryContainer.withValues(alpha: 0.95);
        iconColor = cs.onTertiaryContainer;
        icon = Icons.sentiment_very_satisfied_rounded;
        title = loc.tipsIndexHigh;
      case WellbeingTier.medium:
        bg = cs.primaryContainer.withValues(alpha: 0.9);
        iconColor = cs.onPrimaryContainer;
        icon = Icons.sentiment_satisfied_rounded;
        title = loc.tipsIndexMedium;
      case WellbeingTier.low:
        bg = cs.errorContainer.withValues(alpha: 0.88);
        iconColor = cs.onErrorContainer;
        icon = Icons.sentiment_dissatisfied_rounded;
        title = loc.tipsIndexLow;
    }
    final pct = wellbeingIndexToDisplayPercent(index).round();
    return AuraCard(
      onTap: onOpenDetail,
      borderRadius: AppSpacing.radiusCard,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 26, color: iconColor),
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
                  '${loc.tipsIndexPrefix}${index.toStringAsFixed(2)} · $pct%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiMessageCard(
    BuildContext context,
    String message,
    AppLocalizations loc, {
    required VoidCallback onOpenDetails,
  }) {
    final theme = Theme.of(context);
    return AuraCard(
      onTap: onOpenDetails,
      borderRadius: AppSpacing.radiusCard,
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
    );
  }

  Widget _buildTipCard(
      BuildContext context, Tip tip, AppLocalizations loc, ThemeData theme) {
    final isSaved = _savedIds.contains(tip.id);
    final completedToday = _completedTipIdsToday.contains(tip.id);
    return AuraCard(
      onTap: () => _openDetails(tip),
      margin: const EdgeInsets.only(bottom: AppSpacing.betweenListItems),
      borderRadius: AppSpacing.radiusCard,
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
              if (completedToday)
                Padding(
                  padding: const EdgeInsets.only(right: 4, top: 2),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              IconButton(
                tooltip: loc.tipsLikeTooltip,
                icon: const Icon(Icons.thumb_up_outlined, size: 20),
                onPressed: () => _sendFeedback(context, tip.id, 'like'),
              ),
              IconButton(
                tooltip: loc.tipsDislikeTooltip,
                icon: const Icon(Icons.thumb_down_outlined, size: 20),
                onPressed: () => _sendFeedback(context, tip.id, 'dislike'),
              ),
              IconButton(
                tooltip: loc.tipsSave,
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
              IconButton(
                tooltip: loc.recDetailsDismiss,
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                onPressed: () async {
                  await dismissTipId(tip.id);
                  await _loadDismissedAndCompleted();
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.betweenListItems),
          SerenitySectionHeader(title: loc.tipsWhyHelp),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tip.whyItHelps,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          SerenitySectionHeader(title: loc.tipsHowToDo),
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
                  onPressed: () async {
                    final done = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BreathingTimerScreen(),
                      ),
                    );
                    if (done == true) {
                      await markActionCompletedForDate(
                        'rec:${tip.id}',
                        DateTime.now(),
                      );
                      await _loadDismissedAndCompleted();
                    }
                  },
                  icon: const Icon(Icons.timer_rounded, size: 20),
                  label: Text(loc.tipsStartBreathing),
                ),
              )
            else if (tip.action == TipAction.logWalk)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await _logWalk(context, loc);
                    await markActionCompletedForDate(
                      'rec:${tip.id}',
                      DateTime.now(),
                    );
                    await _loadDismissedAndCompleted();
                  },
                  icon: const Icon(Icons.directions_walk_rounded, size: 20),
                  label: Text(loc.tipsLogWalk),
                ),
              ),
          ],
        ],
      ),
    );
  }

  int _tipScore(Tip tip, Map<String, int> dismissedByCategory) {
    var score = 0;

    if (_savedIds.contains(tip.id)) score += 50;
    if (_completedTipIdsToday.contains(tip.id)) score += 30;

    if (_helpfulTipIds.contains(tip.id)) score += 18;
    if (_notHelpfulTipIds.contains(tip.id)) score -= 18;

    if (_quickBreathingDone && tip.action == TipAction.breathingTimer) {
      score += 10;
    }
    if (_quickWalkDone && tip.action == TipAction.logWalk) {
      score += 10;
    }

    final dismissedCount = dismissedByCategory[tip.category] ?? 0;
    if (dismissedCount >= 2) {
      if (tip.category == 'breathing') score -= 12;
      if (tip.category == 'movement') score -= 6;
      if (tip.category == 'sleep') score -= 4;
    }

    // Soft penalty for cards without actionable value.
    if (tip.action == TipAction.none) score -= 4;

    return score;
  }

  Future<void> _openDetails(Tip tip) async {
    await Navigator.push(
      context,
      PageRouteBuilder<void>(
        pageBuilder: (ctx, animation, secondaryAnimation) => RecommendationDetailsScreen(tip: tip),
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 240),
      ),
    );
    await _loadDismissedAndCompleted();
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
      SerenityMessenger.show(context, loc.tipsLogWalkDone);
    } catch (e) {
      if (!mounted) return;
      final msg = localizedApiErrorMessage(e, loc);
      SerenityMessenger.show(context, msg, kind: SerenitySnackKind.error);
    }
  }

  Future<void> _sendFeedback(
    BuildContext context,
    String adviceId,
    String feedback,
  ) async {
    final loc = AppLocalizations.of(context);
    try {
      await _api.postAdviceFeedback(adviceId: adviceId, feedback: feedback);
      if (!context.mounted) return;

      final helpful = feedback == 'like';
      await setTipHelpful(adviceId, helpful: helpful);
      setState(() {
        if (helpful) {
          _helpfulTipIds.add(adviceId);
          _notHelpfulTipIds.remove(adviceId);
        } else {
          _notHelpfulTipIds.add(adviceId);
          _helpfulTipIds.remove(adviceId);
        }
      });

      SerenityMessenger.show(
        context,
        helpful ? loc.recDetailsHelpful : loc.recDetailsNotHelpful,
        kind: helpful ? SerenitySnackKind.success : SerenitySnackKind.info,
      );
    } catch (e) {
      if (!context.mounted) return;
      final msg = localizedApiErrorMessage(e, loc);
      SerenityMessenger.show(context, msg, kind: SerenitySnackKind.error);
    }
  }
}
