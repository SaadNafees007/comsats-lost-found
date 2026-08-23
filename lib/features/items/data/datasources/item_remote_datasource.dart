import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/item_model.dart';

class ItemRemoteDataSource {
  ItemRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _itemsCollection =>
      _firestore.collection('items');

  Future<ItemModel> createItem(ItemModel item) async {
    final document = await _itemsCollection
        .add(item.toFirestore())
        .timeout(const Duration(seconds: 15));

    final snapshot = await document.get().timeout(const Duration(seconds: 15));

    return ItemModel.fromFirestore(snapshot);
  }

  Future<ItemModel?> getItem(String itemId) async {
    final document = await _itemsCollection
        .doc(itemId)
        .get()
        .timeout(const Duration(seconds: 15));

    if (!document.exists) {
      return null;
    }

    return ItemModel.fromFirestore(document);
  }

  Stream<ItemModel?> watchItem(String itemId) {
    return _itemsCollection.doc(itemId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ItemModel.fromFirestore(doc);
    });
  }

  Stream<List<ItemModel>> getItems() {
    return _itemsCollection.snapshots().map((snapshot) {
      final items = snapshot.docs.map(ItemModel.fromFirestore).toList();
      items.sort((a, b) {
        final aTime = a.createdAt ?? a.date;
        final bTime = b.createdAt ?? b.date;
        return bTime.compareTo(aTime);
      });
      return items;
    });
  }

  Stream<List<ItemModel>> getMyItems(String ownerId) {
    return _itemsCollection
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map(ItemModel.fromFirestore).toList();
          items.sort((a, b) {
            final aTime = a.createdAt ?? a.date;
            final bTime = b.createdAt ?? b.date;
            return bTime.compareTo(aTime);
          });
          return items;
        });
  }

  Future<void> updateItem(ItemModel item) {
    return _itemsCollection
        .doc(item.id)
        .update(item.toFirestore())
        .timeout(const Duration(seconds: 15));
  }

  Future<void> deleteItem(String itemId) {
    return _itemsCollection
        .doc(itemId)
        .delete()
        .timeout(const Duration(seconds: 15));
  }
}
