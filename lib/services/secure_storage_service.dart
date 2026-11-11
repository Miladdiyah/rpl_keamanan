import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/logger.dart'; // LATIHAN 4

/// Service untuk mengelola penyimpanan data sensitif yang terenkripsi.
class SecureStorageService {
  static const String _tag = 'SecureStorage';

  // Konfigurasi secure storage
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Key penyimpanan
  static const String _tokenKey = 'auth_token';
  static const String _pinKey = 'user_pin';

  // Menyimpan token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    Logger.info('Token berhasil disimpan', tag: _tag);
  }

  // Membaca token
  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);

    Logger.debug(
      token != null ? 'Token ditemukan' : 'Token tidak ditemukan',
      tag: _tag,
    );

    return token;
  }

  // Menghapus token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    Logger.info('Token berhasil dihapus', tag: _tag);
  }

  // Menyimpan PIN
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    Logger.info('PIN berhasil disimpan', tag: _tag);
  }

  // Membaca PIN
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  // Menghapus semua data
  Future<void> deleteAll() async {
    await _storage.deleteAll();
    Logger.info('Semua data berhasil dihapus', tag: _tag);
  }

  // Mengecek keberadaan token
  Future<bool> hasToken() async {
    return await _storage.containsKey(key: _tokenKey);
  }
}
