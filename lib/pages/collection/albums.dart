import 'package:flutter/material.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/part/part.dart';
import 'api.dart';

class CollectionAlbums extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CachedLoader<Map>(
      cacheKey: 'album_sublist',
      loadTask: MyCollectionApi.of(context).getAlbums,
      builder: (context, result) {
        final data = result['data'] as List;
        return ListView(
          children: data
              .cast<Map>()
              .map((album) =>
                  AlbumTile(album: album, subtitle: _getAlbumSubtitle))
              .toList(),
        );
      },
    );
  }

  String _getAlbumSubtitle(Map album) {
    String artists = (album['artists'] as List)
        .cast<Map>()
        .map((artist) => artist['name'])
        .join('/');
    return '$artists ${album['size']}首';
  }
}
