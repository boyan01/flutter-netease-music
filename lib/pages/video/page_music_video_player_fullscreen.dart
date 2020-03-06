import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/part/part.dart';
import 'package:video_player/video_player.dart';

import 'video_controller.dart';
import 'video_player_model.dart';

///全屏播放界面
class FullScreenMvPlayer extends StatefulWidget {
  FullScreenMvPlayer({Key key}) : super(key: key);

  @override
  FullScreenMvPlayerState createState() {
    return new FullScreenMvPlayerState();
  }
}

class FullScreenMvPlayerState extends State<FullScreenMvPlayer> {
  @override
  void dispose() {
    super.dispose();
    //re enable System UI
    SystemChrome.setEnabledSystemUIOverlays(const [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    final value = VideoPlayerModel.of(context).playerValue;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
                aspectRatio: value.initialized ? value.aspectRatio : 1,
                child: VideoPlayer(VideoPlayerModel.of(context).videoPlayerController)),
          ),
          _FullScreenController(),
        ],
      ),
    );
  }
}

///控制页面
class _FullScreenController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedMvController(
      top: _buildTop(context),
      bottom: _buildBottom(context),
      center: MvPlayPauseButton(),
      beforeChange: (show) {
        if (show) {
          SystemChrome.setEnabledSystemUIOverlays(const [SystemUiOverlay.top, SystemUiOverlay.bottom]);
        }
      },
      afterChange: (show) {
        if (!show) {
          SystemChrome.setEnabledSystemUIOverlays(const []);
        }
      },
    );
  }

  Widget _buildTop(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: const [Colors.black87, Colors.black12])),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Text(VideoPlayerModel.of(context).data.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.thumb_up),
            onPressed: () => notImplemented(context),
          ),
          IconButton(
            icon: Icon(VideoPlayerModel.of(context).subscribed ? Icons.check_box : Icons.add_box),
            onPressed: () => subscribeOrUnSubscribeMv(context),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => notImplemented(context),
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => notImplemented(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    final value = VideoPlayerModel.of(context).playerValue;

    final position = value.position.inMilliseconds;
    final duration = value.duration?.inMilliseconds ?? 0;

    return Container(
      decoration: const BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: const [Colors.black12, Colors.black87])),
      child: DefaultTextStyle(
        style: Theme.of(context).primaryTextTheme.bodyText2,
        child: Row(
          children: <Widget>[
            Text(getTimeStamp(position)),
            Expanded(
              child: Slider(
                  value: position.clamp(0, duration).toDouble(),
                  max: duration.toDouble(),
                  onChanged: value.initialized
                      ? (v) {
                          VideoPlayerModel.of(context).videoPlayerController
                            ..seekTo(Duration(milliseconds: v.toInt()))
                            ..play();
                        }
                      : null),
            ),
            Text(getTimeStamp(duration)),
            SizedBox(width: 4),
            PopupMenuButton<String>(
                itemBuilder: (context) {
                  return VideoPlayerModel.of(context)
                      .imageResolutions
                      .map((str) => PopupMenuItem<String>(
                            value: str,
                            child: Container(child: Text('${str}P')),
                          ))
                      .toList();
                },
                onSelected: (v) => VideoPlayerModel.of(context).currentImageResolution = v,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Text('${VideoPlayerModel.of(context).currentImageResolution}P'),
                )),
            IconButton(
                icon: Icon(Icons.fullscreen_exit, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }
}
