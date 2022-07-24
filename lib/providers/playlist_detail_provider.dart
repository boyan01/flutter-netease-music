import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../repository.dart';
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

  PlaylistDetail? _playlistDetail;

  final _initializeCompleter = Completer();

  Future<void> _initializeLoad() async {
    assert(state is AsyncLoading, 'state is not AsyncLoading');
    final local = await neteaseLocalData.getPlaylistDetail(playlistId);
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
      if (data.tracks.length != data.tracks.length) {
        final trackIds = data.trackIds.toSet();

        for (final track in data.tracks) {
          trackIds.remove(track.id);
        }
        assert(
          trackIds.isNotEmpty,
          'trackIds is empty. but trackCount is not.',
        );
        final musics = await neteaseRepository!.songDetails(data.trackIds);
        if (musics.isValue) {
          data = data.copyWith(tracks: musics.asValue!.value);
        }
      }
      _playlistDetail = data;
      await neteaseLocalData.updatePlaylistDetail(data);
      state = AsyncValue.data(data);
    } catch (error, stacktrace) {
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
    await neteaseLocalData.updatePlaylistDetail(detail);
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
    await neteaseLocalData.updatePlaylistDetail(detail);
    state = AsyncValue.data(detail);
  }
}
