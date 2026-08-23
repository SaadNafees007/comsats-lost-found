import '../entities/claim_entity.dart';

abstract class ClaimRepository {
  /// Submit a new claim for [itemId].
  Future<ClaimEntity> submitClaim(ClaimEntity claim);

  /// Stream all claims on a specific item (for item owner to review).
  Stream<List<ClaimEntity>> getClaimsForItem(String itemId);

  /// Stream all claims submitted by the current user.
  Stream<List<ClaimEntity>> getMyClaims(String claimantId);

  /// Accept or reject a claim. Updates the claim document and the item status.
  Future<void> updateClaimStatus({
    required String claimId,
    required String itemId,
    required ClaimStatus newStatus,
  });
}
