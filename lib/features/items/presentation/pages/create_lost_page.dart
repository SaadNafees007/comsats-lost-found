import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/inputs/image_picker_field.dart';
import '../../domain/entities/item_entity.dart';
import '../providers/item_provider.dart';

class CreateLostPage extends ConsumerStatefulWidget {
  const CreateLostPage({super.key});

  @override
  ConsumerState<CreateLostPage> createState() => _CreateLostPageState();
}

class _CreateLostPageState extends ConsumerState<CreateLostPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();

  List<XFile> _selectedImages = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String _loadingMessage = 'Reporting item...';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to report an item.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = _selectedImages.isNotEmpty
          ? 'Uploading photos...'
          : 'Reporting lost item...';
    });

    try {
      // Step 1: Upload images if any
      List<String> imageUrls = const [];
      if (_selectedImages.isNotEmpty) {
        try {
          imageUrls = await ref
              .read(storageServiceProvider)
              .uploadItemImages(userId: user.uid, images: _selectedImages);
        } catch (storageError) {
          debugPrint('[CreateLostPage] Storage upload error: $storageError');
        }
      }

      if (!mounted) return;

      setState(() {
        _loadingMessage = 'Saving report...';
      });

      // Step 2: Create item in Firestore
      final item = ItemEntity(
        id: '',
        ownerId: user.uid,
        type: ItemType.lost,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        location: _locationController.text.trim(),
        date: _selectedDate,
        imageUrls: imageUrls,
        status: ItemStatus.active,
        createdAt: null,
        updatedAt: null,
      );

      await ref.read(createItemProvider).call(item);

      if (!mounted) return;

      ref.invalidate(itemsProvider);
      ref.invalidate(myItemsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lost item reported successfully.')),
      );

      context.go(AppRoutes.home);
    } on FirebaseException catch (e, stack) {
      debugPrint(
        '[CreateLostPage] FirebaseException: ${e.code} - ${e.message}\n$stack',
      );
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message ?? e.code}')));
    } catch (e, stack) {
      debugPrint('[CreateLostPage] Generic error: $e\n$stack');
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save item: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Lost Item')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Report a Lost Item',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Provide accurate information and photos to help others identify and return your item.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Item Title',
                    hint: 'e.g. Black Leather Wallet',
                    icon: Icons.title_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an item title.';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Category',
                    hint: 'e.g. Electronics, Wallet, Documents',
                    icon: Icons.category_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Last Seen Location',
                    hint: 'e.g. Library 1st Floor, CS Dept Lab 3',
                    icon: Icons.location_on_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the location.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _inputDecoration(
                    label: 'Description',
                    hint:
                        'Describe identifying marks, color, brand, contents, etc.',
                    icon: Icons.description_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description.';
                    }
                    if (value.trim().length < 10) {
                      return 'Please provide a more detailed description.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _isLoading ? null : _selectDate,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      label: 'Date Lost',
                      icon: Icons.calendar_today_outlined,
                    ),
                    child: Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/'
                      '${_selectedDate.month.toString().padLeft(2, '0')}/'
                      '${_selectedDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ImagePickerField(
                  onImagesChanged: (images) {
                    _selectedImages = images;
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
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
                                _loadingMessage,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        : const Text('Report Lost Item'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
