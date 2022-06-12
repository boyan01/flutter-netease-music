import 'package:flutter/material.dart';
import '../../../extension.dart';
import '../../../repository/data/track.dart';

///歌手选择弹窗
///返回 [ArtistMini]
class ArtistSelectionDialog extends StatelessWidget {
  const ArtistSelectionDialog({super.key, required this.artists});
  final List<ArtistMini> artists;

  @override
  Widget build(BuildContext context) {
    final children = artists.map<Widget>((artist) {
      final enabled = artist.id != 0;
      return ListTile(
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(artist.name,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .merge(TextStyle(color: enabled ? null : Colors.grey)),),
        ),
        enabled: enabled,
        onTap: () {
          Navigator.of(context).pop(artist);
        },
      );
    }).toList();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 356),
        child: SimpleDialog(
          title: Container(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Text(context.strings.selectTheArtist),
          ),
          children: children,
        ),
      ),
    );
  }
}
