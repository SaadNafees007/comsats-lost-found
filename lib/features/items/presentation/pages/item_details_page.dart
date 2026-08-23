import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/item_entity.dart';
import '../providers/item_provider.dart';
import '../widgets/image_carousel.dart';

class ItemDetailsPage extends ConsumerWidget {
  const ItemDetailsPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemDetailsProvider(itemId));

    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: itemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load item',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(itemDetailsProvider(itemId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Item not found.'));
          }

          return _ItemDetailsContent(item: item);
        },
      ),
    );
  }
}

class _ItemDetailsContent extends StatelessWidget {
  const _ItemDetailsContent({required this.item});

  final ItemEntity item;

  @override
  Widget build(BuildContext context) {
    final isLost = item.type == ItemType.lost;
    final typeColor = isLost ? AppColors.error : AppColors.success;
    final typeText = isLost ? 'LOST' : 'FOUND';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUrls.isNotEmpty) ...[
            ImageCarousel(imageUrls: item.imageUrls),
            const SizedBox(height: 20),
          ],

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
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

              const Spacer(),

              Text(
                item.category,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            item.title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          Text(
            item.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          _InfoRow(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: item.location,
          ),

          const SizedBox(height: 14),

          _InfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Date',
            value:
                '${item.date.day.toString().padLeft(2, '0')}/'
                '${item.date.month.toString().padLeft(2, '0')}/'
                '${item.date.year}',
          ),

          const SizedBox(height: 14),

          _InfoRow(
            icon: Icons.info_outline,
            title: 'Status',
            value: _statusText(item.status),
          ),

          const SizedBox(height: 30),

          if (item.type == ItemType.lost)
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Claim / recovery flow in Milestone 2
                },
                icon: const Icon(Icons.contact_page_outlined),
                label: const Text('I Found This Item'),
              ),
            ),

          if (item.type == ItemType.found)
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Claim / recovery flow in Milestone 2
                },
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('This Is My Item (Claim)'),
              ),
            ),
        ],
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
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
