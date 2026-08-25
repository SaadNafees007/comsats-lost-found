import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final credential = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Login failed. No user was returned.',
      );
    }

    final profile = await _remoteDataSource.getUserProfile(uid: user.uid);

    return profile ?? _mapUser(user);
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
    required String studentId,
    required String department,
  }) {
    return _remoteDataSource.register(
      email: email,
      password: password,
      displayName: displayName,
      studentId: studentId,
      department: department,
    );
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    final credential = await _remoteDataSource.loginWithGoogle();

    final user = credential?.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Google sign-in cancelled or failed.',
      );
    }

    final profile = await _remoteDataSource.getUserProfile(uid: user.uid);

    // If this is a new Google user, create a Firestore profile for them.
    if (profile == null) {
      await _remoteDataSource.createGoogleUserProfile(user: user);
      return _mapUser(user);
    }

    return profile;
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.logout();
  }

  @override
  Future<void> resetPassword({required String email}) {
    return _remoteDataSource.resetPassword(email: email);
  }

  @override
  Future<void> updateDisplayName({
    required String uid,
    required String displayName,
  }) {
    return _remoteDataSource.updateDisplayName(
      uid: uid,
      displayName: displayName,
    );
  }

  UserEntity _mapUser(User user) {
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
