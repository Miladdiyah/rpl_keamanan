import '../models/user.dart';
import '../services/api_service.dart';
import 'user_repository.dart';

/// Implementasi konkret dari UserRepository.
class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  UserRepositoryImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  @override
  Future<List<User>> getUsers() async {
    return _apiService.getUsers();
  }

  @override
  Future<User> getUserById(int id) async {
    return _apiService.getUserById(id);
  }

  /// Menutup resource yang digunakan.
  void dispose() {
    _apiService.dispose();
  }
}
