import 'package:flutter/material.dart';

import '../config/dependency_injector.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../widgets/user_card.dart';

/// Halaman untuk menampilkan daftar pengguna.
class UserListScreen extends StatefulWidget {
  final UserRepository? repository;

  const UserListScreen({super.key, this.repository});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late final UserRepository _repository;

  List<User> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _repository =
        widget.repository ?? DependencyScope.of(context).userRepository;

    _loadUsers();
  }

  /// Mengambil data pengguna melalui repository.
  Future<void> _loadUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _repository.getUsers();

      if (!mounted) return;

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Gagal memuat pengguna. Silakan coba kembali.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Terjadi Kesalahan'),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(child: Text('Tidak ada data pengguna'));
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];

          return UserCard(user: user, onTap: () => _showUserDetail(user));
        },
      ),
    );
  }

  /// Menampilkan detail pengguna.
  void _showUserDetail(User user) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Username: ${user.username}'),
              Text('Email: ${user.email}'),
              Text('Telepon: ${user.phone}'),
              Text('Website: ${user.website}'),
              Text('Perusahaan: ${user.companyName}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
