import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../repository.dart';

final playlistDetailProvider = StreamProvider.family<PlaylistDetail, int>(
  (ref, playlistId) async* {
    final local = await neteaseLocalData.getPlaylistDetail(playlistId);
    if (local != null) {
      yield local;
    }
    final ret = await neteaseRepository!.playlistDetail(playlistId);
    var detail = await ret.asFuture;

    if (detail.tracks.length != detail.tracks.length) {
      final trackIds = detail.trackIds.toSet();

      for (final track in detail.tracks) {
        trackIds.remove(track.id);
      }
      assert(trackIds.isNotEmpty, 'trackIds is empty. but trackCount is not.');
      final musics = await neteaseRepository!.songDetails(detail.trackIds);
      if (musics.isValue) {
        detail = detail.copyWith(tracks: musics.asValue!.value);
      }
    }
    await neteaseLocalData.updatePlaylistDetail(detail);
    yield detail;
  },
);
