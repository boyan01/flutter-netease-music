import 'package:riverpod/riverpod.dart';

import '../repository.dart';

final homePlaylistProvider = FutureProvider((ref) async {
  final list = await neteaseRepository!.personalizedPlaylist(limit: 6);
  return list.asFuture;
});

final personalizedNewSongProvider = FutureProvider((ref) async {
  final list = await neteaseRepository!.personalizedNewSong();
  return list.asFuture;
});
