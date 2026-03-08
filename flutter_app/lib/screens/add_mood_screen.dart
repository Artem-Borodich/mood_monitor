import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_service.dart';

class AddMoodScreen extends StatefulWidget {
  const AddMoodScreen({super.key});

  @override
  State<AddMoodScreen> createState() => _AddMoodScreenState();
}

class _AddMoodScreenState extends State<AddMoodScreen> {
  final ApiService _api = ApiService();

  double _mood = 5;
  double _stress = 5;
  double _energy = 5;
   // Optional extra fields
  String _category = 'none';
  double _sleepHours = 7;
  double _activityMinutes = 0;
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _submitting = false;
  bool _pressedSave = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood entry saved')),
      );
      setState(() {
        _pressedSave = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
    final dateString =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.addTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.addSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _buildCategoryChips(theme, loc),
          const SizedBox(height: 16),
          _buildSleepAndActivity(theme, loc),
          const SizedBox(height: 24),
          _buildSliderCard(
            context: context,
            label: loc.addMoodLabel,
            description: loc.addMoodDesc,
            icon: Icons.emoji_emotions_rounded,
            value: _mood,
            colorForValue: _moodColor,
            onChanged: (v) => setState(() => _mood = v),
          ),
          const SizedBox(height: 16),
          _buildSliderCard(
            context: context,
            label: loc.addStressLabel,
            description: loc.addStressDesc,
            icon: Icons.local_fire_department_rounded,
            value: _stress,
            colorForValue: _stressColor,
            onChanged: (v) => setState(() => _stress = v),
          ),
          const SizedBox(height: 16),
          _buildSliderCard(
            context: context,
            label: loc.addEnergyLabel,
            description: loc.addEnergyDesc,
            icon: Icons.bolt_rounded,
            value: _energy,
            colorForValue: _energyColor,
            onChanged: (v) => setState(() => _energy = v),
          ),
          const SizedBox(height: 24),
          Text(
            loc.addOptionalNote,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: loc.addOptionalNoteHint,
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                dateString,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _pickDate,
                child: Text(loc.addChangeDate),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: AnimatedScale(
              scale: _pressedSave ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () {
                          setState(() {
                            _pressedSave = true;
                          });
                          _submit();
                        },
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(loc.addSave),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme, AppLocalizations loc) {
    final labels = <String, String>{
      'none': loc.addCategoryNone,
      'work': loc.addCategoryWork,
      'relationships': loc.addCategoryRelationships,
      'health': loc.addCategoryHealth,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.addCategoryTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
        ),
      ],
    );
  }

  Widget _buildSleepAndActivity(ThemeData theme, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.addSleepActivityTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.nights_stay_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          loc.addSleepLabel,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Text(
                      _sleepHours.toStringAsFixed(1),
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
                Slider(
                  min: 0,
                  max: 12,
                  divisions: 24,
                  value: _sleepHours,
                  label: _sleepHours.toStringAsFixed(1),
                  onChanged: (v) => setState(() => _sleepHours = v),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_walk_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          loc.addActivityLabel,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Text(
                      _activityMinutes.round().toString(),
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
                Slider(
                  min: 0,
                  max: 300,
                  divisions: 30,
                  value: _activityMinutes,
                  label: _activityMinutes.round().toString(),
                  onChanged: (v) => setState(() => _activityMinutes = v),
                ),
              ],
            ),
          ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
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
                    color: color.withOpacity(0.15),
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
                inactiveTrackColor: theme.colorScheme.surfaceVariant,
                thumbColor: color,
                overlayColor: color.withOpacity(0.2),
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

