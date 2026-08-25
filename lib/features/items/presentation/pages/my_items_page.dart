import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/navigation/bottom_navigation.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/item_entity.dart';
import '../providers/item_provider.dart';

class MyItemsPage extends ConsumerWidget {
  const MyItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final itemsAsync = ref.watch(myItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Items')),
      body: itemsAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to load your items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(myItemsProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (items) {
          if (user == null) {
            return const Center(
              child: Text('Please login to view your items.'),
            );
          }

          if (items.isEmpty) {
            return const _EmptyMyItems();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myItemsProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final item = items[index];

                return _MyItemCard(
                  item: item,
                  onTap: () {
                    context.push('${AppRoutes.itemDetails}/${item.id}');
                  },
                  onEdit: () {
                    context.push('${AppRoutes.editItem}/${item.id}');
                  },
                  onDelete: () {
                    _deleteItem(context, ref, item, user.uid);
                  },
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }

  Future<void> _deleteItem(
    BuildContext context,
    WidgetRef ref,
    ItemEntity item,
    String currentUserId,
  ) async {
    if (item.ownerId != currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to delete this item.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Item?'),
          content: Text(
            'Are you sure you want to delete "${item.title}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      if (item.imageUrls.isNotEmpty) {
        try {
          await ref
              .read(storageServiceProvider)
              .deleteItemImages(item.imageUrls);
        } catch (e) {
          debugPrint('[MyItemsPage] Storage cleanup failed: $e');
        }
      }

      await ref.read(itemRepositoryProvider).deleteItem(item.id);

      ref.invalidate(myItemsProvider);
      ref.invalidate(itemsProvider);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully.')),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to delete item: $error')));
    }
  }
}

class _MyItemCard extends StatelessWidget {
  const _MyItemCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ItemEntity item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isLost = item.type == ItemType.lost;

    final typeColor = isLost ? AppColors.error : AppColors.success;

    final typeText = isLost ? 'LOST' : 'FOUND';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    typeText,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                _StatusBadge(status: item.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.imageUrls.isNotEmpty &&
                    item.imageUrls.first.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item.imageUrls.first,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 64,
                        height: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_outlined, size: 24),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 17),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(item.location, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ItemStatus status;

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color color;

    switch (status) {
      case ItemStatus.active:
        text = 'ACTIVE';
        color = AppColors.success;
        break;

      case ItemStatus.claimed:
        text = 'CLAIMED';
        color = Colors.orange;
        break;

      case ItemStatus.resolved:
        text = 'RESOLVED';
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyMyItems extends StatelessWidget {
  const _EmptyMyItems();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            const Text(
              'No items reported yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Your lost and found reports will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
