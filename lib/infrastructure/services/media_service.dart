import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planpal/domain/models/message.dart';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from camera or gallery
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick a document or file
  Future<File?> pickFile({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          return File(path);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Pick a document (PDF, DOCX, TXT, etc.)
  Future<File?> pickDocument() async {
    return pickFile(
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'],
    );
  }

  /// Get message type based on file extension
  MessageType getMessageType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    // Image types
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return MessageType.image;
    }
    
    // Document types
    if (['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'].contains(extension)) {
      return MessageType.document;
    }
    
    // Default to file
    return MessageType.file;
  }

  /// Get emoji icon for message type
  String getMessageTypeIcon(MessageType type) {
    switch (type) {
      case MessageType.image:
        return '📷';
      case MessageType.document:
        return '📄';
      case MessageType.file:
        return '📎';
      default:
        return '';
    }
  }

  /// Check if file size is within limit (10MB)
  bool isFileSizeValid(File file) {
    final sizeInBytes = file.lengthSync();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= 10;
  }

  /// Get formatted file size
  String getFormattedFileSize(File file) {
    final sizeInBytes = file.lengthSync();
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
