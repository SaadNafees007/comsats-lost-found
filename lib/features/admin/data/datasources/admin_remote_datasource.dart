import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../claims/data/models/claim_model.dart';
import '../../../items/data/models/item_model.dart';

class AdminRemoteDataSource {
  AdminRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _itemsCollection =>
      _firestore.collection('items');

  CollectionReference<Map<String, dynamic>> get _claimsCollection =>
      _firestore.collection('claims');

  /// Streams all items in the system for admin overview.
  Stream<List<ItemModel>> getAllItems() {
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

  /// Streams all claims in the system for admin overview.
  Stream<List<ClaimModel>> getAllClaims() {
    return _claimsCollection.snapshots().map((snapshot) {
      final claims = snapshot.docs.map(ClaimModel.fromFirestore).toList();
      claims.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return claims;
    });
  }

  /// Admin operation: Force delete an item and its associated claims.
  Future<void> adminDeleteItem(String itemId) async {
    final batch = _firestore.batch();

    // 1. Delete item doc
    batch.delete(_itemsCollection.doc(itemId));

    // 2. Delete associated claims
    final claimsQuery = await _claimsCollection
        .where('itemId', isEqualTo: itemId)
        .get();

    for (final doc in claimsQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit().timeout(const Duration(seconds: 15));
  }

  /// Admin operation: Force update item status (e.g. resolve/close report).
  Future<void> adminUpdateItemStatus(String itemId, String status) async {
    await _itemsCollection
        .doc(itemId)
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()})
        .timeout(const Duration(seconds: 15));
  }
}
