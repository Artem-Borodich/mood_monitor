import 'dart:convert';

/// Classifies API failures for clearer UI (network vs server vs client).
enum ApiErrorKind {
  network,
  server,
  client,
  unknown,
}

/// Thrown by [ApiService] when a request fails or returns an unexpected status.
class ApiException implements Exception {
  ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.detail,
  });

  final ApiErrorKind kind;
  final String message;
  final int? statusCode;
  final String? detail;

  /// User-facing line: server [detail] if present, else [message].
  String get userMessage => detail?.isNotEmpty == true ? detail! : message;

  @override
  String toString() => userMessage;

  static ApiException network(String message) =>
      ApiException(kind: ApiErrorKind.network, message: message);

  static ApiException server(int? code, String message, [String? detail]) =>
      ApiException(
        kind: ApiErrorKind.server,
        message: message,
        statusCode: code,
        detail: detail,
      );

  static ApiException client(int code, String message, [String? detail]) =>
      ApiException(
        kind: ApiErrorKind.client,
        message: message,
        statusCode: code,
        detail: detail,
      );

  static ApiException unknown(String message) =>
      ApiException(kind: ApiErrorKind.unknown, message: message);

  /// Parse FastAPI-style `{"detail": ...}` (string or validation error list).
  static String? parseDetailFromBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      final raw = decoded['detail'];
      if (raw is String) return raw;
      if (raw is List) {
        final parts = <String>[];
        for (final item in raw) {
          if (item is Map && item['msg'] != null) {
            parts.add(item['msg'].toString());
          }
        }
        if (parts.isNotEmpty) return parts.join(' ');
      }
    } catch (_) {}
    return null;
  }
}
