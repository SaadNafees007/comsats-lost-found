import '../../domain/entities/claim_entity.dart';
import '../../domain/repositories/claim_repository.dart';
import '../datasources/claim_remote_datasource.dart';
import '../models/claim_model.dart';

class ClaimRepositoryImpl implements ClaimRepository {
  ClaimRepositoryImpl({required ClaimRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ClaimRemoteDataSource _remoteDataSource;

  @override
  Future<ClaimEntity> submitClaim(ClaimEntity claim) {
    return _remoteDataSource.submitClaim(
      ClaimModel(
        id: claim.id,
        itemId: claim.itemId,
        claimantId: claim.claimantId,
        itemOwnerId: claim.itemOwnerId,
        proofDescription: claim.proofDescription,
        proofImageUrls: claim.proofImageUrls,
        status: claim.status,
        createdAt: claim.createdAt,
        reviewedAt: claim.reviewedAt,
      ),
    );
  }

  @override
  Stream<List<ClaimEntity>> getClaimsForItem(String itemId) {
    return _remoteDataSource.getClaimsForItem(itemId);
  }

  @override
  Stream<List<ClaimEntity>> getMyClaims(String claimantId) {
    return _remoteDataSource.getMyClaims(claimantId);
  }

  @override
  Future<void> updateClaimStatus({
    required String claimId,
    required String itemId,
    required ClaimStatus newStatus,
  }) {
    return _remoteDataSource.updateClaimStatus(
      claimId: claimId,
      itemId: itemId,
      newStatus: newStatus,
    );
  }
}
