import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Class untuk mengatur konfigurasi aplikasi.
class AppConfig {
  /// URL utama API.
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? '';
  }

  /// API Key aplikasi.
  static String get apiKey {
    return dotenv.env['API_KEY'] ?? '';
  }

  /// Timeout request API dalam detik.
  static int get timeoutSeconds {
    return 30;
  }

  /// Memeriksa apakah konfigurasi sudah tersedia.
  static bool isConfigured() {
    return baseUrl.isNotEmpty && apiKey.isNotEmpty;
  }
}
