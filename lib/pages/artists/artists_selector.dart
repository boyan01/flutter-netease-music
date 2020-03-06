import 'package:flutter/material.dart';
import 'package:quiet/model/model.dart';

import 'page_artist_detail.dart';

///quick launch [ArtistDetailPage] if have more than one id
void launchArtistDetailPage(BuildContext context, List<Artist> artists) async {
  debugPrint("to artist :$artists");
  if (artists == null || artists.isEmpty) {
    return;
  }
  if (artists.length == 1) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ArtistDetailPage(artistId: artists[0].id);
    }));
  } else {
    final artist = await showDialog<Artist>(
        context: context,
        builder: (context) {
          return ArtistSelectionDialog(artists: artists);
        });
    if (artist != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return ArtistDetailPage(artistId: artist.id);
      }));
    }
  }
}

///歌手选择弹窗
///返回 [Artist]
class ArtistSelectionDialog extends StatelessWidget {
  final List<Artist> artists;

  const ArtistSelectionDialog({Key key, @required this.artists})
      : assert(artists != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = artists.map<Widget>((artist) {
      final enabled = artist.id != 0;
      return ListTile(
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(artist.name,
              style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(color: enabled ? null : Colors.grey))),
        ),
        enabled: enabled,
        onTap: () {
          Navigator.of(context).pop(artist);
        },
      );
    }).toList();

    return Center(
      child: Container(
        constraints: BoxConstraints(maxHeight: 356),
        child: SimpleDialog(
          title: Container(
            child: Text("请选择要查看的歌手"),
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.8),
          ),
          children: children,
        ),
      ),
    );
  }
}
