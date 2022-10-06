import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository.dart';

final userPlaylistsProvider = FutureProvider.family<List<PlaylistDetail>, int>(
  (ref, userId) async {
    final result = await neteaseRepository!.userPlaylist(userId);
    return result.asFuture;
  },
);

class _UserPlaylistStateNotifier
    extends StateNotifier<AsyncValue<List<PlaylistDetail>>> {
  _UserPlaylistStateNotifier(this.userId) : super(const AsyncValue.loading()) {
    _load();
  }

  final int userId;

  final List<PlaylistDetail> _data = [];

  var _isLoading = false;

  Future<void> _load() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    try {
      final result = await neteaseRepository!.userPlaylist(userId);
      final data = await result.asFuture;
      _data.addAll(data);
      state = AsyncValue.data(data.toList());
    } catch (error, stacktrace) {
      if (_data.isEmpty) {
        state = AsyncValue.error(error, stacktrace);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() => _load();

  Future<void> add(PlaylistDetail playlist) async {
    _data.add(playlist);
    state = AsyncValue.data(_data.toList());
  }

  Future<void> remove(PlaylistDetail playlist) async {
    _data.remove(playlist);
    state = AsyncValue.data(_data.toList());
  }

  Future<void> subscribe(PlaylistDetail playlist) async {
    _data.add(playlist);
    state = AsyncValue.data(_data.toList());
  }

  Future<void> unsubscribe(PlaylistDetail playlist) async {
    _data.remove(playlist);
    state = AsyncValue.data(_data.toList());
  }
}
