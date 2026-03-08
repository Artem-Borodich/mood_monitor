class MoodEntry {
  final int id;
  final int mood;
  final int stress;
  final int energy;
  final String? note;
  final String? category;
  final double? sleepHours;
  final int? activityMinutes;
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.mood,
    required this.stress,
    required this.energy,
    required this.createdAt,
    this.note,
    this.category,
    this.sleepHours,
    this.activityMinutes,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as int,
      mood: json['mood'] as int,
      stress: json['stress'] as int,
      energy: json['energy'] as int,
      note: json['note'] as String?,
      category: json['category'] as String?,
      sleepHours: (json['sleep_hours'] as num?)?.toDouble(),
      activityMinutes: json['activity_minutes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  double get wellbeingIndex {
    return double.parse(
      (0.4 * mood + 0.3 * energy - 0.3 * stress).toStringAsFixed(2),
    );
  }
}

