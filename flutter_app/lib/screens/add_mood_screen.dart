import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/aura_card.dart';
import '../design_system/design_tokens.dart';
import '../l10n/app_localizations.dart';
import '../services/api_exception.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/serenity_button.dart';
import '../widgets/serenity_messenger.dart';

class AddMoodScreen extends StatefulWidget {
  const AddMoodScreen({
    super.key,
    this.onSaved,
    this.embeddedInShell = false,
  });

  /// When set (e.g. full-screen flow), called after a successful save instead of only a snackbar.
  final VoidCallback? onSaved;
  /// Less vertical padding when shown under a flow [Scaffold] (no bottom tab bar).
  final bool embeddedInShell;

  @override
  State<AddMoodScreen> createState() => _AddMoodScreenState();
}

class _AddMoodScreenState extends State<AddMoodScreen> {
  final ApiService _api = ApiService();

  double _mood = 7;
  double _stress = 4;
  double _energy = 6;
  String _category = 'none';
  double _sleepHours = 7;
  double _activityMinutes = 20;
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
    });
    final loc = AppLocalizations.of(context);
    try {
      await _api.createMoodEntry(
        mood: _mood.round(),
        stress: _stress.round(),
        energy: _energy.round(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        date: _selectedDate,
        category: _category == 'none' ? null : _category,
        sleepHours: _sleepHours,
        activityMinutes: _activityMinutes.round(),
      );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      if (widget.onSaved != null) {
        widget.onSaved!();
      } else {
        SerenityMessenger.show(context, loc.entrySaved);
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? e.userMessage : '${loc.errorPrefix}$e';
      SerenityMessenger.show(context, msg, kind: SerenitySnackKind.error);
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final topPad =
        widget.embeddedInShell ? AppSpacing.sm : AppSpacing.screenTop;
    final bottomPad = widget.embeddedInShell ? 32.0 : 110.0;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  topPad,
                  AppSpacing.screenHorizontal,
                  bottomPad,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      loc.addTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      loc.addSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section + 4),
                    _buildSliderCard(
                      context: context,
                      label: loc.addMoodLabel,
                      description: loc.addMoodDesc,
                      icon: Icons.emoji_emotions_rounded,
                      value: _mood,
                      colorForValue: _moodColor,
                      onChanged: (v) => setState(() => _mood = v),
                    ),
                    SizedBox(height: AppSpacing.betweenCards),
                    _buildSliderCard(
                      context: context,
                      label: loc.addStressLabel,
                      description: loc.addStressDesc,
                      icon: Icons.spa_outlined,
                      value: _stress,
                      colorForValue: _stressColor,
                      onChanged: (v) => setState(() => _stress = v),
                    ),
                    SizedBox(height: AppSpacing.betweenCards),
                    _buildSliderCard(
                      context: context,
                      label: loc.addEnergyLabel,
                      description: loc.addEnergyDesc,
                      icon: Icons.bolt_rounded,
                      value: _energy,
                      colorForValue: _energyColor,
                      onChanged: (v) => setState(() => _energy = v),
                    ),
                    SizedBox(height: AppSpacing.betweenCards),
                    AuraCard(
                      borderRadius: DsRadii.lg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.addSleepActivityTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.titleToContent),
                          _buildSleepAndActivity(theme, loc),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            loc.addCategoryTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildCategoryChips(theme, loc),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.betweenCards),
                    AuraCard(
                      borderRadius: DsRadii.lg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.addJournalTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _noteController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: loc.addOptionalNoteHint,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.event_rounded),
                            label: Text(loc.addChangeDate),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            12,
            AppSpacing.screenHorizontal,
            16,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35)),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                offset: const Offset(0, -6),
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SerenityButton(
              label: _submitting ? loc.quickLogSheetSaving : loc.addSave,
              icon: _submitting ? Icons.hourglass_top_rounded : Icons.check_rounded,
              onPressed: _submitting ? null : _submit,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(ThemeData theme, AppLocalizations loc) {
    final labels = <String, String>{
      'none': loc.addCategoryNone,
      'work': loc.addCategoryWork,
      'relationships': loc.addCategoryRelationships,
      'health': loc.addCategoryHealth,
    };

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: labels.entries.map((entry) {
        final selected = _category == entry.key;
        return FilterChip(
          label: Text(entry.value),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) {
            setState(() {
              _category = entry.key;
            });
            HapticFeedback.selectionClick();
          },
        );
      }).toList(),
    );
  }

  Widget _buildSleepAndActivity(ThemeData theme, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(loc.addSleepLabel, style: theme.textTheme.bodyLarge),
            Text(
              '${_sleepHours.toStringAsFixed(1)} h',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Slider(
          min: 0,
          max: 12,
          divisions: 24,
          value: _sleepHours,
          onChanged: (v) => setState(() => _sleepHours = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(loc.addActivityLabel, style: theme.textTheme.bodyLarge),
            Text(
              '${_activityMinutes.round()} min',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Slider(
          min: 0,
          max: 300,
          divisions: 30,
          value: _activityMinutes,
          onChanged: (v) => setState(() => _activityMinutes = v),
        ),
      ],
    );
  }

  Widget _buildSliderCard({
    required BuildContext context,
    required String label,
    required String description,
    required IconData icon,
    required double value,
    required Color Function(double) colorForValue,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    final color = colorForValue(value);

    return AuraCard(
      borderRadius: DsRadii.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(DsRadii.md),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(DsRadii.pill),
                ),
                child: Text(
                  value.round().toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15, elevation: 3),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 26),
              trackHeight: 6,
              activeTrackColor: color,
              inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
            ),
            child: Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: value,
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Color _moodColor(double value) {
    final t = (value - 1) / 9;
    return Color.lerp(const Color(0xFF7B74D9), const Color(0xFF5FA88A), t.clamp(0.0, 1.0))!;
  }

  Color _stressColor(double value) {
    final t = (value - 1) / 9;
    return Color.lerp(const Color(0xFF6EB89A), const Color(0xFFD67A8A), t.clamp(0.0, 1.0))!;
  }

  Color _energyColor(double value) {
    final t = (value - 1) / 9;
    return Color.lerp(const Color(0xFF8A8CB8), const Color(0xFFE6B86A), t.clamp(0.0, 1.0))!;
  }
}
