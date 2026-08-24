import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../items/domain/entities/item_entity.dart';
import '../../domain/entities/claim_entity.dart';
import '../providers/claim_provider.dart';

class ItemClaimsPage extends ConsumerWidget {
  const ItemClaimsPage({super.key, required this.item});

  final ItemEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimsAsync = ref.watch(claimsForItemProvider(item.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Claims'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      body: claimsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Unable to load claims',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(claimsForItemProvider(item.id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (claims) {
          if (claims.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 56),
                  SizedBox(height: 16),
                  Text(
                    'No claims yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'No one has submitted a claim for this item yet.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: claims.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _ClaimCard(claim: claims[index], itemId: item.id);
            },
          );
        },
      ),
    );
  }
}

class _ClaimCard extends ConsumerWidget {
  const _ClaimCard({required this.claim, required this.itemId});

  final ClaimEntity claim;
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(reviewClaimProvider);
    final isProcessing = reviewState.isLoading;
    final isPending = claim.status == ClaimStatus.pending;

    Color statusColor;
    String statusLabel;
    switch (claim.status) {
      case ClaimStatus.pending:
        statusColor = Colors.orange;
        statusLabel = 'Pending Review';
      case ClaimStatus.accepted:
        statusColor = AppColors.success;
        statusLabel = 'Accepted';
      case ClaimStatus.rejected:
        statusColor = AppColors.error;
        statusLabel = 'Rejected';
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const Icon(Icons.person_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Claimant ID: ${claim.claimantId.substring(0, 8)}...',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Submitted date
            Text(
              'Submitted: ${_formatDate(claim.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),

            // Proof description
            Text(
              'Proof Description',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              claim.proofDescription,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),

            // Proof photos (if any)
            if (claim.proofImageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Proof Photos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: claim.proofImageUrls.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: () => _openImage(context, claim.proofImageUrls[i]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          claim.proofImageUrls[i],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 80,
                            height: 80,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Accept / Reject buttons (only for pending claims)
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => _reject(context, ref),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => _accept(context, ref),
                      icon: isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Accept Claim',
      message:
          'Are you sure you want to accept this claim? The item status will be updated to "Claimed".',
      confirmLabel: 'Accept',
    );
    if (confirmed != true) return;

    await ref
        .read(reviewClaimProvider.notifier)
        .accept(claimId: claim.id, itemId: itemId);

    if (claim.claimantId.isNotEmpty) {
      try {
        await ref
            .read(notificationRepositoryProvider)
            .sendNotification(
              NotificationEntity(
                id: '',
                recipientId: claim.claimantId,
                senderId: claim.itemOwnerId,
                itemId: itemId,
                title: 'Claim Accepted! 🎉',
                body:
                    'Your claim proof was accepted by the item owner. Tap to view item details.',
                type: NotificationType.claimAccepted,
                isRead: false,
                createdAt: DateTime.now(),
              ),
            );
      } catch (_) {
        // Non-fatal notification error
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Claim accepted. Item marked as claimed.'),
        ),
      );
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showConfirmationDialog(
      context,
      title: 'Reject Claim',
      message:
          'Are you sure you want to reject this claim? The item will remain active for other claims.',
      confirmLabel: 'Reject',
      isDestructive: true,
    );
    if (confirmed != true) return;

    await ref
        .read(reviewClaimProvider.notifier)
        .reject(claimId: claim.id, itemId: itemId);

    if (claim.claimantId.isNotEmpty) {
      try {
        await ref
            .read(notificationRepositoryProvider)
            .sendNotification(
              NotificationEntity(
                id: '',
                recipientId: claim.claimantId,
                senderId: claim.itemOwnerId,
                itemId: itemId,
                title: 'Claim Update',
                body:
                    'Your claim proof was reviewed and declined by the item owner.',
                type: NotificationType.claimRejected,
                isRead: false,
                createdAt: DateTime.now(),
              ),
            );
      } catch (_) {
        // Non-fatal notification error
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Claim rejected.')));
    }
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? AppColors.error : null,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _openImage(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image_outlined,
                  size: 64,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}  '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
