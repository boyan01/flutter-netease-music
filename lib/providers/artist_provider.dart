import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/repository.dart';

final artistProvider = FutureProvider.family<ArtistDetail, int>(
  (ref, albumId) async {
    final result = await neteaseRepository!.artist(albumId);
    final album = await result.asFuture;
    return album;
  },
);
