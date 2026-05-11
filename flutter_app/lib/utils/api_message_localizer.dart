import '../l10n/app_localizations.dart';
import '../services/api_exception.dart';

/// Maps [ApiException] boilerplate from [ApiService] to the active UI language.
String localizedApiErrorMessage(Object error, AppLocalizations loc) {
  if (error is! ApiException) return '${loc.errorPrefix}$error';
  final e = error;
  if (e.detail != null && e.detail!.trim().isNotEmpty) {
    return e.detail!;
  }
  if (e.kind == ApiErrorKind.network) {
    final m = e.message;
    if (m.contains('No internet') || m.contains('SocketException')) {
      return loc.apiErrorNoInternet;
    }
    if (m.contains('too long')) {
      return loc.apiErrorTimeout;
    }
    return loc.apiErrorNetwork;
  }
  if (e.kind == ApiErrorKind.server) {
    return loc.apiErrorServer;
  }
  if (e.kind == ApiErrorKind.client) {
    return e.message.isNotEmpty ? e.message : loc.apiErrorClient;
  }
  return e.message.isNotEmpty ? e.message : loc.apiErrorUnknown;
}
