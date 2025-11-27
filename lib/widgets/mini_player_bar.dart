import 'package:flutter/material.dart';
import '../audio_manager.dart';

class MiniPlayerBar extends StatefulWidget {
  const MiniPlayerBar({super.key});

  @override
  State<MiniPlayerBar> createState() => _MiniPlayerBarState();
}

class _MiniPlayerBarState extends State<MiniPlayerBar> {
  final manager = AudioManager.instance;

  Duration _position = Duration.zero;
  Duration _duration = Duration(seconds: 1);
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // audio manager already starts persistence in its constructor
    // listen to player streams to update UI
    manager.player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    manager.player.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration(seconds: 1));
    });
    manager.player.playerStateStream.listen((ps) {
      if (mounted) setState(() => _isPlaying = ps.playing);
    });

    // listen to metadata/value notifier changes
    manager.currentLectureId.addListener(_onMetaChange);
    manager.currentTitle.addListener(_onMetaChange);
  }

  @override
  void dispose() {
    manager.currentLectureId.removeListener(_onMetaChange);
    manager.currentTitle.removeListener(_onMetaChange);
    super.dispose();
  }

  void _onMetaChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (manager.currentLectureId.value == null) return const SizedBox.shrink();

    final pos = _position;
    final dur = _duration.inSeconds == 0
        ? const Duration(seconds: 1)
        : _duration;
    final value = (pos.inSeconds.clamp(0, dur.inSeconds)) / dur.inSeconds;

    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.deepOrange,
                ),
                onPressed: () async {
                  try {
                    if (_isPlaying) {
                      await manager.pause();
                    } else {
                      await manager.play();
                    }
                  } catch (e) {
                    // ignore
                  }
                },
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manager.currentTitle.value ?? 'Playing',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.deepOrange,
                      minHeight: 3,
                    ),
                  ],
                ),
              ),
              // If the player currently has no audio loaded but we have persisted
              // metadata (so the mini player is visible), show a small resume
              // button to restore the last session and start playback.
              if (manager.player.audioSource == null &&
                  manager.currentLectureId.value != null)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.deepOrange),
                  tooltip: 'Resume last session',
                  onPressed: () async {
                    try {
                      final ok = await manager.restoreLastSessionIfRequested();
                      if (ok) await manager.play();
                    } catch (e) {
                      // ignore
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
