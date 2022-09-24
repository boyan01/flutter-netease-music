import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mixin_logger/mixin_logger.dart';

import '../repository/data/playlist_detail.dart';
import '../repository/data/track.dart';
import '../repository/netease.dart';
import '../repository/network_repository.dart';
import 'account_provider.dart';

final playlistDetailProvider = StateNotifierProvider.family<
    PlaylistDetailStateNotifier, AsyncValue<PlaylistDetail>, int>(
  (ref, playlistId) => PlaylistDetailStateNotifier(
    playlistId: playlistId,
    read: ref.read,
  ),
);

class PlaylistDetailStateNotifier
    extends StateNotifier<AsyncValue<PlaylistDetail>> {
  PlaylistDetailStateNotifier({
    required this.playlistId,
    required this.read,
  }) : super(const AsyncValue.loading()) {
    _initializeLoad();
  }

  final int playlistId;
  final Reader read;
  late Box<PlaylistDetail> _playlistDetailBox;

  PlaylistDetail? _playlistDetail;

  final _initializeCompleter = Completer();

  Future<void> _initializeLoad() async {
    assert(state is AsyncLoading, 'state is not AsyncLoading');
    _playlistDetailBox = await Hive.openBox<PlaylistDetail>('playlistDetail');
    final local = _playlistDetailBox.get(playlistId.toString());
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
        }
      }
      _playlistDetail = data;
      await _playlistDetailBox.put(playlistId, data);
      state = AsyncValue.data(data);
    } catch (error, stacktrace) {
      debugPrint('error: $error ,$stacktrace');
      if (_playlistDetail == null) {
        state = AsyncValue.error(error, stackTrace: stacktrace);
      }
    } finally {
      _isNetworkLoading = false;
    }
  }

  Future<void> addTrack(Track track) async {
    await _initializeCompleter.future;
    if (_playlistDetail == null) {
      return;
    }
    final userId = read(userIdProvider);
    assert(userId == _playlistDetail!.creator.userId, 'userId is not match');

    final ret = await neteaseRepository!.playlistTracksEdit(
      PlaylistOperation.add,
      playlistId,
      [track.id],
    );
    if (!ret) {
      throw Exception('add track failed');
    }
    final detail = _playlistDetail!.copyWith(
      tracks: [track, ..._playlistDetail!.tracks],
      trackIds: [track.id, ..._playlistDetail!.trackIds],
    );
    _playlistDetail = detail;
    await _playlistDetailBox.put(playlistId, detail);
    state = AsyncValue.data(detail);
  }

  Future<void> removeTrack(Track track) async {
    await _initializeCompleter.future;
    if (_playlistDetail == null) {
      return;
    }
    final userId = read(userIdProvider);
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
    await _playlistDetailBox.put(playlistId, detail);
    state = AsyncValue.data(detail);
  }
}
