import 'package:async/async.dart';
import 'package:flutter/material.dart';
import '../../navigation/mobile/artists/page_artist_detail.dart';
import '../../repository.dart';

import '../../component/netease/netease_loader.dart';

class CollectionArtists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CachedLoader<Map>(
        loadTask: () => Future.value(Result.error('unimplemented')),
        builder: (context, result) {
          final data = result['data'] as List;
          return ListView(
              children: ListTile.divideTiles(
                  context: context,
                  tiles: data.cast<Map>().map((artist) => ListTile(
                        leading: SizedBox(
                          height: 48,
                          width: 48,
                          child: Image(image: CachedImage(artist['img1v1Url'])),
                        ),
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
