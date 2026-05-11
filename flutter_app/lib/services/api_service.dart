import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../models/forecast_payload.dart';
import '../models/mood_entry.dart';
import 'api_exception.dart';

/// HTTP client for the wellbeing API.
///
/// [userId] is sent on requests for API compatibility; the backend does not
/// enforce authentication in this demo (auth intentionally omitted).
class ApiService {
  ApiService({
    http.Client? client,
    String? baseUrl,
    this.userId = 1,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;
  final int userId;

  static const _timeout = Duration(seconds: 25);

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<http.Response> _send(Future<http.Response> Function() run) async {
    try {
      return await run().timeout(_timeout);
    } on SocketException catch (e) {
      throw ApiException.network(
        'No internet connection (${e.message}).',
      );
    } on TimeoutException {
      throw ApiException.network('The server took too long to respond.');
    } on http.ClientException catch (e) {
      throw ApiException.network(e.message);
    }
  }

  void _ensureStatus(http.Response r, Set<int> ok) {
    if (ok.contains(r.statusCode)) return;
    final detail = ApiException.parseDetailFromBody(r.body);
    const fallback = 'Request failed';
    if (r.statusCode >= 500) {
      throw ApiException.server(
        r.statusCode,
        '$fallback (${r.statusCode})',
        detail,
      );
    }
    if (r.statusCode >= 400) {
      throw ApiException.client(
        r.statusCode,
        '$fallback (${r.statusCode})',
        detail,
      );
    }
    throw ApiException.unknown('$fallback (${r.statusCode})');
  }

  Future<List<MoodEntry>> fetchMoodEntries() async {
    final response = await _send(
      () => _client.get(_uri('/mood?user_id=$userId')),
    );
    _ensureStatus(response, {200});
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
    int? forUserId,
  }) async {
    final body = <String, dynamic>{
      'user_id': forUserId ?? userId,
      'mood': mood,
      'stress': stress,
      'energy': energy,
      'note': note,
      'category': category,
      'sleep_hours': sleepHours,
      'activity_minutes': activityMinutes,
      if (date != null) 'created_at': date.toUtc().toIso8601String(),
    };

    final response = await _send(
      () => _client.post(
            _uri('/mood'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          ),
    );
    _ensureStatus(response, {201});
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return MoodEntry.fromJson(data);
  }

  Future<MoodEntry?> fetchLastMoodEntry() async {
    final list = await fetchMoodEntries();
    return list.isNotEmpty ? list.first : null;
  }

  Future<MoodEntry> fetchMoodEntry(int id) async {
    final response = await _send(() => _client.get(_uri('/mood/$id')));
    _ensureStatus(response, {200});
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
      'user_id': userId,
      'mood': mood,
      'stress': stress,
      'energy': energy,
      'note': note,
      'category': category,
      'sleep_hours': sleepHours,
      'activity_minutes': activityMinutes,
      if (date != null) 'created_at': date.toUtc().toIso8601String(),
    };

    final response = await _send(
      () => _client.put(
            _uri('/mood/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          ),
    );
    _ensureStatus(response, {200});
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return MoodEntry.fromJson(data);
  }

  Future<void> deleteMoodEntry(int id) async {
    final response = await _send(() => _client.delete(_uri('/mood/$id')));
    _ensureStatus(response, {204});
  }

  Future<double?> fetchWellbeingIndex() async {
    final response = await _send(
      () => _client.get(_uri('/wellbeing?user_id=$userId')),
    );
    _ensureStatus(response, {200});
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (data['wellbeing_index'] == null) {
      return null;
    }
    return (data['wellbeing_index'] as num).toDouble();
  }

  Future<Map<String, dynamic>> fetchRecommendations({String lang = 'en'}) async {
    final response = await _send(
      () => _client.get(
            _uri('/recommendations?lang=$lang&user_id=$userId'),
          ),
    );
    _ensureStatus(response, {200});
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<ForecastPayload> fetchForecast({String lang = 'en'}) async {
    final response = await _send(
      () => _client.get(
            _uri('/forecast?user_id=$userId&lang=$lang'),
          ),
    );
    _ensureStatus(response, {200});
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return ForecastPayload.fromJson(data);
  }

  Future<void> postAdviceFeedback({
    required String adviceId,
    required String feedback,
    int? forUserId,
  }) async {
    final response = await _send(
      () => _client.post(
            _uri('/feedback'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(<String, dynamic>{
              'user_id': forUserId ?? userId,
              'advice_id': adviceId,
              'feedback': feedback,
            }),
          ),
    );
    _ensureStatus(response, {201});
  }

  /// Quick connectivity check (backend must expose GET /health).
  Future<bool> pingHealth() async {
    try {
      final response =
          await _client.get(_uri('/health')).timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
