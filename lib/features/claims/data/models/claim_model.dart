import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/claim_entity.dart';

class ClaimModel extends ClaimEntity {
  const ClaimModel({
    required super.id,
    required super.itemId,
    required super.claimantId,
    required super.itemOwnerId,
    required super.proofDescription,
    required super.proofImageUrls,
    required super.status,
    required super.createdAt,
    super.reviewedAt,
  });

  factory ClaimModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    final createdAtTs = data['createdAt'] as Timestamp?;
    final reviewedAtTs = data['reviewedAt'] as Timestamp?;

    return ClaimModel(
      id: document.id,
      itemId: data['itemId'] as String? ?? '',
      claimantId: data['claimantId'] as String? ?? '',
      itemOwnerId: data['itemOwnerId'] as String? ?? '',
      proofDescription: data['proofDescription'] as String? ?? '',
      proofImageUrls: List<String>.from(
        data['proofImageUrls'] as List<dynamic>? ?? <dynamic>[],
      ),
      status: _statusFromString(data['status'] as String?),
      createdAt: createdAtTs?.toDate() ?? DateTime.now(),
      reviewedAt: reviewedAtTs?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'claimantId': claimantId,
      'itemOwnerId': itemOwnerId,
      'proofDescription': proofDescription,
      'proofImageUrls': proofImageUrls,
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
      'reviewedAt': reviewedAt == null ? null : Timestamp.fromDate(reviewedAt!),
    };
  }

  static ClaimStatus _statusFromString(String? value) {
    switch (value) {
      case 'accepted':
        return ClaimStatus.accepted;
      case 'rejected':
        return ClaimStatus.rejected;
      case 'pending':
      default:
        return ClaimStatus.pending;
    }
  }
}
