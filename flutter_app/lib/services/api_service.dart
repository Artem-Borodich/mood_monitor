import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/mood_entry.dart';

class ApiService {
  ApiService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://localhost:8000';

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<List<MoodEntry>> fetchMoodEntries() async {
    final response = await _client.get(_uri('/mood'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load mood entries');
    }
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MoodEntry> createMoodEntry({
    required int mood,
    required int stress,
    required int energy,
    String? note,
    DateTime? date,
    String? category,
    double? sleepHours,
    int? activityMinutes,
  }) async {
    final body = <String, dynamic>{
      'mood': mood,
      'stress': stress,
      'energy': energy,
      'note': note,
      'category': category,
      'sleep_hours': sleepHours,
      'activity_minutes': activityMinutes,
      if (date != null) 'created_at': date.toUtc().toIso8601String(),
    };

    final response = await _client.post(
      _uri('/mood'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create mood entry');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return MoodEntry.fromJson(data);
  }

  Future<MoodEntry?> fetchLastMoodEntry() async {
    final list = await fetchMoodEntries();
    return list.isNotEmpty ? list.first : null;
  }

  Future<MoodEntry> fetchMoodEntry(int id) async {
    final response = await _client.get(_uri('/mood/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load mood entry');
    }
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return MoodEntry.fromJson(data);
  }

  Future<MoodEntry> updateMoodEntry(
    int id, {
    required int mood,
    required int stress,
    required int energy,
    String? note,
    DateTime? date,
    String? category,
    double? sleepHours,
    int? activityMinutes,
  }) async {
    final body = <String, dynamic>{
      'mood': mood,
      'stress': stress,
      'energy': energy,
      'note': note,
      'category': category,
      'sleep_hours': sleepHours,
      'activity_minutes': activityMinutes,
      if (date != null) 'created_at': date.toUtc().toIso8601String(),
    };

    final response = await _client.put(
      _uri('/mood/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update mood entry');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return MoodEntry.fromJson(data);
  }

  Future<void> deleteMoodEntry(int id) async {
    final response = await _client.delete(_uri('/mood/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete mood entry');
    }
  }

  Future<double?> fetchWellbeingIndex() async {
    final response = await _client.get(_uri('/wellbeing'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load wellbeing index');
    }
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (data['wellbeing_index'] == null) {
      return null;
    }
    return (data['wellbeing_index'] as num).toDouble();
  }

  Future<Map<String, dynamic>> fetchRecommendations({String lang = 'en'}) async {
    final response =
        await _client.get(_uri('/recommendations?lang=$lang'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load recommendations');
    }
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return data;
  }
}

