import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/all_lectures.dart';

// Keys used in SharedPreferences
const _kLastLectureId = 'lastLectureId';
const _kLastPositionSecs = 'lastPositionSecs';
const _kLastPlaying = 'lastPlaying';

class AudioManager with WidgetsBindingObserver {
  AudioManager._internal() {
    WidgetsBinding.instance.addObserver(this);
    // start persistence init (not awaited)
    _initPersistence();
    _setupErrorHandling();
  }

  static final AudioManager _instance = AudioManager._internal();

  static AudioManager get instance => _instance;

  final AudioPlayer player = AudioPlayer();

  // Additional state notifiers
  final ValueNotifier<bool> isBuffering = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Playback settings
  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  void _setupErrorHandling() {
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        isBuffering.value = true;
      } else {
        isBuffering.value = false;
      }
    });

    player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace stackTrace) {
        errorMessage.value = 'Error: ${e.toString()}';
      },
    );
  }

  // persisted state
  final ValueNotifier<String?> currentLectureId = ValueNotifier<String?>(null);
  Duration _lastPosition = Duration.zero;
  bool _lastPlaying = false;
  // last persisted values read from storage on startup. These are intentionally
  // not applied to the player automatically; they can be used later when the
  // user explicitly requests to resume playback.
  String? _persistedLectureId;

  DateTime _lastSavedAt = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _initPersistence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString(_kLastLectureId);
      final lastPosSecs = prefs.getDouble(_kLastPositionSecs) ?? 0.0;
      final lastPlaying = prefs.getBool(_kLastPlaying) ?? false;

      // Keep the last persisted values available. We will NOT automatically
      // load or start playback on app start. However, we DO set the persisted
      // metadata (lecture id/title/subtitle) so the mini-player is visible
      // when the user opens the app again (the player may be idle but the
      // UI shows the last lecture info). If the user wants to actually
      // resume audio playback, they can trigger restoreLastSessionIfRequested().
      _persistedLectureId = lastId;
      _lastPosition = Duration(seconds: lastPosSecs.toInt());
      _lastPlaying = lastPlaying;

      // Do NOT set currentLectureId on app start. Only set when user selects audio.

      // listen to position changes to persist periodically
      player.positionStream.listen((p) {
        _lastPosition = p;
        // throttle saves to once every 5 seconds
        if (DateTime.now().difference(_lastSavedAt).inSeconds >= 5) {
          _saveState();
        }
      });

      player.playerStateStream.listen((ps) {
        _lastPlaying = ps.playing;
        // save playing state occasionally
        if (DateTime.now().difference(_lastSavedAt).inSeconds >= 5) {
          _saveState();
        }
      });
    } catch (_) {}
  }

  /// Restore the last persisted lecture into the player without automatically
  /// starting playback. This is intended to be called only when the user
  /// explicitly wants to resume the previous session (for example, when they
  /// press a "Resume" button or tap Play). If no persisted lecture exists,
  /// the method returns false.
  Future<bool> restoreLastSessionIfRequested() async {
    if (_persistedLectureId == null) return false;
    try {
      final lecture = allLecturesData.firstWhere(
        (l) => l.id == _persistedLectureId,
      );
      if (lecture.audioPath.startsWith('assets/')) {
        await player.setAsset(lecture.audioPath);
      } else {
        await player.setFilePath(lecture.audioPath);
      }
      if (_lastPosition > Duration.zero) await player.seek(_lastPosition);

      currentLectureId.value = lecture.id;
      currentTitle.value = lecture.title;
      currentSubtitle.value = lecture.book;

      // Do not auto-play. Caller may call play() if desired.
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (currentLectureId.value != null) {
        await prefs.setString(_kLastLectureId, currentLectureId.value!);
      }
      await prefs.setDouble(
        _kLastPositionSecs,
        _lastPosition.inSeconds.toDouble(),
      );
      await prefs.setBool(_kLastPlaying, _lastPlaying);
      _lastSavedAt = DateTime.now();
    } catch (_) {}
  }

  // Optional metadata to show in the mini player
  final ValueNotifier<String?> currentTitle = ValueNotifier<String?>(null);
  final ValueNotifier<String?> currentSubtitle = ValueNotifier<String?>(null);

  Future<Duration?> setAsset(String asset) => player.setAsset(asset);
  Future<Duration?> setFilePath(String path) => player.setFilePath(path);

  /// Preload a lecture's audio (asset or file) without starting playback.
  /// Returns the loaded Duration if successful (may be null).
  Future<Duration?> preloadLecture(String audioPath, {String? filePath}) async {
    try {
      if (filePath != null) {
        return await player.setFilePath(filePath);
      }
      return await player.setAsset(audioPath);
    } catch (e) {
      return null;
    }
  }

  /// Convenience that sets metadata and currentLectureId when preloading.
  Future<Duration?> preloadLectureWithMeta({
    required String lectureId,
    required String audioPath,
    String? filePath,
    String? title,
    String? subtitle,
  }) async {
    final d = await preloadLecture(audioPath, filePath: filePath);
    currentLectureId.value = lectureId;
    currentTitle.value = title;
    currentSubtitle.value = subtitle;
    _saveState();
    return d;
  }

  Future<void> play() async {
    try {
      await player.play();
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = 'Failed to play: ${e.toString()}';
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await player.pause();
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = 'Failed to pause: ${e.toString()}';
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await player.stop();
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = 'Failed to stop: ${e.toString()}';
      rethrow;
    }
  }

  /// Seek forward by specified duration
  Future<void> seekForward([
    Duration duration = const Duration(seconds: 10),
  ]) async {
    try {
      final position = player.position;
      final newPosition = position + duration;
      await player.seek(newPosition);
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = 'Failed to seek: ${e.toString()}';
      rethrow;
    }
  }

  /// Seek backward by specified duration
  Future<void> seekBackward([
    Duration duration = const Duration(seconds: 10),
  ]) async {
    try {
      final position = player.position;
      final newPosition = position - duration;
      await player.seek(newPosition.isNegative ? Duration.zero : newPosition);
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = 'Failed to seek: ${e.toString()}';
      rethrow;
    }
  }

  /// Set playback speed (0.5x to 3.0x)
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      speed = speed.clamp(0.5, 3.0);
      await player.setSpeed(speed);
      _playbackSpeed = speed;
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = 'Failed to set speed: ${e.toString()}';
      rethrow;
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      volume = volume.clamp(0.0, 1.0);
      await player.setVolume(volume);
      errorMessage.value = null;
    } catch (e) {
      errorMessage.value = 'Failed to set volume: ${e.toString()}';
      rethrow;
    }
  }

  void setMetadata({String? title, String? subtitle}) {
    currentTitle.value = title;
    currentSubtitle.value = subtitle;
  }

  void setCurrentLectureId(String? id) {
    currentLectureId.value = id;
    // save immediately
    _saveState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Save state on lifecycle transitions to ensure persistence.
    try {
      _saveState();
    } catch (_) {}

    // Stop playback only when the app is detached (closed). Keep playback
    // running while the app is backgrounded or inactive so the mini player
    // remains visible during the app session.
    if (state == AppLifecycleState.detached) {
      try {
        player.stop();
      } catch (_) {}
    }
  }

  void dispose() {
    try {
      player.dispose();
    } catch (_) {}
    WidgetsBinding.instance.removeObserver(this);
  }
}
