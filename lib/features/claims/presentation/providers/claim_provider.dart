import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/claim_remote_datasource.dart';
import '../../data/repositories/claim_repository_impl.dart';
import '../../domain/entities/claim_entity.dart';
import '../../domain/repositories/claim_repository.dart';

final claimRemoteDataSourceProvider = Provider<ClaimRemoteDataSource>((ref) {
  return ClaimRemoteDataSource();
});

final claimRepositoryProvider = Provider<ClaimRepository>((ref) {
  return ClaimRepositoryImpl(
    remoteDataSource: ref.watch(claimRemoteDataSourceProvider),
  );
});

/// Claims submitted TO a specific item (item owner reviews incoming claims)
final claimsForItemProvider = StreamProvider.family<List<ClaimEntity>, String>((
  ref,
  itemId,
) {
  return ref.watch(claimRepositoryProvider).getClaimsForItem(itemId);
});

/// My submitted claims — scoped to the currently authenticated user.
final myClaimsProvider = StreamProvider<List<ClaimEntity>>((ref) async* {
  // Wait for auth to be resolved (not loading).
  final authUser = await ref.watch(authStateProvider.future);

  if (authUser == null) {
    yield const <ClaimEntity>[];
    return;
  }

  // Auth is ready — stream claims for this user.
  yield* ref.read(claimRepositoryProvider).getMyClaims(authUser.uid);
});

/// Notifier for submit-claim action with loading/error state
class SubmitClaimNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit(ClaimEntity claim) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(claimRepositoryProvider).submitClaim(claim);
    });
  }
}

final submitClaimProvider = AsyncNotifierProvider<SubmitClaimNotifier, void>(
  SubmitClaimNotifier.new,
);

/// Notifier for accept/reject claim action with loading/error state
class ReviewClaimNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> accept({required String claimId, required String itemId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(claimRepositoryProvider)
          .updateClaimStatus(
            claimId: claimId,
            itemId: itemId,
            newStatus: ClaimStatus.accepted,
          );
    });
  }

  Future<void> reject({required String claimId, required String itemId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(claimRepositoryProvider)
          .updateClaimStatus(
            claimId: claimId,
            itemId: itemId,
            newStatus: ClaimStatus.rejected,
          );
    });
  }
}

final reviewClaimProvider = AsyncNotifierProvider<ReviewClaimNotifier, void>(
  ReviewClaimNotifier.new,
);
