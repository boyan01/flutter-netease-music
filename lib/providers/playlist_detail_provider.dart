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

    if (local != null && detail.trackUpdateTime == local.trackUpdateTime) {
      detail = detail.copyWith(tracks: local.tracks);
    } else if (detail.tracks.length != detail.trackCount) {
      final musics = await neteaseRepository!.songDetails(detail.trackIds);
      if (musics.isValue) {
        detail = detail.copyWith(tracks: musics.asValue!.value);
      }
    }
    await neteaseLocalData.updatePlaylistDetail(detail);
    yield detail;
  },
);
