import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository.dart';

final userPlaylistsProvider = FutureProvider.family<List<PlaylistDetail>, int>(
  (ref, userId) async {
    final result = await neteaseRepository!.userPlaylist(userId);
    return result.asFuture;
  },
);
