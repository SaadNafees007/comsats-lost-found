import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../claims/domain/entities/claim_entity.dart';
import '../../../items/domain/entities/item_entity.dart';
import '../../data/datasources/admin_remote_datasource.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSource();
});

final adminAllItemsProvider = StreamProvider<List<ItemEntity>>((ref) {
  return ref.watch(adminRemoteDataSourceProvider).getAllItems();
});

final adminAllClaimsProvider = StreamProvider<List<ClaimEntity>>((ref) {
  return ref.watch(adminRemoteDataSourceProvider).getAllClaims();
});

class AdminStats {
  const AdminStats({
    required this.totalItems,
    required this.lostCount,
    required this.foundCount,
    required this.claimedCount,
    required this.totalClaims,
    required this.pendingClaims,
  });

  final int totalItems;
  final int lostCount;
  final int foundCount;
  final int claimedCount;
  final int totalClaims;
  final int pendingClaims;
}

final adminStatsProvider = Provider<AdminStats>((ref) {
  final items = ref.watch(adminAllItemsProvider).valueOrNull ?? [];
  final claims = ref.watch(adminAllClaimsProvider).valueOrNull ?? [];

  final lostCount = items.where((i) => i.type == ItemType.lost).length;
  final foundCount = items.where((i) => i.type == ItemType.found).length;
  final claimedCount = items
      .where((i) => i.status == ItemStatus.claimed)
      .length;
  final pendingClaims = claims
      .where((c) => c.status == ClaimStatus.pending)
      .length;

  return AdminStats(
    totalItems: items.length,
    lostCount: lostCount,
    foundCount: foundCount,
    claimedCount: claimedCount,
    totalClaims: claims.length,
    pendingClaims: pendingClaims,
  );
});
