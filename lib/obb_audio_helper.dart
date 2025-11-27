// 

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ============================================================
//  HIGH-PERFORMANCE AUDIO LOADER FOR LARGE OBB (v2 - Real Version)
// ============================================================

Future<File> _getObbIndexFile() async {
  final tempDir = await getApplicationDocumentsDirectory();
  return File('${tempDir.path}/obb_index_v2.json');
}

Future<Map<String, String>> _buildObbIndex(String obbPath) async {
  final input = InputFileStream(obbPath);
  final archive = ZipDecoder().decodeBuffer(input);
  final Map<String, String> index = {};
  for (final file in archive) {
    if (file.isFile) {
      final name = file.name.split('/').last;
      index[name] = file.name;
    }
  }
  return index;
}

Future<void> _saveObbIndex(Map<String, String> index, File file) async {
  await file.writeAsString(json.encode(index), flush: true);
}

Future<Map<String, String>> _loadOrCreateObbIndex(String obbPath) async {
  final indexFile = await _getObbIndexFile();

  if (await indexFile.exists()) {
    try {
      final content = await indexFile.readAsString();
      return Map<String, String>.from(json.decode(content));
    } catch (_) {}
  }

  final index = await _buildObbIndex(obbPath);
  await _saveObbIndex(index, indexFile);
  return index;
}

// ============================================================
//  Get Audio Path – Optimized & Cached
// ============================================================

Future<String?> getAudioPathFromObb(String audioFileName) async {
  // 1️⃣ Ensure storage permission (Android)
  if (!await Permission.storage.isGranted) {
    final status = await Permission.storage.request();
    if (!status.isGranted) return null;
  }

  // 2️⃣ Locate OBB
  const obbPath =
      '/sdcard/Android/obb/com.example.lecture_app/main.1.com.example.lecture_app.obb';
  final obbFile = File(obbPath);
  if (!obbFile.existsSync()) return null;

  // 3️⃣ Persistent cache folder
  final appDir = await getApplicationDocumentsDirectory();
  final cacheDir = Directory('${appDir.path}/cached_audios');
  if (!cacheDir.existsSync()) cacheDir.createSync(recursive: true);
  final localFile = File('${cacheDir.path}/$audioFileName');

  // 4️⃣ Instant playback if cached
  if (await localFile.exists()) return localFile.path;

  // 5️⃣ Load index for fast lookup
  final index = await _loadOrCreateObbIndex(obbPath);
  final archivePath = index[audioFileName];
  if (archivePath == null) return null;

  // 6️⃣ Offload extraction to background isolate
  final extracted = await compute(_extractAudioFromObb, {
    'obbPath': obbPath,
    'archivePath': archivePath,
  });

  if (extracted != null) {
    await localFile.writeAsBytes(extracted, flush: true);
    return localFile.path;
  }

  return null;
}

// ============================================================
//  Background extractor – runs in isolate
// ============================================================

Future<Uint8List?> _extractAudioFromObb(Map<String, dynamic> args) async {
  final obbPath = args['obbPath'] as String;
  final archivePath = args['archivePath'] as String;

  // Use buffered reading for better performance
  final input = InputFileStream(obbPath, bufferSize: 65536); // 64KB buffer for faster reading
  final archive = ZipDecoder().decodeBuffer(input, verify: false); // Skip verification for speed

  for (final file in archive) {
    if (file.isFile && file.name == archivePath) {
      // Create a pre-allocated buffer for better memory efficiency
      final content = file.content as List<int>;
      final buffer = Uint8List(content.length);
      buffer.setAll(0, content);
      return buffer;
    }
  }
  return null;
}

// ============================================================
//  Preload index at startup (optional)
// ============================================================

Future<void> preloadObbIndex() async {
  const obbPath =
      '/sdcard/Android/obb/com.example.lecture_app/main.1.com.example.lecture_app.obb';
  final obbFile = File(obbPath);
  if (obbFile.existsSync()) {
    await _loadOrCreateObbIndex(obbPath);
  }
}
