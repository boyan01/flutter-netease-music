import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:quiet/model/model.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

class FavoriteMusicList extends Model {
  final _log = Logger("runBackgroundService");

  FavoriteMusicList(UserAccount account) {
    int userId = 0;

    void listener() {
      if (account.isLogin && account.userId != userId) {
        userId = account.userId;
        _loadUserLikedList(userId);
      } else if (!account.isLogin) {
        userId = 0;
        _ids = const [];
        notifyListeners();
      }
    }

    account.addListener(listener);
    listener();
  }

  void _loadUserLikedList(int userId) async {
    _log.info("_loadUserLikedList $userId");
    _ids = (await neteaseLocalData['likedSongList'] as List)?.cast() ?? const [];
    _log.info("favorite list: $ids");
    notifyListeners();
    final result = await neteaseRepository.likedList(userId);
    if (result.isValue) {
      _ids = result.asValue.value;
      notifyListeners();
      neteaseLocalData['likedSongList'] = _ids;
    }
  }

  List<int> _ids = const [];

  List<int> get ids => _ids;

  static FavoriteMusicList of(BuildContext context, {bool rebuildOnChange = false}) {
    return Provider.of<FavoriteMusicList>(context, listen: rebuildOnChange);
  }

  static bool contain(BuildContext context, Music music) {
    final list = Provider.of<FavoriteMusicList>(context, listen: true);
    return list.ids?.contains(music.id) == true;
  }

  /// 红心歌曲
  Future<void> likeMusic(Music music) async {
    final succeed = await neteaseRepository.like(music.id, true);
    if (succeed) {
      _ids = List.from(_ids)..add(music.id);
      notifyListeners();
    }
  }

  ///取消红心歌曲
  Future<void> dislikeMusic(Music music) async {
    final succeed = await neteaseRepository.like(music.id, false);
    if (succeed) {
      _ids = List.from(_ids)..remove(music.id);
      notifyListeners();
    }
  }
}
