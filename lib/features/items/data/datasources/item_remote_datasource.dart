import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/item_model.dart';

class ItemRemoteDataSource {
  ItemRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _itemsCollection =>
      _firestore.collection('items');

  Future<ItemModel> createItem(ItemModel item) async {
    final document = await _itemsCollection.add(item.toFirestore());

    final snapshot = await document.get();

    return ItemModel.fromFirestore(snapshot);
  }

  Future<ItemModel?> getItem(String itemId) async {
    final document = await _itemsCollection.doc(itemId).get();

    if (!document.exists) {
      return null;
    }

    return ItemModel.fromFirestore(document);
  }

  Stream<List<ItemModel>> getItems() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ItemModel.fromFirestore).toList());
  }

  Stream<List<ItemModel>> getMyItems(String ownerId) {
    return _itemsCollection
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ItemModel.fromFirestore).toList());
  }

  Future<void> updateItem(ItemModel item) {
    return _itemsCollection.doc(item.id).update(item.toFirestore());
  }

  Future<void> deleteItem(String itemId) {
    return _itemsCollection.doc(itemId).delete();
  }
}
