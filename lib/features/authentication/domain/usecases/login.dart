import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class Login {
  Login({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  Future<UserEntity> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}
