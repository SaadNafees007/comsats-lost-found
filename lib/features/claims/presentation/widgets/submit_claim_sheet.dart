import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/inputs/image_picker_field.dart';
import '../../../claims/domain/entities/claim_entity.dart';
import '../../../items/domain/entities/item_entity.dart';
import '../providers/claim_provider.dart';

/// Shows a modal bottom sheet for submitting a claim/proof on an item.
Future<void> showSubmitClaimSheet(
  BuildContext context, {
  required ItemEntity item,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _SubmitClaimSheet(item: item),
  );
}

class _SubmitClaimSheet extends ConsumerStatefulWidget {
  const _SubmitClaimSheet({required this.item});
  final ItemEntity item;

  @override
  ConsumerState<_SubmitClaimSheet> createState() => _SubmitClaimSheetState();
}

class _SubmitClaimSheetState extends ConsumerState<_SubmitClaimSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  List<XFile> _proofImages = [];
  bool _isSubmitting = false;
  String _statusMessage = 'Submitting claim...';

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSubmitting = true;
      _statusMessage = _proofImages.isNotEmpty
          ? 'Uploading proof photos...'
          : 'Submitting claim...';
    });

    try {
      // Upload proof images if provided
      List<String> proofImageUrls = const [];
      if (_proofImages.isNotEmpty) {
        try {
          proofImageUrls =
              await ref.read(storageServiceProvider).uploadItemImages(
                    userId: user.uid,
                    images: _proofImages,
                  );
        } catch (_) {
          // Non-fatal: proceed without images
        }
      }

      if (!mounted) return;
      setState(() => _statusMessage = 'Submitting claim...');

      final claim = ClaimEntity(
        id: '',
        itemId: widget.item.id,
        claimantId: user.uid,
        itemOwnerId: widget.item.ownerId,
        proofDescription: _descController.text.trim(),
        proofImageUrls: proofImageUrls,
        status: ClaimStatus.pending,
        createdAt: DateTime.now(),
      );

      await ref.read(submitClaimProvider.notifier).submit(claim);

      if (!mounted) return;

      final claimState = ref.read(submitClaimProvider);
      if (claimState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${claimState.error}')),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Claim submitted! The item owner will review your proof.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit claim: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLost = widget.item.type == ItemType.lost;
    final title = isLost ? 'Claim This Item' : 'Report Ownership';
    final hint = isLost
        ? 'Describe unique details that prove this is your item (e.g. serial number, contents, marks).'
        : 'Describe where you found this and why you believe you know the owner.';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Item: ${widget.item.title}',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Proof description
              TextFormField(
                controller: _descController,
                minLines: 4,
                maxLines: 6,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  labelText: 'Proof of Ownership',
                  hintText: hint,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description_outlined),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your proof of ownership.';
                  }
                  if (value.trim().length < 15) {
                    return 'Please provide more detail (at least 15 characters).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Optional proof photos
              ImagePickerField(
                onImagesChanged: (images) => _proofImages = images,
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _statusMessage,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                      : const Text('Submit Claim'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
