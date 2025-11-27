import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class ExternalStorageAudioHelper {
  static const String _basePath =
      '/storage/emulated/0/Android/data/com.example.lecture_app/files/LectureAudios';

  /// Check and request storage permissions
  static Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    }
    return false;
  }

  /// Get the full path for an audio file
  static String getAudioPath(String bookFolder, String fileName) {
    return '$_basePath/$bookFolder/$fileName';
  }

  /// Check if an audio file exists
  static Future<bool> audioFileExists(
    String bookFolder,
    String fileName,
  ) async {
    final file = File(getAudioPath(bookFolder, fileName));
    return await file.exists();
  }

  /// Get a File reference for an audio file
  static Future<File?> getAudioFile(String bookFolder, String fileName) async {
    if (!await checkPermissions()) {
      throw Exception('Storage permission not granted');
    }

    final file = File(getAudioPath(bookFolder, fileName));
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Get all audio files in a book folder
  static Future<List<File>> getAudioFilesInBook(String bookFolder) async {
    if (!await checkPermissions()) {
      throw Exception('Storage permission not granted');
    }

    final dir = Directory('$_basePath/$bookFolder');
    if (!await dir.exists()) {
      return [];
    }

    final List<File> audioFiles = [];
    await for (final entity in dir.list(recursive: false)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
        audioFiles.add(entity);
      }
    }
    return audioFiles;
  }

  /// Check if base directory exists
  static Future<bool> checkBaseDirectoryExists() async {
    if (!await checkPermissions()) {
      return false;
    }
    final dir = Directory(_basePath);
    return await dir.exists();
  }
}
