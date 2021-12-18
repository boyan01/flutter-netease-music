import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/repository.dart';

final userPlaylistsProvider = FutureProvider.family<List<PlaylistDetail>, int>(
  (ref, userId) async {
    final result = await neteaseRepository!.userPlaylist(userId);
    return result.asFuture;
  },
);
