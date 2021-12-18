import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/repository.dart';

final playlistDetailProvider = FutureProvider.family<PlaylistDetail, int>(
  (ref, playlistId) async {
    final ret = await neteaseRepository!.playlistDetail(playlistId);
    return ret.asFuture;
  },
);
