import '../entities/item_entity.dart';
import '../repositories/item_repository.dart';

class CreateItem {
  CreateItem({required ItemRepository repository}) : _repository = repository;

  final ItemRepository _repository;

  Future<ItemEntity> call(ItemEntity item) {
    return _repository.createItem(item);
  }
}
