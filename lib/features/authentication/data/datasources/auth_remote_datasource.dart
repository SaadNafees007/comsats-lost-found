import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({AuthService? authService, FirebaseFirestore? firestore})
    : _authService = authService ?? AuthService(),
      _firestore = firestore ?? FirebaseFirestore.instance;

  final AuthService _authService;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    required String studentId,
    required String department,
  }) async {
    final credential = await _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Registration failed. No user was returned.',
      );
    }

    try {
      await user.updateDisplayName(displayName);

      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? email,
        displayName: displayName,
        photoUrl: user.photoURL,
        studentId: studentId,
        department: department,
        role: 'student',
      );

      await _usersCollection.doc(user.uid).set({
        ...userModel.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userModel;
    } catch (e) {
      // Prevent an orphan Firebase Authentication account
      // if Firestore profile creation fails.
      try {
        await user.delete();
      } catch (_) {
        // Ignore cleanup failure and rethrow the original error.
      }

      rethrow;
    }
  }

  Future<UserCredential?> loginWithGoogle() {
    return _authService.signInWithGoogle();
  }

  Future<UserModel?> getUserProfile({required String uid}) async {
    final document = await _usersCollection.doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return UserModel.fromFirestore(document);
  }

  Future<void> createGoogleUserProfile({required User user}) async {
    final existing = await _usersCollection.doc(user.uid).get();
    if (existing.exists) return; // Don't overwrite existing profiles.

    await _usersCollection.doc(user.uid).set({
      'id': user.uid,
      'email': user.email ?? '',
      'displayName': user.displayName ?? '',
      'photoUrl': user.photoURL ?? '',
      'studentId': '',
      'department': '',
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDisplayName({
    required String uid,
    required String displayName,
  }) async {
    await _usersCollection.doc(uid).update({
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resetPassword({required String email}) {
    return _authService.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() {
    return _authService.signOut();
  }

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;
}
