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
    try {
      final data = document.data() ?? <String, dynamic>{};

      DateTime? parsedCreatedAt;
      if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
        parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
      }

      DateTime? parsedReviewedAt;
      if (data['reviewedAt'] != null && data['reviewedAt'] is Timestamp) {
        parsedReviewedAt = (data['reviewedAt'] as Timestamp).toDate();
      }

      List<String> parsedUrls = [];
      if (data['proofImageUrls'] != null) {
        if (data['proofImageUrls'] is List) {
          parsedUrls = (data['proofImageUrls'] as List)
              .map((e) => e.toString())
              .toList();
        }
      }

      return ClaimModel(
        id: document.id,
        itemId: data['itemId'] as String? ?? '',
        claimantId: data['claimantId'] as String? ?? '',
        itemOwnerId: data['itemOwnerId'] as String? ?? '',
        proofDescription: data['proofDescription'] as String? ?? '',
        proofImageUrls: parsedUrls,
        status: _statusFromString(data['status'] as String?),
        createdAt: parsedCreatedAt ?? DateTime.now(),
        reviewedAt: parsedReviewedAt,
      );
    } catch (e) {
      return ClaimModel(
        id: document.id,
        itemId: '',
        claimantId: '',
        itemOwnerId: '',
        proofDescription: 'Error loading claim: $e',
        proofImageUrls: const [],
        status: ClaimStatus.pending,
        createdAt: DateTime.now(),
      );
    }
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
