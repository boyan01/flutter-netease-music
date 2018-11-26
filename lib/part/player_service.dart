import 'package:flutter/services.dart';
import 'package:quiet/model/model.dart';

const MethodChannel _channel = const MethodChannel('tech.soit.quiet/player');

MusicPlayer quiet = MusicPlayer._private();

typedef MusicChangeCallback = void Function(Music);

class MusicPlayer {
  MusicPlayer._private();

  ///current playing music list
  List<Music> get playlist => _playlist;

  List<Music> _playlist;

  ///current playing music
  Music get current => _current;
  Music _current;

  List<MusicChangeCallback> musicChangeCallbacks = [];

  ///play music
  ///if param is null, play current music
  ///if param music is null , current is null , do nothing
  Future<bool> play({Music music}) async {
    music ??= current;
    if (music == null) {
      return false;
    }
    assert(
        music.url != null && music.url.isNotEmpty, "music url can not be null");
    var data = {
      'title': music.title,
      'subTitle': music.subTitle,
      'imageUrl': music.album.coverImageUrl,
      'playUrl': music.url
    };

    var success = await _channel.invokeMethod("play", data);
    if (success) {
      _current = music;
      musicChangeCallbacks.forEach((f) => f(current));
    }

    return success;
  }

  Future<bool> pause() async {
    await _channel.invokeMethod("pause");
    return true;
  }

  void playNext() {
    //TODO
  }

  void playPrevious() {

  }

  Future<bool> setVolume(double volume) async {
    var success = await _channel.invokeMethod("volume", volume);
    return success;
  }

  void addMusicChangeListener(MusicChangeCallback callback) {
    musicChangeCallbacks.add(callback);
    callback(current);
  }

  void removeMusicChangeListener(MusicChangeCallback callback) {
    musicChangeCallbacks.remove(callback);
  }
}

enum PlayerState { playing, buffering, pause, idle }
