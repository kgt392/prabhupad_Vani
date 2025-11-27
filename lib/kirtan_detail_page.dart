import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'models/kirtan.dart';
import 'external_storage_audio_helper.dart';
import 'audio_manager.dart';
import 'widgets/mini_player.dart';

class KirtanDetailPage extends StatefulWidget {
  final Kirtan kirtan;
  final String? obbAudioPath; // new optional parameter

  const KirtanDetailPage({super.key, required this.kirtan, this.obbAudioPath});

  @override
  State<KirtanDetailPage> createState() => _KirtanDetailPageState();
}

class _KirtanDetailPageState extends State<KirtanDetailPage> {
  AudioPlayer get _player => AudioManager.instance.player;
  bool _loading = false;
  bool _error = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _playing = false;
  late Kirtan _currentKirtan;
  String? _currentObbPath;

  @override
  void initState() {
    super.initState();
    _currentKirtan = widget.kirtan;
    _currentObbPath = widget.obbAudioPath;
    _initAudio();

    // Listen to position and state updates
    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _player.playerStateStream.listen((state) {
      if (mounted) setState(() => _playing = state.playing);
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
        final audioPath = _currentKirtan.audioPath;
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
        loadedDuration = await _player.setAsset(_currentKirtan.audioPath);
      }
      // Set metadata for mini player
      AudioManager.instance.setMetadata(
        title: _currentKirtan.title,
        subtitle: _currentKirtan.type,
      );
      AudioManager.instance.setCurrentLectureId(_currentKirtan.id);
      if (mounted)
        setState(() {
          _duration = loadedDuration ?? Duration.zero;
          _position = Duration.zero;
          _loading = false;
          _error = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = true;
        });
    }
  }

  @override
  void dispose() {
    // Do not dispose shared player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentKirtan.title),
        backgroundColor: Colors.purple.shade50,
        foregroundColor: Colors.purple.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kirtan Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Type: ${_currentKirtan.type}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_currentKirtan.date != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Date: ${_currentKirtan.date}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    if (_currentKirtan.location != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        "Location: ${_currentKirtan.location}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Main Audio Player UI
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error
                    ? const Center(
                        child: Text(
                          "Audio not found",
                          style: TextStyle(color: Colors.purple),
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
                            activeColor: Colors.purple.shade700,
                            thumbColor: Colors.purple,
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
                                  color: Colors.purple,
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
                                  color: Colors.purple.shade700,
                                ),
                                onPressed: () =>
                                    _playing ? _player.pause() : _player.play(),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.forward_10,
                                  size: 40,
                                  color: Colors.purple,
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
            const Text(
              "Kirtan Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "This is a ${_currentKirtan.type.toLowerCase()} by Srila Prabhupada. Enjoy the transcendental sound vibration.",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
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
