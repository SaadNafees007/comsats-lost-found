import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  ImageService({ImagePicker? imagePicker})
      : _picker = imagePicker ?? ImagePicker();

  final ImagePicker _picker;

  /// Captures a single image from the camera with optimized size and compression.
  Future<XFile?> pickImageFromCamera({
    double maxWidth = 1280,
    double maxHeight = 1280,
    int imageQuality = 80,
  }) async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
    } catch (_) {
      return null;
    }
  }

  /// Picks a single image from the device gallery.
  Future<XFile?> pickImageFromGallery({
    double maxWidth = 1280,
    double maxHeight = 1280,
    int imageQuality = 80,
  }) async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
    } catch (_) {
      return null;
    }
  }

  /// Picks multiple images from the device gallery.
  Future<List<XFile>> pickMultiImages({
    double maxWidth = 1280,
    double maxHeight = 1280,
    int imageQuality = 80,
    int limit = 4,
  }) async {
    try {
      final images = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        limit: limit,
      );
      return images;
    } catch (_) {
      return const [];
    }
  }
}

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});
