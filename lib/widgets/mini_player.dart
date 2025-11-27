import 'package:flutter/material.dart';
import '../audio_manager.dart';

/// Compact MiniPlayer used only inside LectureDetailPage as bottomNavigationBar.
class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  final manager = AudioManager.instance;

  Duration _position = Duration.zero;
  Duration _duration = Duration(seconds: 1);
  bool _isPlaying = false;

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    manager.player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    manager.player.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration(seconds: 1));
    });
    manager.player.playerStateStream.listen((ps) {
      if (mounted) setState(() => _isPlaying = ps.playing);
    });

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
    // If there's no current lecture metadata, don't show anything.
    if (manager.currentLectureId.value == null) return const SizedBox.shrink();

    final pos = _position;
    final dur = _duration.inSeconds == 0
        ? const Duration(seconds: 1)
        : _duration;
    final value = dur.inSeconds == 0
        ? 0.0
        : (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0);

    return Material(
      elevation: 8,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title and book name on the left
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manager.currentTitle.value ?? 'Playing',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if ((manager.currentSubtitle.value ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          manager.currentSubtitle.value ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.deepOrange,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatDuration(pos),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Expanded(child: Container()),
                        Text(
                          _formatDuration(dur),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right column: play/pause (and optional resume), shifted slightly above
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (manager.player.audioSource == null &&
                          manager.currentLectureId.value != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.deepOrange,
                            ),
                            tooltip: 'Resume last session',
                            onPressed: () async {
                              try {
                                final ok = await manager
                                    .restoreLastSessionIfRequested();
                                if (ok) await manager.play();
                              } catch (e) {}
                            },
                          ),
                        ),
                      IconButton(
                        padding: EdgeInsets.only(bottom: 8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                          color: Colors.deepOrange,
                        ),
                        onPressed: () async {
                          try {
                            if (_isPlaying) {
                              await manager.pause();
                            } else {
                              await manager.play();
                            }
                          } catch (e) {}
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
