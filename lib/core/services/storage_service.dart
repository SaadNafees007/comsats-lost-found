import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  StorageService({FirebaseStorage? firebaseStorage})
    : _storage = firebaseStorage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  final Uuid _uuid = const Uuid();

  /// Uploads a list of [XFile]s to Firebase Storage under `items/{userId}/{uuid}.jpg`.
  /// Uses [readAsBytes] to ensure cross-platform support across Mobile, Web, and Desktop.
  Future<List<String>> uploadItemImages({
    required String userId,
    required List<XFile> images,
  }) async {
    if (images.isEmpty) return const [];

    final downloadUrls = <String>[];

    for (final image in images) {
      try {
        final imageBytes = await image.readAsBytes();
        final fileName = '${_uuid.v4()}.jpg';
        final ref = _storage.ref().child('items').child(userId).child(fileName);

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploadedBy': userId},
        );

        final uploadTask = ref.putData(imageBytes, metadata);
        final snapshot = await uploadTask.timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            uploadTask.cancel();
            throw Exception('Photo upload timed out.');
          },
        );

        final downloadUrl = await snapshot.ref.getDownloadURL().timeout(
          const Duration(seconds: 10),
        );
        downloadUrls.add(downloadUrl);
      } catch (e, stackTrace) {
        debugPrint('[StorageService] Image upload error: $e\n$stackTrace');
        // Continue uploading remaining images even if one fails
        continue;
      }
    }

    return downloadUrls;
  }

  /// Deletes a list of image URLs from Firebase Storage.
  Future<void> deleteItemImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      if (url.isEmpty) continue;
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
