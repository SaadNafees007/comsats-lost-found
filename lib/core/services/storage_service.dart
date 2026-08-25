import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  StorageService({FirebaseStorage? firebaseStorage})
    : _storage = firebaseStorage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Uploads a list of [XFile]s to Firebase Storage under `items/{userId}/{uuid}.jpg`.
  /// Uses [readAsBytes] to ensure cross-platform support across Mobile, Web, and Desktop.
  Future<List<String>> uploadItemImages({
    required String userId,
    required List<XFile> images,
  }) async {
    if (images.isEmpty) return const [];

    final base64Images = <String>[];
    final List<String> errors = [];

    for (final image in images) {
      try {
        final imageBytes = await image.readAsBytes();
        final base64String = base64Encode(imageBytes);
        // Prefix with data URI scheme so it's easily recognizable
        base64Images.add('data:image/jpeg;base64,$base64String');
      } catch (e, stackTrace) {
        debugPrint('[StorageService] Image encoding error: $e\n$stackTrace');
        errors.add(e.toString());
      }
    }

    if (base64Images.isEmpty && errors.isNotEmpty) {
      throw Exception(
        'All photo encodings failed. Last error: ${errors.last}',
      );
    }

    return base64Images;
  }

  /// Deletes a list of image URLs from Firebase Storage.
  Future<void> deleteItemImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      if (url.isEmpty) continue;
      // Base64 images are stored directly in Firestore, so no need to delete them from Storage
      if (url.startsWith('data:image')) continue;
      
      try {
        final ref = _storage.refFromURL(url);
        await ref.delete().timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('[StorageService] Delete image error: $e');
      }
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
