import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/navigator_provider.dart';
import '../image.dart';
import '../navigation_target.dart';

class AlbumTile extends ConsumerWidget {
  const AlbumTile({super.key, required this.album, this.subtitle});

  ///netease album json object
  final Map album;

  final String Function(Map album)? subtitle;

  String _defaultSubtitle(Map album) {
    final date = DateFormat('y.M.d')
        .format(DateTime.fromMillisecondsSinceEpoch(album['publishTime']));
    return "$date 歌曲 ${album["size"]}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = (this.subtitle ?? _defaultSubtitle)(album);
    return InkWell(
      onTap: () => ref
          .read(navigatorProvider.notifier)
          .navigate(NavigationTargetAlbumDetail(album['id'])),
      child: SizedBox(
        height: 64,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: AppImage(url: album['picUrl']),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 4)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Spacer(),
                  Text(album['name'], maxLines: 1),
                  const Spacer(),
                  Text(
                    subtitle,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  const Divider(height: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
