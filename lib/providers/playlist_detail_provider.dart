import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart';

import '../db/enum/key_value_group.dart';
import '../repository/data/playlist_detail.dart';
import '../repository/data/track.dart';
import '../repository/netease.dart';
import '../repository/network_repository.dart';
import '../utils/db/db_key_value.dart';
import 'database_provider.dart';
import 'key_value/account_provider.dart';

final playlistDetailProvider = StateNotifierProvider.family<
    PlaylistDetailStateNotifier, AsyncValue<PlaylistDetail>, int>(
  (ref, playlistId) => PlaylistDetailStateNotifier(
    playlistId: playlistId,
    ref: ref,
  ),
);

extension _PlaylistKeyValue on BaseLazyDbKeyValue {
  Future<PlaylistDetail?> getPlaylistDetail(int playlistId) async {
    final json = await get<Map<String, dynamic>>('playlist_detail_$playlistId');
    if (json == null) {
      return null;
    }
    return PlaylistDetail.fromJson(json);
  }

  Future<void> setPlaylistDetail(PlaylistDetail playlistDetail) async {
    await set('playlist_detail_${playlistDetail.id}', playlistDetail.toJson());
  }
}

final _playlistDetailKeyValueProvider = Provider(
  (ref) => BaseLazyDbKeyValue(
    group: KeyValueGroup.playlistDetail,
    dao: ref.watch(keyValueDaoProvider),
  ),
);

class PlaylistDetailStateNotifier
    extends StateNotifier<AsyncValue<PlaylistDetail>> {
  PlaylistDetailStateNotifier({
    required this.playlistId,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    _initializeLoad();
  }

  final int playlistId;
  final Ref ref;

  PlaylistDetail? _playlistDetail;

  BaseLazyDbKeyValue get _playlistDetailKeyValue =>
      ref.read(_playlistDetailKeyValueProvider);

  final _initializeCompleter = Completer();

  Future<void> _initializeLoad() async {
    assert(state is AsyncLoading, 'state is not AsyncLoading');
    final local = await _playlistDetailKeyValue.getPlaylistDetail(playlistId);
    if (local != null) {
      _playlistDetail = local;
      state = AsyncValue.data(local);
    }
    _initializeCompleter.complete();
    await _load();
  }

  var _isNetworkLoading = false;

  Future<void> _load() async {
    if (_isNetworkLoading) {
      return;
    }
    _isNetworkLoading = true;
    try {
      final result = await neteaseRepository!.playlistDetail(playlistId);
      var data = await result.asFuture;
      if (data.tracks.length != data.trackCount) {
        final trackIds = data.trackIds.toSet();

        for (final track in data.tracks) {
          trackIds.remove(track.id);
        }
        if (trackIds.isEmpty) {
          e('trackIds is empty. but trackCount is not. ${data.trackCount} ${data.tracks.length}');
        }
        final musics = await neteaseRepository!.songDetails(data.trackIds);
        if (musics.isValue) {
          data = data.copyWith(tracks: musics.asValue!.value);
        } else {
          e('load playlist detail failed. ${musics.asError!.error}');
        }
      }
      _playlistDetail = data;
      state = AsyncValue.data(data);
      await _playlistDetailKeyValue.setPlaylistDetail(data);
    } catch (error, stacktrace) {
      debugPrint('error: $error ,$stacktrace');
      if (state is! AsyncData) {
        state = AsyncValue.error(error, stacktrace);
      }
    } finally {
      _isNetworkLoading = false;
    }
  }

  Future<void> addTrack(List<Track> tracks) async {
    await _initializeCompleter.future;
    if (_playlistDetail == null) {
      return;
    }
    final userId = ref.read(userIdProvider);
    assert(userId == _playlistDetail!.creator.userId, 'userId is not match');

    final existed = _playlistDetail!.tracks.map((e) => e.id).toSet();
    final tracksToAdd = tracks.where((e) => !existed.contains(e.id)).toList();

    if (tracksToAdd.isEmpty) {
      d('tracksToAdd is empty');
      return;
    }

    final ids = tracksToAdd.map((e) => e.id).toList();
    final ret = await neteaseRepository!.playlistTracksEdit(
      PlaylistOperation.add,
      playlistId,
      ids,
    );
    if (!ret) {
      throw Exception('add track failed');
    }
    final detail = _playlistDetail!.copyWith(
      tracks: [...tracksToAdd, ..._playlistDetail!.tracks],
      trackIds: [...ids, ..._playlistDetail!.trackIds],
    );
    _playlistDetail = detail;
    await _playlistDetailKeyValue.setPlaylistDetail(detail);
    state = AsyncValue.data(detail);
  }

  Future<void> removeTrack(Track track) async {
    await _initializeCompleter.future;
    if (_playlistDetail == null) {
      return;
    }
    final userId = ref.read(userIdProvider);
    assert(userId == _playlistDetail!.creator.userId, 'userId is not match');
    final ret = await neteaseRepository!.playlistTracksEdit(
      PlaylistOperation.remove,
      playlistId,
      [track.id],
    );
    if (!ret) {
      throw Exception('add track failed');
    }
    final detail = _playlistDetail!.copyWith(
      tracks: _playlistDetail!.tracks.where((t) => t.id != track.id).toList(),
      trackIds: _playlistDetail!.trackIds.where((t) => t != track.id).toList(),
    );
    _playlistDetail = detail;
    await _playlistDetailKeyValue.setPlaylistDetail(detail);
    state = AsyncValue.data(detail);
  }
}
