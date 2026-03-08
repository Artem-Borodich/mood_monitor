import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/mood_entry.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';

class EditMoodScreen extends StatefulWidget {
  const EditMoodScreen({super.key, required this.entry});

  final MoodEntry entry;

  @override
  State<EditMoodScreen> createState() => _EditMoodScreenState();
}

class _EditMoodScreenState extends State<EditMoodScreen> {
  final ApiService _api = ApiService();
  late double _mood;
  late double _stress;
  late double _energy;
  late String _category;
  late double _sleepHours;
  late double _activityMinutes;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _mood = e.mood.toDouble();
    _stress = e.stress.toDouble();
    _energy = e.energy.toDouble();
    _category = e.category ?? 'none';
    if (_category != 'none' && _category != 'work' && _category != 'relationships' && _category != 'health') {
      _category = 'none';
    }
    _sleepHours = e.sleepHours ?? 7;
    _activityMinutes = (e.activityMinutes ?? 0).toDouble();
    _noteController = TextEditingController(text: e.note ?? '');
    _selectedDate = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await _api.updateMoodEntry(
        widget.entry.id,
        mood: _mood.round(),
        stress: _stress.round(),
        energy: _energy.round(),
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        date: _selectedDate,
        category: _category == 'none' ? null : _category,
        sleepHours: _sleepHours,
        activityMinutes: _activityMinutes.round(),
      );
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.entryUpdated)));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.errorPrefix}$e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final dateString =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text(loc.editEntry)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.screenTop, AppSpacing.screenHorizontal, AppSpacing.screenBottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSliderCard(theme, loc.addMoodLabel, loc.addMoodDesc, Icons.emoji_emotions_rounded, _mood, (v) => setState(() => _mood = v), _moodColor),
            const SizedBox(height: AppSpacing.betweenCards),
            _buildSliderCard(theme, loc.addStressLabel, loc.addStressDesc, Icons.local_fire_department_rounded, _stress, (v) => setState(() => _stress = v), _stressColor),
            const SizedBox(height: AppSpacing.betweenCards),
            _buildSliderCard(theme, loc.addEnergyLabel, loc.addEnergyDesc, Icons.bolt_rounded, _energy, (v) => setState(() => _energy = v), _energyColor),
            const SizedBox(height: AppSpacing.betweenSections),
            Text(loc.addCategoryTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.titleToContent),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _chip(loc.addCategoryNone, 'none'),
                _chip(loc.addCategoryWork, 'work'),
                _chip(loc.addCategoryRelationships, 'relationships'),
                _chip(loc.addCategoryHealth, 'health'),
              ],
            ),
            const SizedBox(height: AppSpacing.betweenSections),
            Text(loc.addSleepActivityTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.titleToContent),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.addSleepLabel, style: theme.textTheme.bodyMedium),
                        Text(_sleepHours.toStringAsFixed(1), style: theme.textTheme.labelLarge),
                      ],
                    ),
                    Slider(min: 0, max: 12, divisions: 24, value: _sleepHours, label: _sleepHours.toStringAsFixed(1), onChanged: (v) => setState(() => _sleepHours = v)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.addActivityLabel, style: theme.textTheme.bodyMedium),
                        Text(_activityMinutes.round().toString(), style: theme.textTheme.labelLarge),
                      ],
                    ),
                    Slider(min: 0, max: 300, divisions: 30, value: _activityMinutes, label: _activityMinutes.round().toString(), onChanged: (v) => setState(() => _activityMinutes = v)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.betweenSections),
            Text(loc.addOptionalNote, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.titleToContent),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: loc.addOptionalNoteHint,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: AppSpacing.betweenCards),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(dateString, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Text(loc.addChangeDate),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(loc.addSave),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard(ThemeData theme, String label, String description, IconData icon, double value, ValueChanged<double> onChanged, Color Function(double) colorForValue) {
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
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(value.round().toString(), style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: color)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                activeTrackColor: color,
                inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.2),
              ),
              child: Slider(min: 1, max: 10, divisions: 9, value: value, label: value.round().toString(), onChanged: onChanged),
            ),
          ],
        ),
      ),
    );
  }

  Color _moodColor(double value) => Color.lerp(Colors.red, Colors.green, ((value - 1) / 9).clamp(0.0, 1.0))!;
  Color _stressColor(double value) => Color.lerp(Colors.green, Colors.red, ((value - 1) / 9).clamp(0.0, 1.0))!;
  Color _energyColor(double value) => Color.lerp(Colors.grey, Colors.amber, ((value - 1) / 9).clamp(0.0, 1.0))!;

  Widget _chip(String label, String value) {
    final selected = _category == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _category = value),
    );
  }
}
