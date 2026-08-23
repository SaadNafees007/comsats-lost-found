import '../entities/item_entity.dart';

abstract class ItemRepository {
  Future<ItemEntity> createItem(ItemEntity item);

  Future<ItemEntity?> getItem(String itemId);

  Stream<ItemEntity?> watchItem(String itemId);

  Stream<List<ItemEntity>> getItems();

  Stream<List<ItemEntity>> getMyItems(String ownerId);

  Future<void> updateItem(ItemEntity item);

  Future<void> deleteItem(String itemId);
}
