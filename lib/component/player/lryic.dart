import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:music_player/music_player.dart';
import 'package:quiet/pages/player/lyric.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

///当前播放中的音乐的歌词
class PlayingLyric extends Model {
  PlayingLyric(MusicPlayer player) {
    player.addListener(() {
      _shouldLoadLyric(player.value.current);
    });
  }

  static PlayingLyric of(BuildContext context, {rebuildOnChange: true}) {
    return ScopedModel.of<PlayingLyric>(context, rebuildOnChange: rebuildOnChange);
  }

  CancelableOperation _lyricLoader;

  String _message = '暂无歌词';

  LyricContent _lyricContent;

  ///没有歌词时的提示
  ///与[lyric]互斥，当[lyric]为null时，[message]定不能为null
  String get message => _message;

  LyricContent get lyric => _lyricContent;

  bool get hasLyric => lyric != null && lyric.size > 0;

  Music _music;

  void _shouldLoadLyric(Music music) {
    if (_music == music) {
      return;
    }
    _music = music;
    _lyricLoader?.cancel();
    if (music == null) {
      _setLyric();
      return;
    }
    _lyricLoader = CancelableOperation<String>.fromFuture(neteaseRepository.lyric(music.id))
      ..value.then((lyric) {
        _setLyric(lyric: lyric);
      }, onError: (e) {
        _setLyric(message: e.toString());
      });
  }

  void _setLyric({String lyric, String message}) {
    assert(lyric == null || message == null);
    _message = message;
    if (lyric != null && lyric.isNotEmpty) {
      _lyricContent = LyricContent.from(lyric);
    } else {
      _lyricContent = null;
    }
    if (_lyricContent?.size == 0) {
      _lyricContent = null;
    }
    if (_lyricContent == null) {
      _message = '暂无歌词';
    }
    notifyListeners();
  }
}
