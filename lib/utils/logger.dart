import 'package:flutter/foundation.dart';

/// Level log yang tersedia, dari paling ringan ke paling serius.
enum LogLevel { debug, info, warning, error }

/// Logger terstruktur dan aman.
///
/// Aturan:
/// - Log hanya tampil di mode debug ([kDebugMode]); di release tidak ada output.
/// - Pesan otomatis disamarkan oleh [maskSensitive] agar token, password,
///   PIN, API key, dan email tidak ikut tercetak.
/// - Tetap jangan memasukkan data sensitif ke pesan log.
///
/// Contoh:
/// ```dart
/// Logger.info('Request GET /users', tag: 'API');
/// Logger.error('Gagal memuat data', tag: 'API', error: e);
/// ```
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

  /// Menyamarkan data sensitif pada [message].
  ///
  /// Contoh: `token=abc123` menjadi `token: ***`,
  /// `user@mail.com` menjadi `***@***`.
  static String maskSensitive(String message) {
    return message
        .replaceAll(_bearerPattern, 'Bearer ***')
        .replaceAllMapped(_keyValuePattern, (m) => '${m.group(1)}: ***')
        .replaceAll(_emailPattern, '***@***');
  }

  /// Log level debug: detail teknis untuk pengembangan.
  static void debug(String message, {String tag = 'APP'}) {
    _log(LogLevel.debug, message, tag, null);
  }

  /// Log level info: alur normal aplikasi.
  static void info(String message, {String tag = 'APP'}) {
    _log(LogLevel.info, message, tag, null);
  }

  /// Log level warning: sesuatu yang tidak ideal tapi tidak fatal.
  static void warning(String message, {String tag = 'APP'}) {
    _log(LogLevel.warning, message, tag, null);
  }

  /// Log level error: kegagalan. [error] opsional ikut dicatat (disamarkan).
  static void error(String message, {String tag = 'APP', Object? error}) {
    _log(LogLevel.error, message, tag, error);
  }

  static void _log(LogLevel level, String message, String tag, Object? error) {
    // Hanya tampil di mode debug
    if (!kDebugMode) return;

    final buffer = StringBuffer()
      ..write(DateTime.now().toIso8601String())
      ..write(' [${level.name.toUpperCase()}]')
      ..write('[$tag] ')
      ..write(maskSensitive(message));

    if (error != null) {
      buffer.write(' | ${maskSensitive(error.toString())}');
    }

    debugPrint(buffer.toString());
  }
}
