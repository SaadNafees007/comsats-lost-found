import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/claim_entity.dart';
import '../models/claim_model.dart';

class ClaimRemoteDataSource {
  ClaimRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _claimsCollection =>
      _firestore.collection('claims');

  CollectionReference<Map<String, dynamic>> get _itemsCollection =>
      _firestore.collection('items');

  Future<ClaimModel> submitClaim(ClaimModel claim) async {
    final doc = await _claimsCollection
        .add(claim.toFirestore())
        .timeout(const Duration(seconds: 15));

    final snapshot = await doc.get().timeout(const Duration(seconds: 15));
    return ClaimModel.fromFirestore(snapshot);
  }

  Stream<List<ClaimModel>> getClaimsForItem(String itemId) {
    return _claimsCollection
        .where('itemId', isEqualTo: itemId)
        .snapshots()
        .map((snapshot) {
      final claims = snapshot.docs.map(ClaimModel.fromFirestore).toList();
      claims.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return claims;
    });
  }

  Stream<List<ClaimModel>> getMyClaims(String claimantId) {
    return _claimsCollection
        .where('claimantId', isEqualTo: claimantId)
        .snapshots()
        .map((snapshot) {
      final claims = snapshot.docs.map(ClaimModel.fromFirestore).toList();
      claims.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return claims;
    });
  }

  /// Updates the claim status, and also updates the parent item status atomically.
  Future<void> updateClaimStatus({
    required String claimId,
    required String itemId,
    required ClaimStatus newStatus,
  }) async {
    final batch = _firestore.batch();

    // 1. Update the claim document
    batch.update(_claimsCollection.doc(claimId), {
      'status': newStatus.name,
      'reviewedAt': FieldValue.serverTimestamp(),
    });

    // 2. Derive the corresponding item status from the claim decision
    final String itemStatus;
    if (newStatus == ClaimStatus.accepted) {
      itemStatus = 'claimed';
    } else {
      // rejected → revert item back to active so others can still claim
      itemStatus = 'active';
    }

    batch.update(_itemsCollection.doc(itemId), {
      'status': itemStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit().timeout(const Duration(seconds: 15));
  }
}
