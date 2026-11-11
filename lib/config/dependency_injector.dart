import 'package:flutter/widgets.dart';

import '../repositories/post_repository.dart';
import '../repositories/post_repository_impl.dart';
import '../repositories/user_repository.dart';
import '../repositories/user_repository_impl.dart';
import '../services/api_service.dart';

class DependencyInjector {
  DependencyInjector._internal();

  static final DependencyInjector _instance = DependencyInjector._internal();

  factory DependencyInjector() => _instance;

  static DependencyInjector get instance => _instance;

  late final ApiService apiService = ApiService();

  late final UserRepository userRepository = UserRepositoryImpl(
    apiService: apiService,
  );

  late final PostRepository postRepository = PostRepositoryImpl(
    apiService: apiService,
  );
}

class DependencyScope extends InheritedWidget {
  final DependencyInjector injector;

  const DependencyScope({
    super.key,
    required this.injector,
    required super.child,
  });

  static DependencyInjector of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<DependencyScope>();

    assert(scope != null, 'DependencyScope tidak ditemukan di widget tree');

    return scope!.injector;
  }

  @override
  bool updateShouldNotify(DependencyScope oldWidget) {
    return injector != oldWidget.injector;
  }
}
