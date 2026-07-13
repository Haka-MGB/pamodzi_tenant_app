import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service to handle image picking from camera or gallery
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    try {
      // Request storage permission
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        // Try alternative permission for Android
        final altStatus = await Permission.storage.request();
        if (!altStatus.isGranted) {
          return null;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleFromGallery({int maxImages = 5}) async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        final altStatus = await Permission.storage.request();
        if (!altStatus.isGranted) {
          return [];
        }
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      // Limit number of images
      final limitedImages = images.take(maxImages).toList();

      return limitedImages.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Check if storage/photos permission is granted
  Future<bool> isStoragePermissionGranted() async {
    final photosStatus = await Permission.photos.isGranted;
    final storageStatus = await Permission.storage.isGranted;
    return photosStatus || storageStatus;
  }
}
