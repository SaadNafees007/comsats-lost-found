import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/register.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(authService: ref.watch(authServiceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

final loginProvider = Provider<Login>((ref) {
  return Login(repository: ref.watch(authRepositoryProvider));
});

final registerProvider = Provider<Register>((ref) {
  return Register(repository: ref.watch(authRepositoryProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);

  return authService.authStateChanges;
});

final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final dataSource = ref.watch(authRemoteDataSourceProvider);

  final authUser = authState.valueOrNull;
  if (authUser == null) {
    return null;
  }

  return dataSource.getUserProfile(uid: authUser.uid);
});

final authLoadingProvider = StateProvider<bool>((ref) {
  return false;
});
