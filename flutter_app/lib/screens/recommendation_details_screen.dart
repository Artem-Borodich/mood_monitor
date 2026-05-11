import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../locale_store.dart';
import '../models/tip.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../design_system/aura_card.dart';
import '../widgets/serenity_messenger.dart';
import 'breathing_timer_screen.dart';

class RecommendationDetailsScreen extends StatefulWidget {
  const RecommendationDetailsScreen({
    super.key,
    required this.tip,
  });

  final Tip tip;

  @override
  State<RecommendationDetailsScreen> createState() =>
      _RecommendationDetailsScreenState();
}

class _RecommendationDetailsScreenState
    extends State<RecommendationDetailsScreen> {
  final ApiService _api = ApiService();

  bool _loading = false;
  bool _saved = false;
  bool _completedToday = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _loadFlags();
  }

  Future<void> _loadFlags() async {
    final tipId = widget.tip.id;
    final today = DateTime.now();

    final saved = await getSavedTipIds();
    final dismissed = await getDismissedTipIds();
    final completed = await isActionCompletedForDate('rec:$tipId', today);

    if (!mounted) return;
    setState(() {
      _saved = saved.contains(tipId);
      _dismissed = dismissed.contains(tipId);
      _completedToday = completed;
    });
  }

  Future<void> _markCompletedToday() async {
    await markActionCompletedForDate('rec:${widget.tip.id}', DateTime.now());
    if (!mounted) return;
    setState(() => _completedToday = true);
  }

  String _estimatedDuration(AppLocalizations loc) {
    // Tip model doesn't carry duration fields, so we derive a calm, UX-friendly estimate.
    switch (widget.tip.category) {
      case 'breathing':
        return loc.locale.languageCode == 'ru' ? '2 мин' : '2 min';
      case 'movement':
      case 'quick_breaks':
        if (widget.tip.category == 'movement') {
          return loc.locale.languageCode == 'ru' ? '10–15 мин' : '10–15 min';
        }
        return loc.locale.languageCode == 'ru' ? '1–2 мин' : '1–2 min';
      case 'sleep':
        return loc.locale.languageCode == 'ru' ? '10–15 мин' : '10–15 min';
      case 'mindset':
        return loc.locale.languageCode == 'ru' ? '1 мин' : '1 min';
      default:
        return loc.locale.languageCode == 'ru' ? 'Пара минут' : 'A few minutes';
    }
  }

  String _expectedBenefit(AppLocalizations loc) {
    final lang = loc.locale.languageCode;
    if (widget.tip.action == TipAction.breathingTimer) {
      return lang == 'ru'
          ? 'Меньше напряжения и более спокойное состояние за ~2 минуты.'
          : 'Feel calmer and settle your body in about 2 minutes.';
    }
    if (widget.tip.action == TipAction.logWalk) {
      return lang == 'ru'
          ? 'Мягкий подъём энергии и снижение напряжения после прогулки.'
          : 'A gentle energy lift and less tension after a short walk.';
    }

    if (lang == 'ru') {
      return 'Небольшой шаг, который помогает вашему состоянию выровняться.';
    }
    return 'A small step that helps your state feel more aligned.';
  }

  IconData _badgeIcon() {
    return _completedToday ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded;
  }

  Future<void> _onStartPressed() async {
    final loc = AppLocalizations.of(context);
    if (_loading) return;

    setState(() => _loading = true);
    var didComplete = false;
    try {
      if (widget.tip.action == TipAction.breathingTimer) {
        final done = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => const BreathingTimerScreen(),
          ),
        );
        if (done == true) {
          await _markCompletedToday();
          didComplete = true;
        }
      } else if (widget.tip.action == TipAction.logWalk) {
        await _logWalk(context, loc);
        await _markCompletedToday();
        didComplete = true;
      } else {
        await _markCompletedToday();
        didComplete = true;
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      SerenityMessenger.show(context, e.userMessage, kind: SerenitySnackKind.error);
    } catch (e) {
      if (!mounted) return;
      final msg = '${loc.errorPrefix}$e';
      SerenityMessenger.show(context, msg, kind: SerenitySnackKind.error);
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }

    if (!mounted) return;
    if (didComplete) {
      SerenityMessenger.show(context, loc.recDoneBadge);
    }
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
  }

  Future<void> _sendFeedback(String feedback) async {
    final loc = AppLocalizations.of(context);
    try {
      await _api.postAdviceFeedback(adviceId: widget.tip.id, feedback: feedback);
      if (!mounted) return;

      final helpful = feedback == 'like';
      await setTipHelpful(widget.tip.id, helpful: helpful);

      SerenityMessenger.show(
        context,
        helpful ? loc.recDetailsHelpful : loc.recDetailsNotHelpful,
        kind: helpful ? SerenitySnackKind.success : SerenitySnackKind.info,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? e.userMessage : '${loc.errorPrefix}$e';
      SerenityMessenger.show(context, msg, kind: SerenitySnackKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final title = widget.tip.title;
    final duration = _estimatedDuration(loc);
    final expectedBenefit = _expectedBenefit(loc);
    final steps = widget.tip.howToDo;

    String ctaLabel;
    if (widget.tip.action == TipAction.breathingTimer) {
      ctaLabel = loc.tipsBreathStart;
    } else if (widget.tip.action == TipAction.logWalk) {
      ctaLabel = loc.tipsLogWalk;
    } else {
      ctaLabel = loc.recDetailsDoneForToday;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    tooltip: loc.cancel,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Spacer(),
                  if (_completedToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Icon(_badgeIcon(), size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            loc.recDoneBadge,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.screenTop,
                  AppSpacing.screenHorizontal,
                  AppSpacing.screenBottom,
                ),
                children: [
                  AuraCard(
                    glassBorder: true,
                    borderRadius: 32,
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.tip.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _MetaChip(
                              icon: Icons.timer_rounded,
                              label: loc.recDetailsEstimatedDuration,
                              value: duration,
                            ),
                            const SizedBox(width: 10),
                            _MetaChip(
                              icon: Icons.self_improvement_rounded,
                              label: loc.recDetailsExpectedBenefit,
                              value: expectedBenefit,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SectionHeader(title: loc.tipsWhyHelp),
                        const SizedBox(height: 8),
                        Text(
                          widget.tip.whyItHelps,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        _SectionHeader(title: loc.recDetailsActionSteps),
                        const SizedBox(height: 10),
                        ...steps.asMap().entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${e.key + 1}. ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    e.value,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _dismissed
                              ? null
                              : () async {
                                  await dismissTipId(widget.tip.id);
                                  if (!mounted) return;
                                  Navigator.of(context).pop(true);
                                },
                          icon: const Icon(Icons.block_rounded),
                          label: Text(loc.recDetailsDismiss),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _onStartPressed,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(ctaLabel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                14,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: loc.tipsSave,
                        onPressed: () async {
                          await toggleSavedTipId(widget.tip.id);
                          await _loadFlags();
                        },
                        icon: Icon(
                          _saved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: _saved
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        tooltip: loc.recDetailsHelpful,
                        onPressed: () => _sendFeedback('like'),
                        icon: const Icon(Icons.thumb_up_outlined),
                      ),
                      IconButton(
                        tooltip: loc.recDetailsNotHelpful,
                        onPressed: () => _sendFeedback('dislike'),
                        icon: const Icon(Icons.thumb_down_outlined),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
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
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.45),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

