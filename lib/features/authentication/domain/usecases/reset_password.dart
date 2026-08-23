import '../repositories/auth_repository.dart';

class ResetPassword {
  ResetPassword({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<void> call({required String email}) {
    return _repository.resetPassword(email: email);
  }
}
