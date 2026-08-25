import '../repositories/auth_repository.dart';

class UpdateDisplayName {
  UpdateDisplayName({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<void> call({required String uid, required String displayName}) {
    return _repository.updateDisplayName(uid: uid, displayName: displayName);
  }
}
