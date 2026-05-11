import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../models/mood_entry.dart';
import '../../services/api_exception.dart';
import '../../services/api_service.dart';
import '../../theme/app_decoration.dart';
import '../../theme/app_spacing.dart';

/// Opens a bottom sheet to adjust mood / stress / energy (and optional fields)
/// before saving — replaces one-tap instant submit from the dashboard.
Future<bool> showQuickLogBottomSheet(
  BuildContext context, {
  required MoodEntry template,
  required ApiService api,
  required AppLocalizations loc,
}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    backgroundColor: Colors.transparent,
    builder: (ctx) => _QuickLogSheet(
      template: template,
      api: api,
      loc: loc,
    ),
  );
  return ok == true;
}

class _QuickLogSheet extends StatefulWidget {
  const _QuickLogSheet({
    required this.template,
    required this.api,
    required this.loc,
  });

  final MoodEntry template;
  final ApiService api;
  final AppLocalizations loc;

  @override
  State<_QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends State<_QuickLogSheet> {
  late double _mood;
  late double _stress;
  late double _energy;
  late double _sleepHours;
  late double _activityMinutes;
  late String _category;
  late TextEditingController _noteController;
  bool _advancedOpen = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _applyTemplate(widget.template);
    _noteController = TextEditingController(text: widget.template.note ?? '');
  }

  void _applyTemplate(MoodEntry t) {
    _mood = t.mood.toDouble();
    _stress = t.stress.toDouble();
    _energy = t.energy.toDouble();
    _sleepHours = t.sleepHours ?? 7;
    _activityMinutes = (t.activityMinutes ?? 20).toDouble();
    var cat = t.category ?? 'none';
    if (cat != 'none' &&
        cat != 'work' &&
        cat != 'relationships' &&
        cat != 'health') {
      cat = 'none';
    }
    _category = cat;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final loc = widget.loc;
    try {
      await widget.api.createMoodEntry(
        mood: _mood.round(),
        stress: _stress.round(),
        energy: _energy.round(),
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        date: DateTime.now(),
        category: _category == 'none' ? null : _category,
        sleepHours: _sleepHours,
        activityMinutes: _activityMinutes.round(),
      );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? e.userMessage : '${loc.errorPrefix}$e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = widget.loc;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final radius = BorderRadius.circular(28);

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.06),
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                theme.colorScheme.surface,
              ],
            ),
            border: AppDecorations.glassBorderLight(context),
            boxShadow: AppDecorations.cardFloating(context),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                  child: Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppDecorations.primaryHeroGradient(),
                          boxShadow: AppDecorations.cardSubtle(context),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.quickLogTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              loc.quickLogSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: loc.cancel,
                        onPressed: _saving ? null : () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _saving
                      ? null
                      : () {
                          setState(() {
                            _applyTemplate(widget.template);
                            _noteController.text = widget.template.note ?? '';
                          });
                          HapticFeedback.selectionClick();
                        },
                  icon: const Icon(Icons.restart_alt_rounded, size: 20),
                  label: Text(loc.quickLogSheetReset),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      16 + bottomInset,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SliderBlock(
                          icon: Icons.emoji_emotions_rounded,
                          label: loc.addMoodLabel,
                          value: _mood,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (v) => setState(() => _mood = v),
                        ),
                        const SizedBox(height: AppSpacing.betweenCards),
                        _SliderBlock(
                          icon: Icons.psychology_alt_rounded,
                          label: loc.addStressLabel,
                          value: _stress,
                          activeColor: theme.colorScheme.error,
                          onChanged: (v) => setState(() => _stress = v),
                        ),
                        const SizedBox(height: AppSpacing.betweenCards),
                        _SliderBlock(
                          icon: Icons.bolt_rounded,
                          label: loc.addEnergyLabel,
                          value: _energy,
                          activeColor: theme.colorScheme.tertiary,
                          onChanged: (v) => setState(() => _energy = v),
                        ),
                        const SizedBox(height: AppSpacing.betweenCards),
                        ExpansionTile(
                          initiallyExpanded: _advancedOpen,
                          onExpansionChanged: (o) => setState(() => _advancedOpen = o),
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            loc.quickLogSheetAdvanced,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          children: [
                            _SleepRow(
                              label: loc.addSleepLabel,
                              value: _sleepHours,
                              max: 12,
                              divisions: 24,
                              valueSuffix: '${_sleepHours.toStringAsFixed(1)} h',
                              onChanged: (v) => setState(() => _sleepHours = v),
                            ),
                            const SizedBox(height: 12),
                            _SleepRow(
                              label: loc.addActivityLabel,
                              value: _activityMinutes,
                              max: 300,
                              divisions: 30,
                              valueSuffix: '${_activityMinutes.round()} min',
                              onChanged: (v) => setState(() => _activityMinutes = v),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                loc.addCategoryTitle,
                                style: theme.textTheme.labelLarge,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _catChip(theme, loc, loc.addCategoryNone, 'none'),
                                _catChip(theme, loc, loc.addCategoryWork, 'work'),
                                _catChip(theme, loc, loc.addCategoryRelationships, 'relationships'),
                                _catChip(theme, loc, loc.addCategoryHealth, 'health'),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.quickLogSheetNote,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteController,
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: loc.addOptionalNoteHint,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.betweenSections),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _saving ? null : () => Navigator.pop(context, false),
                                child: Text(loc.quickLogSheetCancel),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: FilledButton.icon(
                                onPressed: _saving ? null : _save,
                                icon: _saving
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                    : const Icon(Icons.check_rounded),
                                label: Text(
                                  _saving ? loc.quickLogSheetSaving : loc.quickLogSheetSave,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _catChip(ThemeData theme, AppLocalizations loc, String label, String value) {
    final sel = _category == value;
    return FilterChip(
      label: Text(label),
      selected: sel,
      onSelected: _saving
          ? (_) {}
          : (_) {
              setState(() => _category = value);
            },
      showCheckmark: false,
    );
  }
}

class _SliderBlock extends StatelessWidget {
  const _SliderBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: AppDecorations.cardSubtle(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: activeColor, size: 22),
              const SizedBox(width: 10),
              Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                value.round().toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: activeColor,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(1, 10),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SleepRow extends StatelessWidget {
  const _SleepRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.valueSuffix,
    this.max = 12,
    this.divisions = 24,
  });

  final String label;
  final double value;
  final String valueSuffix;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(
              valueSuffix,
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Slider(
          value: value.clamp(0, max),
          min: 0,
          max: max,
          divisions: divisions,
          label: valueSuffix,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
