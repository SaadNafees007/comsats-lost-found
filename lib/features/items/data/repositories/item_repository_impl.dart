import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/item_remote_datasource.dart';
import '../models/item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  ItemRepositoryImpl({required ItemRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ItemRemoteDataSource _remoteDataSource;

  @override
  Future<ItemEntity> createItem(ItemEntity item) {
    return _remoteDataSource.createItem(
      ItemModel(
        id: item.id,
        ownerId: item.ownerId,
        type: item.type,
        title: item.title,
        description: item.description,
        category: item.category,
        location: item.location,
        date: item.date,
        imageUrls: item.imageUrls,
        status: item.status,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      ),
    );
  }

  @override
  Future<ItemEntity?> getItem(String itemId) {
    return _remoteDataSource.getItem(itemId);
  }

  @override
  Stream<List<ItemEntity>> getItems() {
    return _remoteDataSource.getItems();
  }

  @override
  Stream<List<ItemEntity>> getMyItems(String ownerId) {
    return _remoteDataSource.getMyItems(ownerId);
  }

  @override
  Future<void> updateItem(ItemEntity item) {
    return _remoteDataSource.updateItem(
      ItemModel(
        id: item.id,
        ownerId: item.ownerId,
        type: item.type,
        title: item.title,
        description: item.description,
        category: item.category,
        location: item.location,
        date: item.date,
        imageUrls: item.imageUrls,
        status: item.status,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      ),
    );
  }

  @override
  Future<void> deleteItem(String itemId) {
    return _remoteDataSource.deleteItem(itemId);
  }
}
