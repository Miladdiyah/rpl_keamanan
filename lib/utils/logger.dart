import 'package:flutter/foundation.dart';

/// Level log aplikasi.
enum LogLevel { debug, info, warning, error }

/// Logger terstruktur untuk kebutuhan debugging.
///
/// Log hanya ditampilkan pada mode debug.
/// Data sensitif seperti token, password, API key,
/// dan email akan disamarkan.
class Logger {
  Logger._();

  static final RegExp _keyValuePattern = RegExp(
    r'\b(token|password|passwd|pin|api[_-]?key|secret|authorization)\b\s*[:=]\s*\S+',
    caseSensitive: false,
  );

  static final RegExp _bearerPattern = RegExp(
    r'Bearer\s+\S+',
    caseSensitive: false,
  );

  static final RegExp _emailPattern = RegExp(r'[\w.+\-]+@[\w\-]+(\.[\w\-]+)+');

  /// Menyamarkan informasi sensitif dalam pesan log.
  static String maskSensitive(String message) {
    return message
        .replaceAll(_bearerPattern, 'Bearer ***')
        .replaceAllMapped(_keyValuePattern, (match) => '${match.group(1)}: ***')
        .replaceAll(_emailPattern, '***@***');
  }

  /// Log untuk informasi debugging.
  static void debug(String message, {String tag = 'APP'}) {
    _log(LogLevel.debug, message, tag);
  }

  /// Log informasi normal aplikasi.
  static void info(String message, {String tag = 'APP'}) {
    _log(LogLevel.info, message, tag);
  }

  /// Log peringatan.
  static void warning(String message, {String tag = 'APP'}) {
    _log(LogLevel.warning, message, tag);
  }

  /// Log kesalahan tanpa mencetak detail sensitif.
  static void error(String message, {String tag = 'APP'}) {
    _log(LogLevel.error, message, tag);
  }

  static void _log(LogLevel level, String message, String tag) {
    if (!kDebugMode) return;

    final safeMessage = maskSensitive(message);

    debugPrint(
      '${DateTime.now().toIso8601String()} '
      '[${level.name.toUpperCase()}][$tag] '
      '$safeMessage',
    );
  }
}
