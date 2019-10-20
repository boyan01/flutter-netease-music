import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:music_player/music_player.dart' as player;
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/player/lryic.dart';
import 'package:quiet/component/player/player_state.dart';
import 'package:quiet/model/model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:quiet/component/player/bottom_player_bar.dart';
export 'package:quiet/component/player/lryic.dart';

MusicPlayer quiet = MusicPlayer._private();

///key which save playing music to local preference
const String _PREF_KEY_PLAYING = "quiet_player_playing";

///key which save playing music list to local preference
const String _PREF_KEY_PLAYLIST = "quiet_player_playlist";

///key which save playing list token to local preference
const String _PREF_KEY_TOKEN = "quiet_player_token";

///key which save playing mode to local preference
const String _PREF_KEY_PLAY_MODE = "quiet_player_play_mode";

class MusicPlayer extends player.MusicPlayer {
  MusicPlayer._private() : super();

  @override
  void onInit(player.MusicPlayerState state) {
    super.onInit(state);
    if (state.queue.isNotEmpty) {
      return;
    }
    //load former player information from SharedPreference
    Future.microtask(() async {
      var preference = await SharedPreferences.getInstance();
      final playingMediaId = preference.getString(_PREF_KEY_PLAYING);
      final token = preference.getString(_PREF_KEY_TOKEN);
      final playingList = (json.decode(preference.get(_PREF_KEY_PLAYLIST)) as List)
          ?.cast<Map>()
          ?.map((e) => player.MediaMetadata.fromMap(e))
          ?.toList();
      final playMode = player.PlayMode.values[preference.getInt(_PREF_KEY_PLAY_MODE) ?? 0];
      setPlayList(playingList ?? const [], token);
      transportControls.setPlayMode(playMode);
      transportControls.prepareFromMediaId(playingMediaId);
      debugPrint("loaded : $playingMediaId");
      debugPrint("loaded : $playingList");
      debugPrint("loaded : $token");
      debugPrint("loaded : $playMode");
    }).catchError((e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
    });
  }

  @override
  void onMetadataChanged(player.MediaMetadata metadata) {
    super.onMetadataChanged(metadata);
    SharedPreferences.getInstance().then((preference) {
      preference.setString(_PREF_KEY_PLAYING, metadata?.mediaId);
    });
  }

  @override
  void notifyListeners() {
    compatValue = PlayerControllerState(value);
    super.notifyListeners();
  }

  @override
  void onQueueTitleChanged(String title) {
    super.onQueueTitleChanged(title);
    SharedPreferences.getInstance().then((preference) {
      preference.setString(_PREF_KEY_TOKEN, title);
    });
  }

  @override
  Future<void> setPlayList(List<player.MediaMetadata> list, String queueId, {String queueTitle}) async {
    await super.setPlayList(list, queueId, queueTitle: queueTitle);
    SharedPreferences.getInstance().then((preference) {
      preference.setString(_PREF_KEY_PLAYLIST, json.encode(list.map((e) => e.toMap()).toList()));
      preference.setString(_PREF_KEY_TOKEN, queueId);
    });
  }

  @override
  void onPlaybackStateChanged(player.PlaybackState playbackState) {
    super.onPlaybackStateChanged(playbackState);
    _persistPlayMode();
  }

  void _persistPlayMode() {
    SharedPreferences.getInstance().then((preference) {
      preference.setInt(_PREF_KEY_PLAY_MODE, compatValue.playMode.index);
    });
  }

  ///play a single song
  Future<void> play({Music music}) async {
    if (value.playbackState.state == player.PlaybackState.STATE_PAUSED) {
      transportControls.play();
      return;
    }
    music = music ?? compatValue.current;
    if (music == null) {
      //null music, null current playing, this is an error state
      return;
    }
    if (!compatValue.playingList.contains(music)) {
      //playing list do not contain music
      //so we insert this music to next of current playing
      await insertToNext(music);
    }
    transportControls.playFromMediaId(music.metadata.mediaId);
  }

  ///insert a music to [value.current] next position
  Future<void> insertToNext(Music music) {
    return insertToNext2([music]);
  }

  Future<void> insertToNext2(List<Music> list) async {
    //TODO
    debugPrint("TODO");
  }

  Future<void> removeFromPlayingList(Music music) async {
    //TODO
    debugPrint("TODO");
  }

  Future<void> playWithList(Music music, List<Music> list, String token, {String queueTitle}) async {
    debugPrint("playWithList ${list.map((m) => m.title).join(",")}");
    debugPrint("playWithList token = $token");
    assert(list != null && token != null);
    if (list.isEmpty) {
      return;
    }
    music ??= list.first;
    await setPlayList(list.map((l) => l.metadata).toList(), token, queueTitle: queueTitle);
    transportControls.playFromMediaId(music.metadata.mediaId);
  }

  Future<void> pause() async {
    transportControls.pause();
  }

  void quiet() {
    dispose();
  }

  Future<void> playNext() async {
    transportControls.skipToNext();
    transportControls.play();
  }

  Future<void> playPrevious() async {
    transportControls.skipToPrevious();
    transportControls.play();
  }

  ///might be null
  Future<Music> getNext() async {
    //TODO
    return null;
  }

  ///might be null
  Future<Music> getPrevious() async {
    //TODO
    return null;
  }

  /// Seek to position in milliseconds
  void seekTo(int position) {
    transportControls.seekTo(position);
  }

  ///change playlist play mode
  ///[PlayMode]
  void changePlayMode() {
    player.PlayMode next = player.PlayMode.values[(compatValue.playMode.index + 1) % 3];
    transportControls.setPlayMode(next);
  }

  PlayerControllerState compatValue = PlayerControllerState.uninitialized();
}

class Quiet extends StatefulWidget {
  Quiet({@Required() this.child, Key key}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _QuietState();
}

class _QuietState extends State<Quiet> {
  PlayerControllerState value;

  void _onPlayerChange() {
    setState(() {
      value = quiet.compatValue;
      if (value.hasError) {
        showSimpleNotification(Text("播放歌曲${value.current?.title ?? ""}失败!"),
            leading: Icon(Icons.error), background: Theme.of(context).errorColor);
      }
    });
  }

  @override
  void initState() {
    value = quiet.compatValue;
    quiet.addListener(_onPlayerChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    quiet.removeListener(_onPlayerChange);
    quiet.dispose();
  }

  final _playingLyric = PlayingLyric(quiet);

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: _playingLyric,
      child: PlayerState(
        child: widget.child,
        state: value,
      ),
    );
  }
}

class PlayerState extends InheritedWidget {
  final PlayerControllerState state;

  const PlayerState({
    Key key,
    @required this.state,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  static PlayerControllerState of(BuildContext context) {
    final widget = context.inheritFromWidgetOfExactType(PlayerState) as PlayerState;
    return widget.state;
  }

  @override
  bool updateShouldNotify(PlayerState old) {
    return old.state != state;
  }
}
