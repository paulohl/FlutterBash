import 'dart:io';
import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final imagePickerProvider = Provider<MyImagePicker>((ref) {
  return MyImagePickerImpl();
});

abstract class MyImagePicker {
  Future<Uint8List?> pickWebImage(PickType pickType);

  Future<File?> pickImage(PickType pickType);

  Future<XFile?> pickVideo(PickType pickType);

  Future<List<File>> pickMultipleFiles();
}

class MyImagePickerImpl extends MyImagePicker {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Future<File?> pickImage(PickType pickType) async {
    final xFile = await _imagePicker.pickImage(
      source: pickType == PickType.fromGallery
          ? ImageSource.gallery
          : ImageSource.camera,
      imageQuality: 50,
    );

    return xFile == null ? null : File(xFile.path);
  }

  @override
  Future<Uint8List?> pickWebImage(PickType pickType) async {
    final xFile = await _imagePicker.pickImage(
      source: pickType == PickType.fromGallery
          ? ImageSource.gallery
          : ImageSource.camera,
      imageQuality: 50,
    );

    return xFile == null ? null : await xFile.readAsBytes();
  }

  @override
  Future<XFile?> pickVideo(PickType pickType) async {
    final XFile? xFile = await _imagePicker.pickVideo(
      source: pickType == PickType.fromGallery
          ? ImageSource.gallery
          : ImageSource.camera,
    );
    return xFile;
  }

  @override
  Future<List<File>> pickMultipleFiles() async {
    final files = await _imagePicker.pickMultiImage(imageQuality: 30);
    if (files != null) {
      return files.map((e) => File(e.path)).toList();
    } else {
      return [];
    }
  }
}

enum PickType { fromGallery, fromCamera }

// Image Types
abstract class ImageType {}

class PotraitImageType extends ImageType {}

class LandscapeImageType extends ImageType {}
