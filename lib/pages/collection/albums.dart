import 'package:flutter/material.dart';
import 'package:quiet/part/netease/netease_loader.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';

Future<Map> _getAlbums() {
  return neteaseRepository
      .doRequest('https://music.163.com/weapi/album/sublist', {
    'offset': 0,
    'total': true,
  });
}

class CollectionAlbums extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeteaseLoader<Map>(
      cacheKey: 'album_sublist',
      loadTask: _getAlbums,
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
