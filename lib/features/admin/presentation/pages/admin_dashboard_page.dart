import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../claims/domain/entities/claim_entity.dart';
import '../../../items/domain/entities/item_entity.dart';
import '../providers/admin_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: Center(child: Text('Error loading profile: $e')),
      ),
      data: (userProfile) {
        if (userProfile == null || userProfile.role != 'admin') {
          return Scaffold(
            appBar: AppBar(title: const Text('Access Denied')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, size: 72, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Access Denied',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You do not have the required administrator permissions to view this dashboard.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.home),
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final stats = ref.watch(adminStatsProvider);

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Admin Dashboard'),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.inventory_2_outlined),
                    text: 'All Reports',
                  ),
                  Tab(
                    icon: Icon(Icons.assignment_turned_in_outlined),
                    text: 'All Claims',
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                // Stats Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Total Posts',
                              value: '${stats.totalItems}',
                              icon: Icons.inventory_2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatCard(
                              title: 'Lost Items',
                              value: '${stats.lostCount}',
                              icon: Icons.search_off,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatCard(
                              title: 'Found Items',
                              value: '${stats.foundCount}',
                              icon: Icons.check_circle_outline,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Total Claims',
                              value: '${stats.totalClaims}',
                              icon: Icons.assignment_outlined,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatCard(
                              title: 'Pending Claims',
                              value: '${stats.pendingClaims}',
                              icon: Icons.pending_actions,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatCard(
                              title: 'Resolved',
                              value: '${stats.claimedCount}',
                              icon: Icons.verified,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: TabBarView(
                    children: [_AdminItemsTab(), _AdminClaimsTab()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AdminItemsTab extends ConsumerWidget {
  const _AdminItemsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(adminAllItemsProvider);

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading items: $e')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No items registered.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () =>
                    context.push('${AppRoutes.itemDetails}/${item.id}'),
                leading: CircleAvatar(
                  backgroundColor: item.type == ItemType.lost
                      ? Colors.orange.withValues(alpha: 0.2)
                      : AppColors.secondary.withValues(alpha: 0.2),
                  child: Icon(
                    item.type == ItemType.lost ? Icons.search : Icons.check,
                    color: item.type == ItemType.lost
                        ? Colors.orange
                        : AppColors.secondary,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${item.category} • Status: ${item.status.name.toUpperCase()}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Report?'),
                          content: const Text(
                            'Are you sure you want to force delete this item as admin?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref
                            .read(adminRemoteDataSourceProvider)
                            .adminDeleteItem(item.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item deleted by admin.'),
                            ),
                          );
                        }
                      }
                    } else if (value == 'resolve') {
                      await ref
                          .read(adminRemoteDataSourceProvider)
                          .adminUpdateItemStatus(item.id, 'resolved');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item marked as resolved.'),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'resolve',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 18),
                          SizedBox(width: 8),
                          Text('Mark Resolved'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete Report',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AdminClaimsTab extends ConsumerWidget {
  const _AdminClaimsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(adminAllClaimsProvider);

    return claimsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading claims: $e')),
      data: (claims) {
        if (claims.isEmpty) {
          return const Center(child: Text('No claims submitted.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: claims.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final claim = claims[index];
            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () {
                  if (claim.itemId.isNotEmpty) {
                    context.push('${AppRoutes.itemDetails}/${claim.itemId}');
                  }
                },
                leading: CircleAvatar(
                  backgroundColor: claim.status == ClaimStatus.accepted
                      ? AppColors.success.withValues(alpha: 0.2)
                      : claim.status == ClaimStatus.rejected
                      ? AppColors.error.withValues(alpha: 0.2)
                      : Colors.amber.withValues(alpha: 0.2),
                  child: Icon(
                    claim.status == ClaimStatus.accepted
                        ? Icons.check
                        : claim.status == ClaimStatus.rejected
                        ? Icons.close
                        : Icons.hourglass_empty,
                    size: 20,
                    color: claim.status == ClaimStatus.accepted
                        ? AppColors.success
                        : claim.status == ClaimStatus.rejected
                        ? AppColors.error
                        : Colors.amber,
                  ),
                ),
                title: Text(
                  'Claim #${claim.id.substring(0, claim.id.length > 8 ? 8 : claim.id.length)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Proof: ${claim.proofDescription}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  claim.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: claim.status == ClaimStatus.accepted
                        ? AppColors.success
                        : claim.status == ClaimStatus.rejected
                        ? AppColors.error
                        : Colors.amber,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
