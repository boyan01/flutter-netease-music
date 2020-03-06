import 'package:flutter/material.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/material/playing_indicator.dart';
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
    return ProgressTrackContainer(builder: _buildBar);
  }

  Widget _buildBar(BuildContext context) {
    var theme = Theme.of(context).primaryTextTheme;
    var state = context.playbackState;

    Widget progressIndicator;

    String durationText;
    String positionText;

    if (state.initialized) {
      var duration = context.playerValue.metadata.duration ?? 0;

      var position = isUserTracking ? trackingPosition.round() : state.positionWithOffset;

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
            min: 0.0,
            activeColor: theme.bodyText2.color.withOpacity(0.75),
            inactiveColor: theme.caption.color.withOpacity(0.3),
            max: duration.toDouble(),
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
              context.transportControls
                ..seekTo(value.round())
                ..play();
            },
          ),
        ],
      );
    } else {
      //a disable slider if media is not available
      progressIndicator = Slider(value: 0, onChanged: (_) => {});
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        children: <Widget>[
          Text(positionText ?? "00:00", style: theme.bodyText2),
          Padding(padding: EdgeInsets.only(left: 4)),
          Expanded(
            child: progressIndicator,
          ),
          Padding(padding: EdgeInsets.only(left: 4)),
          Text(durationText ?? "00:00", style: theme.bodyText2),
        ],
      ),
    );
  }
}
