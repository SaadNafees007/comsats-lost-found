import '../repositories/auth_repository.dart';

class Logout {
  Logout({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.logout();
  }
}
