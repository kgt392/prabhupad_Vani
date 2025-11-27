import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'models/lecture.dart';
import 'data/all_lectures.dart';
import 'external_storage_audio_helper.dart';
import 'audio_manager.dart';
import 'widgets/mini_player.dart';

class LectureDetailPage extends StatefulWidget {
  final Lecture lecture;
  final String? obbAudioPath; // path to audio from OBB

  const LectureDetailPage({
    super.key,
    required this.lecture,
    this.obbAudioPath,
  });

  @override
  State<LectureDetailPage> createState() => _LectureDetailPageState();
}

class _LectureDetailPageState extends State<LectureDetailPage> {
  AudioPlayer get _player => AudioManager.instance.player;
  bool _loading = true;
  bool _error = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _playing = false;
  late Lecture _currentLecture;
  String? _currentObbPath;

  @override
  void initState() {
    super.initState();
    // shared player managed by AudioManager
    _currentLecture = widget.lecture;
    _currentObbPath = widget.obbAudioPath;
    _initAudio();

    // Listen to position and state updates
    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _player.playerStateStream.listen((state) {
      if (mounted) setState(() => _playing = state.playing);
      // when playback completes, attempt to autoplay next
      if (state.processingState == ProcessingState.completed) {
        _onPlaybackComplete();
      }
    });
    _player.durationStream.listen((dur) {
      if (mounted) setState(() => _duration = dur ?? Duration.zero);
    });
  }

  Future<void> _initAudio() async {
    try {
      Duration? loadedDuration;

      // Try to get audio from external storage first
      String? externalPath;
      try {
        final audioPath = _currentLecture.audioPath;
        final parts = audioPath.split('/');
        if (parts.length >= 2) {
          final bookFolder = parts[parts.length - 2];
          final fileName = parts.last;
          final file = await ExternalStorageAudioHelper.getAudioFile(
            bookFolder,
            fileName,
          );
          if (file != null) {
            externalPath = file.path;
          }
        }
      } catch (e) {
        print('Error accessing external storage: $e');
      }

      if (externalPath != null) {
        loadedDuration = await _player.setFilePath(externalPath);
      } else {
        // Fallback to asset if external file not found
        loadedDuration = await _player.setAsset(_currentLecture.audioPath);
      }

      // Update metadata for mini player
      AudioManager.instance.setMetadata(
        title: _currentLecture.title,
        subtitle: _currentLecture.book,
      );
      AudioManager.instance.setCurrentLectureId(_currentLecture.id);

      if (mounted)
        setState(() {
          _duration = loadedDuration ?? Duration.zero;
          _position = Duration.zero;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = true;
        });
      print('Audio init error: $e');
    }
  }

  @override
  void dispose() {
    // Do not dispose the shared player here; AudioManager owns it.
    super.dispose();
  }

  Future<void> _onPlaybackComplete() async {
    // small debounce
    await Future.delayed(const Duration(milliseconds: 150));
    await _playNextIfAvailable();
  }

  Future<void> _playNextIfAvailable() async {
    try {
      final idx = allLecturesData.indexWhere((l) => l.id == _currentLecture.id);
      if (idx == -1) return;
      final nextIdx = idx + 1;
      if (nextIdx >= allLecturesData.length) return;

      final nextLecture = allLecturesData[nextIdx];
      setState(() {
        _loading = true;
        _error = false;
      });

      // try to get external storage path for next lecture
      String? externalPath;
      try {
        final audioPath = nextLecture.audioPath;
        final parts = audioPath.split('/');
        if (parts.length >= 2) {
          final bookFolder = parts[parts.length - 2];
          final fileName = parts.last;
          final file = await ExternalStorageAudioHelper.getAudioFile(
            bookFolder,
            fileName,
          );
          if (file != null) {
            externalPath = file.path;
          }
        }
      } catch (e) {
        externalPath = null;
      }

      await _player.stop();
      Duration? loadedDuration;
      if (externalPath != null) {
        loadedDuration = await _player.setFilePath(externalPath);
      } else {
        // Fallback to asset if external file not found
        loadedDuration = await _player.setAsset(nextLecture.audioPath);
      }

      if (mounted)
        setState(() {
          _currentLecture = nextLecture;
          _currentObbPath = externalPath;
          _duration = loadedDuration ?? Duration.zero;
          _position = Duration.zero;
          _loading = false;
          _error = loadedDuration == null;
        });

      // Update metadata for mini player when autoplay advances
      AudioManager.instance.setMetadata(
        title: nextLecture.title,
        subtitle: nextLecture.book,
      );
      AudioManager.instance.setCurrentLectureId(nextLecture.id);

      await _player.play();
    } catch (e) {
      print('Autoplay next error: $e');
      if (mounted)
        setState(() {
          _loading = false;
          _error = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentLecture.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Book: ${_currentLecture.book}",
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              "Date: ${_currentLecture.date}",
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              "Location: ${_currentLecture.location}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error
                    ? const Center(
                        child: Text(
                          "Audio not found",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Slider for position
                          Slider(
                            min: 0,
                            max: _duration.inSeconds.toDouble().clamp(
                              1,
                              double.infinity,
                            ),
                            value: _position.inSeconds
                                .clamp(0, _duration.inSeconds)
                                .toDouble(),
                            onChanged: (val) =>
                                _player.seek(Duration(seconds: val.toInt())),
                            activeColor: Colors.deepOrange,
                            thumbColor: Colors.deepOrangeAccent,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(_position)),
                              Text(_formatDuration(_duration)),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Play / Pause and Seek +/-10s
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.replay_10,
                                  size: 40,
                                  color: Colors.deepOrange,
                                ),
                                tooltip: '-10 seconds',
                                onPressed: () {
                                  final newPos =
                                      _position - const Duration(seconds: 10);
                                  _player.seek(
                                    newPos < Duration.zero
                                        ? Duration.zero
                                        : newPos,
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: Icon(
                                  _playing
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  size: 60,
                                  color: Colors.deepOrange,
                                ),
                                onPressed: () =>
                                    _playing ? _player.pause() : _player.play(),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.forward_10,
                                  size: 40,
                                  color: Colors.deepOrange,
                                ),
                                tooltip: '+10 seconds',
                                onPressed: () {
                                  final newPos =
                                      _position + const Duration(seconds: 10);
                                  _player.seek(
                                    newPos > _duration ? _duration : newPos,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Transcript here", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      bottomNavigationBar: AudioManager.instance.currentLectureId.value != null
          ? const MiniPlayer()
          : null,
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }
}
