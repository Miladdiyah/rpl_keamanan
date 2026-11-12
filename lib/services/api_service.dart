import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../utils/logger.dart';

/// Exception khusus untuk komunikasi API.
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

/// Service untuk komunikasi HTTP.
class ApiService {
  static const String _tag = 'ApiService';

  final http.Client _client;
  final String _baseUrl;

  ApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.baseUrl;

  /// Mengambil seluruh pengguna.
  Future<List<User>> getUsers() async {
    final data = await _getJson('/users');

    if (data is List) {
      return data
          .map<User>((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ApiException('Format data pengguna tidak valid.');
  }

  /// Mengambil pengguna berdasarkan ID.
  Future<User> getUserById(int id) async {
    if (id <= 0) {
      throw ApiException('ID pengguna tidak valid.');
    }

    final data = await _getJson('/users/$id');

    if (data is Map<String, dynamic>) {
      return User.fromJson(data);
    }

    throw ApiException('Format data pengguna tidak valid.');
  }

  /// Mengambil seluruh Posts.
  Future<List<Post>> getPosts() async {
    final data = await _getJson('/posts');

    if (data is List) {
      return data
          .map<Post>((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ApiException('Format data Posts tidak valid.');
  }

  /// Mengambil Post berdasarkan ID.
  Future<Post> getPostById(int id) async {
    if (id <= 0) {
      throw ApiException('ID Post tidak valid.');
    }

    final data = await _getJson('/posts/$id');

    if (data is Map<String, dynamic>) {
      return Post.fromJson(data);
    }

    throw ApiException('Format data Post tidak valid.');
  }

  /// Menjalankan request GET dan memproses JSON.
  Future<dynamic> _getJson(String endpoint) async {
    try {
      Logger.info('Request GET $endpoint', tag: _tag);

      final response = await _client
          .get(Uri.parse('$_baseUrl$endpoint'), headers: _buildHeaders())
          .timeout(Duration(seconds: AppConfig.timeoutSeconds));

      Logger.debug('Response status: ${response.statusCode}', tag: _tag);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      Logger.warning('HTTP error: ${response.statusCode}', tag: _tag);

      throw ApiException('Gagal memuat data. Status: ${response.statusCode}');
    } on ApiException {
      rethrow;
    } on TimeoutException {
      Logger.warning('Request timeout', tag: _tag);
      throw ApiException('Request timeout. Periksa koneksi internet Anda.');
    } on SocketException {
      Logger.warning('Koneksi internet bermasalah', tag: _tag);
      throw ApiException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on FormatException {
      Logger.error('Format JSON tidak valid', tag: _tag);
      throw ApiException('Format data tidak valid.');
    } catch (_) {
      Logger.error('Terjadi kesalahan internal API', tag: _tag);
      throw ApiException('Terjadi kesalahan saat menghubungi server.');
    }
  }

  /// Membuat header request.
  ///
  /// API key tidak pernah dicetak ke log.
  Map<String, String> _buildHeaders() {
    return {'Content-Type': 'application/json', 'X-API-Key': AppConfig.apiKey};
  }

  /// Menutup HTTP client.
  void dispose() {
    _client.close();
  }
}
