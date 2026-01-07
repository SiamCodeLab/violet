import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

/// ============================================
/// FILE PICKER HELPER
/// ============================================

class PickedFileInfo {
  final String name;
  final String path;
  final int size;
  final String extension;
  final File file;

  PickedFileInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.extension,
    required this.file,
  });

  /// Get formatted file size (KB, MB)
  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Check if file is valid type
  bool get isValidType =>
      ['pdf', 'doc', 'docx', 'txt'].contains(extension.toLowerCase());
}

class FilePickerHelper {
  /// Pick single file (doc, txt, pdf)
  static Future<PickedFileInfo?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;

      if (file.path == null) return null;

      return PickedFileInfo(
        name: file.name,
        path: file.path!,
        size: file.size,
        extension: file.extension ?? '',
        file: File(file.path!),
      );
    } catch (e) {
      debugPrint('File pick error: $e');
      return null;
    }
  }

  /// Pick multiple files
  static Future<List<PickedFileInfo>> pickMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return [];

      return result.files
          .where((file) => file.path != null)
          .map(
            (file) => PickedFileInfo(
              name: file.name,
              path: file.path!,
              size: file.size,
              extension: file.extension ?? '',
              file: File(file.path!),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('File pick error: $e');
      return [];
    }
  }
}
