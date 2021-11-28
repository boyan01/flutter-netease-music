import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:quiet/repository.dart';

AsyncSnapshot<PlaylistDetail> usePlaylistDetail(
  int playlistId, {
  PlaylistDetail? preview,
}) {
  final playlist = useStream(useMemoized(() async* {
    if (preview != null) {
      yield preview;
    }
    final local = await neteaseLocalData.getPlaylistDetail(playlistId);
    if (local != null) {
      yield local;
    }

    final detailResult = await neteaseRepository!.playlistDetail(playlistId);
    var detail = detailResult.asValue?.value;
    if (detail != null) {
      if (local != null && detail.trackUpdateTime == local.trackUpdateTime) {
        detail = detail.copyWith(tracks: local.tracks);
      } else if (detail.tracks.length != detail.trackCount) {
        final musics = await neteaseRepository!.songDetails(detail.trackIds);
        if (musics.isValue) {
          detail = detail.copyWith(tracks: musics.asValue!.value);
        }
      }
      neteaseLocalData.updatePlaylistDetail(detail);
      yield detail;
    }
  }, [playlistId]));

  return playlist;
}
