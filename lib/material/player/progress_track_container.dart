import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:quiet/media/tracks/tracks_player.dart';

class ProgressTrackingContainer extends StatefulWidget {
  const ProgressTrackingContainer({
    Key? key,
    required this.builder,
    required this.player,
  }) : super(key: key);

  final TracksPlayer player;
  final WidgetBuilder builder;

  @override
  _ProgressTrackingContainerState createState() =>
      _ProgressTrackingContainerState();
}

class _ProgressTrackingContainerState extends State<ProgressTrackingContainer>
    with SingleTickerProviderStateMixin {
  late TracksPlayer _player;

  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _player = widget.player
      ..onPlaybackStateChanged.addListener(_onStateChanged);
    _ticker = createTicker((elapsed) {
      setState(() {});
    });
    _onStateChanged();
  }

  void _onStateChanged() {
    final needTrack = _player.isPlaying;
    if (_ticker.isActive == needTrack) return;
    if (_ticker.isActive) {
      _ticker.stop();
    } else {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _player.onPlaybackStateChanged.removeListener(_onStateChanged);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
