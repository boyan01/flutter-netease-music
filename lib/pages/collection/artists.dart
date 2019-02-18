import 'package:flutter/material.dart';
import 'package:quiet/pages/page_artist_detail.dart';
import 'package:quiet/part/netease/netease_loader.dart';
import 'package:quiet/repository/netease.dart';

import 'api.dart';

class CollectionArtists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeteaseLoader<Map>(
        loadTask: MyCollectionApi.of(context).getArtists,
        builder: (context, result) {
          final data = result['data'] as List;
          return ListView(
              children: ListTile.divideTiles(
                  context: context,
                  tiles: data.cast<Map>().map((artist) => ListTile(
                        leading: Container(
                            height: 48,
                            width: 48,
                            child: Image(
                                image: NeteaseImage(artist['img1v1Url']))),
                        title: Text(artist['name']),
                        subtitle: Text(
                            '专辑:${artist['albumSize']} MV:${artist['mvSize']}'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ArtistDetailPage(
                                      artistId: artist['id'])));
                        },
                      ))).toList());
        },
        cacheKey: 'artist_sublist');
  }
}
