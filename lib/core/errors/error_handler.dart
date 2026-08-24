import 'package:firebase_auth/firebase_auth.dart';

import 'exceptions.dart';

/// Maps platform-level exceptions (Firebase, Dart) to typed [AppException]s.
class ErrorHandler {
  ErrorHandler._();

  /// Converts a [FirebaseAuthException] to a typed [AuthException].
  static AppException fromFirebaseAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-credential':
        return const UserNotFoundException();
      case 'wrong-password':
        return const WrongPasswordException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'invalid-email':
        return const InvalidEmailException();
      case 'too-many-requests':
        return const TooManyRequestsException();
      case 'network-request-failed':
        return const NetworkException();
      default:
        return AuthException(
          e.message ?? 'Authentication failed. Please try again.',
          code: e.code,
        );
    }
  }

  /// Converts a [FirebaseException] (Firestore / Storage) to a typed exception.
  static AppException fromFirebase(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const PermissionDeniedException();
      case 'not-found':
        return const NotFoundException('Resource');
      case 'unavailable':
      case 'deadline-exceeded':
        return const TimeoutException();
      case 'network-request-failed':
        return const NetworkException();
      default:
        return DatabaseException(
          e.message ?? 'A database error occurred.',
          code: e.code,
        );
    }
  }

  /// Converts any thrown object to a user-readable message string.
  static String toMessage(Object error) {
    if (error is AppException) return error.message;
    if (error is FirebaseAuthException) {
      return fromFirebaseAuth(error).message;
    }
    if (error is FirebaseException) {
      return fromFirebase(error).message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
