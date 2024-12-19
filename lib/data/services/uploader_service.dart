import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/dialog_helper.dart';

final uploadServiceProvider = Provider<UploaderService>((ref) {
  return UploaderService();
});

class UploaderService {
  final supabase = Supabase.instance.client;

  /// [dir] is the directory on firebase storage bucket
  Future<String?> uploadFile(File file, String dir, FileType fileType,
      {Function(double)? onProgress,
      Function(double)? onCompressProgress}) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String extension = p.extension(file.path);

      final String path = await supabase.storage.from(dir).upload(
            '$fileName.$extension',
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl =
          supabase.storage.from('Cards').getPublicUrl('$fileName.$extension');
      return publicUrl;
    } catch (e) {
      print("Error Occurred uploading file $e");
      return null;
    }
  }

  /// [dir] is the directory on firebase storage bucket
  Future<String?> uploadWebFile(Uint8List file, String dir, String extension,
      {Function(double)? onProgress}) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      // String extension = p.extension(File.fromRawPath(file).path);

      // print("called $fileName $extension");
      final String path = await supabase.storage.from(dir).uploadBinary(
            '$fileName.$extension',
            file,
            // fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl =
          supabase.storage.from(dir).getPublicUrl('$fileName.$extension');
      return publicUrl;
    } on StorageException catch (e) {
      DialogHelper.showError(e.message);
      return null;
    }
  }
}

enum FileType { Image, Video, Audio }
