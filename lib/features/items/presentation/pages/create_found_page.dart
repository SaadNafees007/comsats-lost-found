import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../domain/entities/item_entity.dart';
import '../providers/item_provider.dart';

class CreateFoundPage extends ConsumerStatefulWidget {
  const CreateFoundPage({super.key});

  @override
  ConsumerState<CreateFoundPage> createState() => _CreateFoundPageState();
}

class _CreateFoundPageState extends ConsumerState<CreateFoundPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

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
    });

    try {
      final item = ItemEntity(
        id: '',
        ownerId: user.uid,
        type: ItemType.found,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        location: _locationController.text.trim(),
        date: _selectedDate,
        imageUrls: const [],
        status: ItemStatus.active,
        createdAt: null,
        updatedAt: null,
      );

      await ref.read(createItemProvider).call(item);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Found item reported successfully.')),
      );

      context.go(AppRoutes.home);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Unable to report the found item.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
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
      appBar: AppBar(title: const Text('Report Found Item')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Report a Found Item',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Provide accurate information so the owner can identify and recover the item.',
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Item Title',
                    hint: 'e.g. Black Wallet',
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
                    label: 'Found Location',
                    hint: 'e.g. Library, Cafeteria, Block A',
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
                  minLines: 4,
                  maxLines: 6,
                  decoration: _inputDecoration(
                    label: 'Description',
                    hint: 'Describe the item, identifying marks, color, etc.',
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
                      label: 'Date Found',
                      icon: Icons.calendar_today_outlined,
                    ),
                    child: Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/'
                      '${_selectedDate.month.toString().padLeft(2, '0')}/'
                      '${_selectedDate.year}',
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Report Found Item'),
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
