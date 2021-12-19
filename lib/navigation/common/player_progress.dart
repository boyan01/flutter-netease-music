import 'package:flutter/material.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/material/player/progress_track_container.dart';
import 'package:quiet/part/part.dart';

/// A seek bar for current position.
class DurationProgressBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DurationProgressBarState();
}

class DurationProgressBarState extends State<DurationProgressBar> {
  bool isUserTracking = false;

  double trackingPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    return ProgressTrackingContainer(builder: _buildBar);
  }

  Widget _buildBar(BuildContext context) {
    final theme = Theme.of(context).primaryTextTheme;
    final state = context.watchPlayerValue;

    Widget progressIndicator;

    String? durationText;
    String? positionText;

    if (state.initialized) {
      final duration = context.player.duration!.inMilliseconds;

      final position = isUserTracking
          ? trackingPosition.round()
          : context.player.position!.inMilliseconds;

      durationText = getTimeStamp(duration);
      positionText = getTimeStamp(position);

      //TODO add buffer progress
//      int maxBuffering = state.state.playbackState.bufferedPosition;

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
//          LinearProgressIndicator(
//            value: maxBuffering / duration,
//            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
//            backgroundColor: Colors.white12,
//          ),
          Slider(
            value: position.toDouble().clamp(0.0, duration.toDouble()),
            activeColor: theme.bodyText2!.color!.withOpacity(0.75),
            inactiveColor: theme.caption!.color!.withOpacity(0.3),
            max: duration.toDouble(),
            semanticFormatterCallback: (value) => getTimeStamp(value.round()),
            onChangeStart: (value) {
              setState(() {
                isUserTracking = true;
                trackingPosition = value;
              });
            },
            onChanged: (value) {
              setState(() {
                trackingPosition = value;
              });
            },
            onChangeEnd: (value) async {
              isUserTracking = false;
              context.player
                ..seekTo(Duration(milliseconds: value.round()))
                ..play();
            },
          ),
        ],
      );
    } else {
      //a disable slider if media is not available
      progressIndicator = Slider(value: 0, onChanged: (_) => {});
    }

    return SliderTheme(
      data: const SliderThemeData(
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        showValueIndicator: ShowValueIndicator.always,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            Text(positionText ?? "00:00", style: theme.bodyText2),
            const Padding(padding: EdgeInsets.only(left: 4)),
            Expanded(
              child: progressIndicator,
            ),
            const Padding(padding: EdgeInsets.only(left: 4)),
            Text(durationText ?? "00:00", style: theme.bodyText2),
          ],
        ),
      ),
    );
  }
}
