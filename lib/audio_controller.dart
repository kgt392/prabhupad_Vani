import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'external_storage_audio_helper.dart';

class AudioController extends ChangeNotifier {
  AudioController._internal();
  static final AudioController instance = AudioController._internal();

  final AudioPlayer _player = AudioPlayer();
  String? _currentId;
  String? _currentTitle;
  String? _currentPath; // stored as relative key for OBB
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _initialized = false;
  // persisted values read at startup but NOT applied automatically. These
  // are available for an explicit restore action by the user.
  String? _persistedId;
  String? _persistedTitle;
  String? _persistedPath;
  Duration _persistedPosition = Duration.zero;

  static const _kKeyId = 'audio.current.id';
  static const _kKeyTitle = 'audio.current.title';
  static const _kKeyPath = 'audio.current.path';
  static const _kKeyPos = 'audio.current.position';

  String? get currentId => _currentId;
  String? get currentTitle => _currentTitle;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _player.playing;

  String _toRelativeKey(String input) {
    // Accept existing values like 'assets/audio/...' or already relative 'audio/...'
    var s = input;
    if (s.startsWith('assets/')) {
      s = s.substring('assets/'.length);
    }
    // Normalize leading slashes
    if (s.startsWith('/')) s = s.substring(1);
    return s;
  }

  Future<String?> _resolveFromStorage(String relativeKey) async {
    try {
      // The relativeKey format is "bookFolder/fileName.mp3"
      final parts = relativeKey.split('/');
      if (parts.length != 2) {
        print('❌ AudioController: Invalid relative key format: $relativeKey');
        return null;
      }
      final bookFolder = parts[0];
      final fileName = parts[1];

      // Check if file exists in external storage
      final file = await ExternalStorageAudioHelper.getAudioFile(
        bookFolder,
        fileName,
      );
      if (file != null) {
        print('✅ AudioController: Found audio file: ${file.path}');
        return file.path;
      }
      print('❌ AudioController: Audio file not found: $relativeKey');
      return null;
    } catch (e) {
      print('❌ AudioController: Error resolving audio path: $e');
      return null;
    }
  }

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    // Listen to player streams
    _player.positionStream.listen((pos) {
      _position = pos;
      _persistPosition();
      notifyListeners();
    });
    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });
    _player.playerStateStream.listen((_) => notifyListeners());

    // Restore last session
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kKeyId);
    final title = prefs.getString(_kKeyTitle);
    final relKey = prefs.getString(_kKeyPath);
    final posSeconds = prefs.getInt(_kKeyPos);
    // Do NOT automatically restore or preload the previous audio on startup.
    // Store the persisted values so they can be restored on-demand.
    if (id != null && relKey != null) {
      _persistedId = id;
      _persistedTitle = title;
      _persistedPath = relKey;
      if (posSeconds != null)
        _persistedPosition = Duration(seconds: posSeconds);
    }
  }

  Future<void> _persistPosition() async {
    if (_currentId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kKeyPos, _position.inSeconds);
  }

  Future<void> _persistCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKeyId, _currentId!);
    await prefs.setString(_kKeyTitle, _currentTitle ?? '');
    if (_currentPath != null) {
      await prefs.setString(_kKeyPath, _currentPath!);
    }
  }

  /// Restore the last persisted session into the player without starting
  /// playback. Returns true if a persisted session was applied.
  Future<bool> restoreLastSessionIfRequested() async {
    if (_persistedId == null || _persistedPath == null) return false;
    try {
      final resolved = await _resolveFromStorage(_persistedPath!);
      if (resolved != null) {
        await _player.setFilePath(resolved);
        if (_persistedPosition > Duration.zero) {
          await _player.seek(_persistedPosition);
        }
        _currentId = _persistedId;
        _currentTitle = _persistedTitle;
        _currentPath = _persistedPath;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> play(String id, String title, String pathOrKey) async {
    try {
      await ensureInitialized();
      if (_currentId == id && isPlaying) {
        await _player.pause();
        return;
      }
      _currentId = id;
      _currentTitle = title;
      _currentPath = _toRelativeKey(pathOrKey);
      print(
        '🎵 AudioController: Playing audio - ID: $id, Title: $title, Path: $_currentPath',
      );
      final resolved = await _resolveFromStorage(_currentPath!);
      if (resolved == null) {
        print(
          '❌ AudioController: Audio not found in external storage: $_currentPath',
        );
        throw Exception('Audio not found in external storage: $_currentPath');
      }
      print('✅ AudioController: Setting audio file: $resolved');
      await _player.setFilePath(resolved);
      await _player.play();
      await _persistCurrent();
      notifyListeners();
      print('✅ AudioController: Audio playback started successfully');
    } catch (e) {
      print('❌ AudioController: Error playing audio: $e');
      rethrow;
    }
  }

  Future<void> toggle() async {
    await ensureInitialized();
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
}
