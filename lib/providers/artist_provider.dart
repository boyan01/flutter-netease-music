import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository.dart';

final artistProvider = FutureProvider.family<ArtistDetail, int>(
  (ref, albumId) async {
    final result = await neteaseRepository!.artist(albumId);
    final album = await result.asFuture;
    return album;
  },
);

final artistAlbumsProvider = FutureProvider.family<List<AlbumDetail>, int>(
  (ref, artistId) async {
    final result = await neteaseRepository!.artistAlbums(artistId);
    final albums = await result.asFuture;

    final albumsList = <AlbumDetail>[];

    for (final album in albums) {
      final albumDetail = await neteaseRepository!.albumDetail(album.id);
      if (albumDetail.isValue) {
        albumsList.add(albumDetail.asValue!.value);
      }
    }
    return albumsList;
  },
);
