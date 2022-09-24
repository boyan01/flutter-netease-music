import 'dart:async';

import 'package:hive/hive.dart';
import 'package:mixin_logger/mixin_logger.dart';

import 'data/playlist_detail.dart';
import 'data/track.dart';

LocalData neteaseLocalData = LocalData._();

const String _playHistoryKey = 'play_history';

class LocalData {
  LocalData._();

  final _box = Hive.openBox('local_data');

  FutureOr operator [](dynamic key) async {
    return get(key);
  }

  void operator []=(dynamic key, dynamic value) {
    _put(value, key);
  }

  Future<T?> get<T>(dynamic key) async {
    final box = await _box;
    try {
      return box.get(key) as T?;
    } catch (error, stackTrace) {
      e('get $key error: $error\n$stackTrace');
    }
  }

  Future _put(dynamic value, [dynamic key]) async {
    final box = await _box;
    try {
      await box.put(key, value);
    } catch (error, stacktrace) {
      e('LocalData put error: $error\n$stacktrace');
    }
  }

  Future<PlaylistDetail?> getPlaylistDetail(int playlistId) async {
    final data = await get<Map<String, dynamic>>('playlist_detail_$playlistId');
    if (data == null) {
      return null;
    }
    try {
      return PlaylistDetail.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  //TODO 添加分页加载逻辑
  Future<void> updatePlaylistDetail(PlaylistDetail playlistDetail) {
    return _put(
      playlistDetail.toJson(),
      'playlist_detail_${playlistDetail.id}',
    );
  }

  Future<List<Track>> getPlayHistory() async {
    final data = await get<List<Map<String, dynamic>>>(_playHistoryKey);
    if (data == null) {
      return const [];
    }
    final result =
        data.cast<Map<String, dynamic>>().map(Track.fromJson).toList();
    return result;
  }

  Future<void> updatePlayHistory(List<Track> list) {
    return _put(list.map((t) => t.toJson()).toList(), _playHistoryKey);
  }
}
