import '../models/post.dart';
import '../services/api_service.dart';
import 'post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final ApiService _apiService;

  PostRepositoryImpl({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  @override
  Future<List<Post>> getPosts() async {
    return _apiService.getPosts();
  }

  @override
  Future<Post> getPostById(int id) async {
    return _apiService.getPostById(id);
  }
}
