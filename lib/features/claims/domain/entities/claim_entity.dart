enum ClaimStatus { pending, accepted, rejected }

class ClaimEntity {
  const ClaimEntity({
    required this.id,
    required this.itemId,
    required this.claimantId,
    required this.itemOwnerId,
    required this.proofDescription,
    required this.proofImageUrls,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
  });

  final String id;
  final String itemId;
  final String claimantId;
  final String itemOwnerId;
  final String proofDescription;
  final List<String> proofImageUrls;
  final ClaimStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
}
