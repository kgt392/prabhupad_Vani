import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class MiniPlayer extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final String title;
  final VoidCallback onTap;

  const MiniPlayer({
    Key? key,
    required this.audioPlayer,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        widget.audioPlayer.positionStream,
        widget.audioPlayer.bufferedPositionStream,
        widget.audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 120, // Increased height
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            // Progress bar and time
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData =
                    snapshot.data ??
                    PositionData(Duration.zero, Duration.zero, Duration.zero);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(positionData.position)),
                          Text(_formatDuration(positionData.duration)),
                        ],
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: Colors.white,
                        trackHeight: 2.0,
                      ),
                      child: Slider(
                        min: 0.0,
                        max: positionData.duration.inMilliseconds.toDouble(),
                        value: positionData.position.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          widget.audioPlayer.seek(
                            Duration(milliseconds: value.round()),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            // Controls and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white),
                    onPressed: () {
                      final position = widget.audioPlayer.position;
                      widget.audioPlayer.seek(
                        position - const Duration(seconds: 10),
                      );
                    },
                  ),
                  IconButton(
                    icon: StreamBuilder<PlayerState>(
                      stream: widget.audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;
                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return const CircularProgressIndicator();
                        } else if (playing != true) {
                          return const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          );
                        } else {
                          return const Icon(Icons.pause, color: Colors.white);
                        }
                      },
                    ),
                    onPressed: () {
                      if (widget.audioPlayer.playing) {
                        widget.audioPlayer.pause();
                      } else {
                        widget.audioPlayer.play();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                    onPressed: () {
                      final position = widget.audioPlayer.position;
                      widget.audioPlayer.seek(
                        position + const Duration(seconds: 10),
                      );
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
