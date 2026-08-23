import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/item_entity.dart';

class ItemDetailsPage extends ConsumerWidget {
  const ItemDetailsPage({super.key, required this.item});

  final ItemEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLost = item.type == ItemType.lost;
    final typeColor = isLost ? AppColors.error : AppColors.success;
    final typeText = isLost ? 'LOST ITEM' : 'FOUND ITEM';

    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  typeText,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              // Category
              Row(
                children: [
                  const Icon(Icons.category_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    item.category,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Description
              _DetailsSection(
                title: 'Description',
                icon: Icons.description_outlined,
                child: Text(
                  item.description,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),

              const SizedBox(height: 20),

              // Location
              _DetailsSection(
                title: isLost ? 'Last Seen Location' : 'Found Location',
                icon: Icons.location_on_outlined,
                child: Text(
                  item.location,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ),

              const SizedBox(height: 20),

              // Date
              _DetailsSection(
                title: isLost ? 'Date Lost' : 'Date Found',
                icon: Icons.calendar_today_outlined,
                child: Text(
                  '${item.date.day.toString().padLeft(2, '0')}/'
                  '${item.date.month.toString().padLeft(2, '0')}/'
                  '${item.date.year}',
                  style: const TextStyle(fontSize: 15),
                ),
              ),

              const SizedBox(height: 20),

              // Status
              _DetailsSection(
                title: 'Status',
                icon: Icons.info_outline,
                child: Text(
                  _statusText(item.status),
                  style: TextStyle(
                    color: _statusColor(item.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: item.status == ItemStatus.active
                      ? () {
                          _showContactDialog(context);
                        }
                      : null,
                  icon: Icon(
                    isLost
                        ? Icons.person_search_outlined
                        : Icons.check_circle_outline,
                  ),
                  label: Text(
                    isLost ? 'I Found This Item' : 'I Think This Is Mine',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  'Item ID: ${item.id}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(ItemStatus status) {
    switch (status) {
      case ItemStatus.active:
        return 'Active';
      case ItemStatus.claimed:
        return 'Claimed';
      case ItemStatus.resolved:
        return 'Resolved';
    }
  }

  Color _statusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.active:
        return AppColors.success;
      case ItemStatus.claimed:
        return Colors.orange;
      case ItemStatus.resolved:
        return Colors.grey;
    }
  }

  void _showContactDialog(BuildContext context) {
    final isLost = item.type == ItemType.lost;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isLost ? 'Found This Item?' : 'Is This Your Item?'),
          content: Text(
            isLost
                ? 'You can contact the person who reported this item as lost to arrange its return.'
                : 'You can contact the person who reported this item as found to verify ownership and arrange its return.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact feature will be available soon.'),
                  ),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              Icon(icon, size: 19),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
