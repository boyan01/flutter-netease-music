import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/repository.dart';

final albumDetailProvider = FutureProvider.family<AlbumDetail, int>(
  (ref, albumId) async {
    final result = await neteaseRepository!.albumDetail(albumId);
    final album = await result.asFuture;
    return album;
  },
);
