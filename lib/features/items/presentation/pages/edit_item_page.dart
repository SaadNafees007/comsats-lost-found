import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/inputs/image_picker_field.dart';
import '../../domain/entities/item_entity.dart';
import '../providers/item_provider.dart';

class EditItemPage extends ConsumerStatefulWidget {
  const EditItemPage({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends ConsumerState<EditItemPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _locationController;

  ItemEntity? _item;
  List<String> _existingUrls = [];
  List<XFile> _newSelectedFiles = [];
  bool _isSaving = false;
  String _savingMessage = 'Saving changes...';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _categoryController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _initializeFields(ItemEntity item) {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _item = item;
    _existingUrls = List.from(item.imageUrls);

    _titleController.text = item.title;
    _descriptionController.text = item.description;
    _categoryController.text = item.category;
    _locationController.text = item.location;
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = _item;

    if (item == null) {
      return;
    }

    final user = ref.read(authStateProvider).valueOrNull;

    if (user == null) {
      _showMessage('Please login again.');
      return;
    }

    // Client-side ownership check.
    if (item.ownerId != user.uid) {
      _showMessage('You do not have permission to edit this item.');
      return;
    }

    setState(() {
      _isSaving = true;
      _savingMessage = _newSelectedFiles.isNotEmpty
          ? 'Uploading new photos...'
          : 'Updating item...';
    });

    try {
      // Step 1: Upload any new local images
      List<String> newlyUploadedUrls = const [];
      if (_newSelectedFiles.isNotEmpty) {
        newlyUploadedUrls = await ref
            .read(storageServiceProvider)
            .uploadItemImages(userId: user.uid, images: _newSelectedFiles);
      }

      final combinedUrls = [..._existingUrls, ...newlyUploadedUrls];

      if (!mounted) return;

      setState(() {
        _savingMessage = 'Saving item updates...';
      });

      // Step 2: Update item record in Firestore
      final updatedItem = ItemEntity(
        id: item.id,
        ownerId: item.ownerId,
        type: item.type,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        location: _locationController.text.trim(),
        date: item.date,
        imageUrls: combinedUrls,
        status: item.status,
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
      );

      await ref.read(itemRepositoryProvider).updateItem(updatedItem);

      ref.invalidate(itemDetailsProvider(widget.itemId));
      ref.invalidate(itemsProvider);
      ref.invalidate(myItemsProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated successfully.')),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      _showMessage('Unable to update item: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemDetailsProvider(widget.itemId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: itemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load item.\n\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (item) {
          if (item == null) {
            return const Center(child: Text('Item not found.'));
          }

          _initializeFields(item);

          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    final item = _item!;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ReadOnlyInfo(
            label: 'Report Type',
            value: item.type == ItemType.lost ? 'Lost Item' : 'Found Item',
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter item title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required.';
              }

              if (value.trim().length < 2) {
                return 'Title is too short.';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe the item',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required.';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _categoryController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Category',
              hintText: 'e.g. Wallet, Phone, Keys',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Category is required.';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _locationController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'Where was it lost/found?',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Location is required.';
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          ImagePickerField(
            initialImageUrls: _existingUrls,
            onExistingImagesChanged: (remainingUrls) {
              _existingUrls = remainingUrls;
            },
            onImagesChanged: (newImages) {
              _newSelectedFiles = newImages;
            },
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveItem,
              child: _isSaving
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _savingMessage,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyInfo extends StatelessWidget {
  const _ReadOnlyInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}
