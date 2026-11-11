import 'package:flutter/material.dart';

import '../services/secure_storage_service.dart';
import 'post_list_screen.dart';
import 'user_list_screen.dart';
import 'validator_demo_screen.dart'; // LATIHAN 3
import 'user_list_screen.dart';

/// Halaman utama aplikasi.
///
/// Berisi demo secure storage dan tombol navigasi ke halaman data API.
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

  Future<void> _checkToken() async {
    final hasToken = await _storageService.hasToken();
    final token = await _storageService.getToken();
    if (!mounted) return;
    setState(() {
      _hasToken = hasToken;
      _savedToken = token;
    });
  }

  /// Menampilkan sebagian token saja (aman untuk token pendek).
  String _maskToken(String? token) {
    if (token == null || token.isEmpty) return '-';
    if (token.length <= 6) return '••••';
    return '${token.substring(0, 6)}••••';
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _saveToken() async {
    if (_tokenController.text.trim().isEmpty) {
      _showMessage('Token tidak boleh kosong', Colors.red);
      return;
    }

    await _storageService.saveToken(_tokenController.text.trim());
    _tokenController.clear();
    await _checkToken();

    if (mounted) {
      _showMessage('Token berhasil disimpan di secure storage', Colors.green);
    }
  }

  Future<void> _deleteToken() async {
    await _storageService.deleteToken();
    await _checkToken();

    if (mounted) {
      _showMessage('Token berhasil dihapus', Colors.orange);
    }
  }

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserListScreen()),
          );
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Secure Storage
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                      'Simpan token di secure storage (terenkripsi AES).',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tokenController,
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
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
                        border: Border.all(
                          color: _hasToken ? Colors.green : Colors.red,
                        ),
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
                                  ? 'Token tersimpan: ${_maskToken(_savedToken)}'
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

            // Section 2: Data dari API (lewat Repository)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(Icons.cloud, Colors.blue, 'Data dari API'),
                    const SizedBox(height: 8),
                    const Text(
                      'Data diambil melalui Repository pattern.',
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

            // Section 3 (LATIHAN 3): Demo validasi input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                      'Coba validasi telepon, URL, password, dan sanitasi input.',
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

            // Section 4: Catatan Keamanan
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.amber[800]),
                        const SizedBox(width: 8),
                        const Text(
                          'Catatan Keamanan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Base URL dan API key disimpan di file .env.\n'
                      '2. File .env masuk .gitignore.\n'
                      '3. Jangan pernah mencetak token ke log.\n'
                      '4. Gunakan HTTPS untuk komunikasi API.',
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
