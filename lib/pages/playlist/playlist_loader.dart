import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:netease_api/src/ao/playlist_detail.dart';
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
    final detail = detailResult.asValue?.value;
    if (detail != null) {
      if (local != null && detail.trackUpdateTime == local.trackUpdateTime) {
        detail.musicList = local.musicList;
      } else if (detail.musicList.length != detail.trackIds.length) {
        final musics = await neteaseRepository!
            .songDetails(detail.trackIds.map((e) => e.id).toList());
        detail.musicList = musics;
      }
      neteaseLocalData.updatePlaylistDetail(detail);
      yield detail;
    }
  }, [playlistId]));

  return playlist;
}
