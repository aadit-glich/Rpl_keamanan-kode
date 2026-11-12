import 'package:flutter/material.dart';
import '../repositories/post_repository.dart';
import '../repositories/post_repository_impl.dart';
import '../repositories/user_repository.dart';
import '../repositories/user_repository_impl.dart';
import '../services/api_service.dart';

class DependencyInjector extends InheritedWidget {
  final ApiService apiService;
  final UserRepository userRepository;
  final PostRepository postRepository;

  DependencyInjector({
    super.key,
    required super.child,
    ApiService? apiService,
    UserRepository? userRepository,
    PostRepository? postRepository,
  })  : apiService = apiService ?? ApiService.instance,
        userRepository = userRepository ??
            UserRepositoryImpl(apiService: apiService ?? ApiService.instance),
        postRepository = postRepository ??
            PostRepositoryImpl(apiService: apiService ?? ApiService.instance);

  static DependencyInjector of(BuildContext context) {
    final injector =
        context.dependOnInheritedWidgetOfExactType<DependencyInjector>();
    assert(injector != null, 'No DependencyInjector found in context');
    return injector!;
  }

  static DependencyInjector? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DependencyInjector>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
