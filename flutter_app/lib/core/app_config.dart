import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Base URL for the FastAPI backend.
///
/// Override at build time:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000`
///
/// Android emulator uses `10.0.2.2` to reach the host machine's localhost.
class AppConfig {
  AppConfig._();

  static const String _envUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_envUrl.isNotEmpty) return _normalize(_envUrl);
    if (kIsWeb) return _normalize('http://localhost:8000');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _normalize('http://10.0.2.2:8000');
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return _normalize('http://localhost:8000');
      default:
        return _normalize('http://localhost:8000');
    }
  }

  static String _normalize(String url) {
    if (url.endsWith('/')) return url.substring(0, url.length - 1);
    return url;
  }
}
