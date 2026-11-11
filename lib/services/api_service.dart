import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../utils/logger.dart'; // LATIHAN 4

/// Exception khusus untuk error komunikasi API.
///
/// Dipakai agar tidak bentrok dengan HttpException milik dart:io
/// dan agar pesan error di UI bersih (tanpa awalan "Exception:").
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Service untuk komunikasi HTTP dengan REST API.
///
/// Class ini menangani semua request HTTP ke API, termasuk
/// penanganan error, timeout, dan logging yang aman.
class ApiService {
  static const String _tag = 'ApiService';

  final http.Client _client;
  final String _baseUrl;

  ApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.baseUrl;

  /// Mengambil daftar pengguna dari API.
  ///
  /// Mengembalikan [List<User>] jika berhasil.
  /// Melempar [ApiException] dengan pesan yang ramah pengguna jika gagal.
  Future<List<User>> getUsers() async {
    final dynamic data = await _getJson('/users');
    if (data is List) {
      return data
          .map<User>((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiException('Format data tidak valid.');
  }

  /// Mengambil pengguna berdasarkan [id].
  Future<User> getUserById(int id) async {
    final dynamic data = await _getJson('/users/$id');
    if (data is Map<String, dynamic>) {
      return User.fromJson(data);
    }
    throw ApiException('Format data tidak valid.');
  }

  /// Mengambil daftar post dari API.
  ///
  /// Mengembalikan [List<Post>] jika berhasil.
  /// Melempar [ApiException] dengan pesan yang ramah pengguna jika gagal.
  Future<List<Post>> getPosts() async {
    final dynamic data = await _getJson('/posts');
    if (data is List) {
      return data
          .map<Post>((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiException('Format data tidak valid.');
  }

  
  /// Mengambil post berdasarkan ID.
  Future<Post> getPostById(int id) async {
    final dynamic data = await _getJson('/posts/$id');

    if (data is Map<String, dynamic>) {
      return Post.fromJson(data);
    }

    throw ApiException('Format data tidak valid.');
  }

  /// Menjalankan GET request ke [endpoint] lalu mengembalikan hasil JSON.
  ///
  /// Semua penanganan error (timeout, koneksi, status code, format)
  /// dipusatkan di sini.
  Future<dynamic> _getJson(String endpoint) async {
    try {
      // Logging aman: hanya method dan endpoint
      Logger.info('Request GET $endpoint', tag: _tag);

      final response = await _client
          .get(Uri.parse('$_baseUrl$endpoint'), headers: _buildHeaders())
          .timeout(Duration(seconds: AppConfig.timeoutSeconds));

      // Logging aman: hanya status code
      Logger.debug('Response status: ${response.statusCode}', tag: _tag);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      Logger.warning('HTTP error, status: ${response.statusCode}', tag: _tag);
      throw ApiException('Gagal memuat data. Status: ${response.statusCode}');
    } on ApiException {
      rethrow;
    } on TimeoutException {
      Logger.warning('Request timeout pada $endpoint', tag: _tag);
      throw ApiException('Request timeout. Periksa koneksi internet Anda.');
    } on SocketException {
      Logger.warning('Tidak ada koneksi internet', tag: _tag);
      throw ApiException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on FormatException {
      Logger.error('Response bukan JSON yang valid', tag: _tag);
      throw ApiException('Format data tidak valid.');
    } catch (e) {
      Logger.error('Kesalahan tak terduga', tag: _tag, error: e);
      throw ApiException('Terjadi kesalahan: $e');
    }
  }

  /// Membangun header untuk request HTTP.
  ///
  /// Menyertakan API key dari konfigurasi (tidak di-hardcode).
  /// Header ini tidak pernah dicetak ke log.
  Map<String, String> _buildHeaders() {
    return {'Content-Type': 'application/json', 'X-API-Key': AppConfig.apiKey};
  }

  /// Menutup client.
  void dispose() {
    _client.close();
  }
}
