import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/serenity_button.dart';
import '../widgets/serenity_card.dart';

class AddMoodScreen extends StatefulWidget {
  const AddMoodScreen({super.key});

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.entrySaved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.errorPrefix}$e')),
      );
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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.screenTop,
              AppSpacing.screenHorizontal,
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your daily check-in helps us understand your patterns and provide better advice.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                _buildSliderCard(
                  context: context,
                  label: loc.addMoodLabel,
                  description: loc.addMoodDesc,
                  icon: Icons.emoji_emotions_rounded,
                  value: _mood,
                  colorForValue: _moodColor,
                  onChanged: (v) => setState(() => _mood = v),
                ),
                const SizedBox(height: AppSpacing.betweenCards),
                _buildSliderCard(
                  context: context,
                  label: loc.addStressLabel,
                  description: loc.addStressDesc,
                  icon: Icons.psychology_alt_rounded,
                  value: _stress,
                  colorForValue: _stressColor,
                  onChanged: (v) => setState(() => _stress = v),
                ),
                const SizedBox(height: AppSpacing.betweenCards),
                _buildSliderCard(
                  context: context,
                  label: loc.addEnergyLabel,
                  description: loc.addEnergyDesc,
                  icon: Icons.bolt_rounded,
                  value: _energy,
                  colorForValue: _energyColor,
                  onChanged: (v) => setState(() => _energy = v),
                ),
                const SizedBox(height: AppSpacing.betweenCards),
                SerenityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.addSleepActivityTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.titleToContent),
                      _buildSleepAndActivity(theme, loc),
                      const SizedBox(height: 8),
                      _buildCategoryChips(theme, loc),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.betweenCards),
                SerenityCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journal / Notes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _noteController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: loc.addOptionalNoteHint,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.event_rounded),
                          label: Text(loc.addChangeDate),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: SerenityButton(
            label: _submitting ? 'Saving...' : loc.addSave,
            icon: _submitting ? Icons.sync_rounded : Icons.check_circle_outline_rounded,
            onPressed: _submitting ? null : _submit,
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
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _category = entry.key;
                });
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
            Text(loc.addSleepLabel, style: theme.textTheme.bodyMedium),
            Text('${_sleepHours.toStringAsFixed(1)} h', style: theme.textTheme.labelLarge),
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
            Text(loc.addActivityLabel, style: theme.textTheme.bodyMedium),
            Text('${_activityMinutes.round()} min', style: theme.textTheme.labelLarge),
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

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    value.round().toString(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 18),
                activeTrackColor: color,
                inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.2),
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
      ),
    );
  }

  Color _moodColor(double value) {
    // 1 (red) -> 10 (green)
    final t = (value - 1) / 9;
    return Color.lerp(Colors.red, Colors.green, t.clamp(0.0, 1.0))!;
  }

  Color _stressColor(double value) {
    // 1 (green, low) -> 10 (red, high)
    final t = (value - 1) / 9;
    return Color.lerp(Colors.green, Colors.red, t.clamp(0.0, 1.0))!;
  }

  Color _energyColor(double value) {
    // 1 (grey) -> 10 (amber)
    final t = (value - 1) / 9;
    return Color.lerp(Colors.grey, Colors.amber, t.clamp(0.0, 1.0))!;
  }
}

