import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class Register {
  Register({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
    required String displayName,
    required String studentId,
    required String department,
  }) {
    return _repository.register(
      email: email,
      password: password,
      displayName: displayName,
      studentId: studentId,
      department: department,
    );
  }
}
