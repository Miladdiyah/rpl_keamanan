import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../models/user.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();

  List<User> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('Memanggil ApiService.getUsers()');

      final users = await _apiService.getUsers();

      if (!mounted) return;

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pengguna')),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                children: [
                  const SizedBox(height: 150),
                  Center(child: Text(_error!)),
                  Center(
                    child: TextButton(
                      onPressed: _loadUsers,
                      child: const Text('Coba Lagi'),
                    ),
                  ),
                ],
              )
            : _users.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 150),
                  Center(child: Text('Tidak ada data pengguna')),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];

                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(user.toString()),
                  );
                },
              ),
      ),
    );
  }
}
