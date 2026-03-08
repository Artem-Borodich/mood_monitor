import 'package:flutter/material.dart';

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
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood entry saved')),
      );
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you feel today?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          _buildSlider(
            label: 'Mood',
            value: _mood,
            color: Colors.blue,
            onChanged: (v) => setState(() => _mood = v),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            label: 'Stress',
            value: _stress,
            color: Colors.red,
            onChanged: (v) => setState(() => _stress = v),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            label: 'Energy',
            value: _energy,
            color: Colors.green,
            onChanged: (v) => setState(() => _energy = v),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Optional note',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Date: $dateString'),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _pickDate,
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.round().toString()),
          ],
        ),
        Slider(
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: color,
          value: value,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

