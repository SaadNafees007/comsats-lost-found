/// Base application exception.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

// ── Authentication ────────────────────────────────────────────────────────────

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException()
    : super(
        'No account found with that email address.',
        code: 'user-not-found',
      );
}

class WrongPasswordException extends AuthException {
  const WrongPasswordException()
    : super('Incorrect password. Please try again.', code: 'wrong-password');
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
    : super(
        'This email is already registered. Try logging in.',
        code: 'email-already-in-use',
      );
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException()
    : super(
        'Password is too weak. Use at least 8 characters.',
        code: 'weak-password',
      );
}

class InvalidEmailException extends AuthException {
  const InvalidEmailException()
    : super('The email address format is invalid.', code: 'invalid-email');
}

class TooManyRequestsException extends AuthException {
  const TooManyRequestsException()
    : super(
        'Too many attempts. Please wait a moment and try again.',
        code: 'too-many-requests',
      );
}

// ── Firestore / Data ─────────────────────────────────────────────────────────

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

class NotFoundException extends DatabaseException {
  const NotFoundException(String entity)
    : super('$entity not found.', code: 'not-found');
}

class PermissionDeniedException extends DatabaseException {
  const PermissionDeniedException()
    : super(
        'You do not have permission to perform this action.',
        code: 'permission-denied',
      );
}

// ── Storage ───────────────────────────────────────────────────────────────────

class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

class UploadFailedException extends StorageException {
  const UploadFailedException()
    : super(
        'Image upload failed. Please check your connection and try again.',
        code: 'upload-failed',
      );
}

// ── Network ───────────────────────────────────────────────────────────────────

class NetworkException extends AppException {
  const NetworkException()
    : super(
        'No internet connection. Please check your network.',
        code: 'network-error',
      );
}

class TimeoutException extends AppException {
  const TimeoutException()
    : super('The request timed out. Please try again.', code: 'timeout');
}
