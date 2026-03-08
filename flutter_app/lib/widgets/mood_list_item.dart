import 'package:flutter/material.dart';

import '../models/mood_entry.dart';

class MoodListItem extends StatelessWidget {
  const MoodListItem({
    super.key,
    required this.entry,
  });

  final MoodEntry entry;

  @override
  Widget build(BuildContext context) {
    final dateString =
        '${entry.createdAt.year}-${entry.createdAt.month.toString().padLeft(2, '0')}-${entry.createdAt.day.toString().padLeft(2, '0')}';

    return Card(
      child: ListTile(
        title: Text('Mood: ${entry.mood}  •  Stress: ${entry.stress}  •  Energy: ${entry.energy}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $dateString'),
            if (entry.note != null && entry.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(entry.note!),
              ),
          ],
        ),
      ),
    );
  }
}

