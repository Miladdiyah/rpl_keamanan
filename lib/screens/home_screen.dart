import 'package:flutter/material.dart';

import '../services/secure_storage_service.dart';
import 'post_list_screen.dart';
import 'user_list_screen.dart';
import 'validator_demo_screen.dart';

/// Halaman utama aplikasi RPL dan Keamanan.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SecureStorageService _storageService = SecureStorageService();
  final TextEditingController _tokenController = TextEditingController();

  String? _savedToken;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  /// Memeriksa token yang tersimpan.
  Future<void> _checkToken() async {
    try {
      final hasToken = await _storageService.hasToken();
      final token = await _storageService.getToken();

      if (!mounted) return;

      setState(() {
        _hasToken = hasToken;
        _savedToken = token;
      });
    } catch (_) {
      if (!mounted) return;

      _showMessage('Gagal memeriksa token.', Colors.red);
    }
  }

  /// Menampilkan token dalam bentuk tersamarkan.
  String _maskToken(String? token) {
    if (token == null || token.isEmpty) return '-';
    if (token.length <= 6) return '••••';

    return '${token.substring(0, 6)}••••';
  }

  /// Menampilkan pesan kepada pengguna.
  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  /// Menyimpan token ke secure storage.
  Future<void> _saveToken() async {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      _showMessage('Token tidak boleh kosong.', Colors.red);
      return;
    }

    try {
      await _storageService.saveToken(token);

      _tokenController.clear();
      await _checkToken();

      if (!mounted) return;

      _showMessage('Token berhasil disimpan.', Colors.green);
    } catch (_) {
      if (!mounted) return;

      _showMessage('Gagal menyimpan token.', Colors.red);
    }
  }

  /// Menghapus token dari secure storage.
  Future<void> _deleteToken() async {
    try {
      await _storageService.deleteToken();
      await _checkToken();

      if (!mounted) return;

      _showMessage('Token berhasil dihapus.', Colors.orange);
    } catch (_) {
      if (!mounted) return;

      _showMessage('Gagal menghapus token.', Colors.red);
    }
  }

  /// Membuat judul bagian.
  Widget _sectionTitle(IconData icon, Color color, String title) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Tombol navigasi menuju halaman tertentu.
  Widget _navButton({
    required IconData icon,
    required String label,
    required Color color,
    required Widget screen,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RPL & Keamanan'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bagian Secure Storage
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      Icons.lock,
                      Colors.deepPurple,
                      'Secure Storage',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Simpan token menggunakan secure storage.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tokenController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Token',
                        hintText: 'Masukkan token dummy',
                        prefixIcon: Icon(Icons.vpn_key),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveToken,
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _hasToken ? _deleteToken : null,
                            icon: const Icon(Icons.delete),
                            label: const Text('Hapus'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _hasToken ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _hasToken ? Icons.check_circle : Icons.cancel,
                            color: _hasToken ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _hasToken
                                  ? 'Token tersimpan: '
                                        '${_maskToken(_savedToken)}'
                                  : 'Belum ada token tersimpan',
                              style: TextStyle(
                                color: _hasToken
                                    ? Colors.green[800]
                                    : Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bagian data API
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(Icons.cloud, Colors.blue, 'Data dari API'),
                    const SizedBox(height: 8),
                    const Text(
                      'Data diambil melalui Repository Pattern.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _navButton(
                      icon: Icons.list,
                      label: 'Lihat Daftar Pengguna',
                      color: Colors.blue,
                      screen: const UserListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _navButton(
                      icon: Icons.article,
                      label: 'Lihat Daftar Posts',
                      color: Colors.teal,
                      screen: const PostListScreen(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bagian validasi input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      Icons.verified_user,
                      Colors.orange,
                      'Validasi Input',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Demo validasi telepon, URL, password, '
                      'dan sanitasi input.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _navButton(
                      icon: Icons.fact_check,
                      label: 'Demo Validasi Input',
                      color: Colors.orange,
                      screen: const ValidatorDemoScreen(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Catatan keamanan
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      Icons.security,
                      Colors.amber,
                      'Catatan Keamanan',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Konfigurasi disimpan di .env.\n'
                      '2. File .env dimasukkan ke .gitignore.\n'
                      '3. Jangan mencetak token ke log.\n'
                      '4. Gunakan HTTPS untuk API.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
