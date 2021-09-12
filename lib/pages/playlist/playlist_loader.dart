import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:quiet/model/playlist_detail.dart';
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
      neteaseLocalData.updatePlaylistDetail(detail);
      yield detail;
    }
  }, [playlistId]));

  return playlist;
}
