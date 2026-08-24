import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comsats_lost_found/features/claims/data/models/claim_model.dart';
import 'package:comsats_lost_found/features/claims/domain/entities/claim_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClaimModel', () {
    final now = DateTime(2026, 8, 24, 12, 0);

    final testClaim = ClaimModel(
      id: 'claim-123',
      itemId: 'item-789',
      claimantId: 'claimant-11',
      itemOwnerId: 'owner-22',
      proofDescription: 'I left my black leather wallet on desk 4.',
      proofImageUrls: const ['https://example.com/proof.jpg'],
      status: ClaimStatus.pending,
      createdAt: now,
    );

    test('toFirestore should serialize correctly', () {
      final map = testClaim.toFirestore();

      expect(map['itemId'], 'item-789');
      expect(map['claimantId'], 'claimant-11');
      expect(map['itemOwnerId'], 'owner-22');
      expect(
        map['proofDescription'],
        'I left my black leather wallet on desk 4.',
      );
      expect(map['status'], 'pending');
      expect(map['proofImageUrls'], ['https://example.com/proof.jpg']);
      expect(map['createdAt'], isA<FieldValue>());
    });

    test('ClaimStatus enum names map to status strings', () {
      expect(ClaimStatus.pending.name, 'pending');
      expect(ClaimStatus.accepted.name, 'accepted');
      expect(ClaimStatus.rejected.name, 'rejected');
    });
  });
}
