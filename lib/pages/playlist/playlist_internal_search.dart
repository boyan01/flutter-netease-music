import 'package:flutter/material.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/playlist/music_list.dart';
import 'package:quiet/part/part.dart';

class PlaylistInternalSearchDelegate extends SearchDelegate {
  PlaylistInternalSearchDelegate(this.playlist) : assert(playlist != null && playlist.musicList != null);

  final PlaylistDetail playlist;

  List<Music> get list => playlist.musicList;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    return BoxWithBottomPlayerController(buildSection(context));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  Widget buildSection(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    var result = list?.where((m) => m.title.contains(query) || m.subTitle.contains(query))?.toList();
    if (result == null || result.isEmpty) {
      return _EmptyResultSection(query);
    }
    return _InternalResultSection(musics: result);
  }
}

class _EmptyResultSection extends StatelessWidget {
  const _EmptyResultSection(this.query);

  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 50),
      child: Center(
        child: Text('未找到与"$query"相关的内容'),
      ),
    );
  }
}

class _InternalResultSection extends StatelessWidget {
  const _InternalResultSection({Key key, this.musics}) : super(key: key);

  ///result song list, can not be null and empty
  final List<Music> musics;

  @override
  Widget build(BuildContext context) {
    return MusicTileConfiguration(
      musics: musics,
      onMusicTap: (_, music) {
        context.player
          ..insertToNext(music.metadata)
          ..transportControls.playFromMediaId(music.metadata.mediaId);
      },
      trailingBuilder: MusicTileConfiguration.defaultTrailingBuilder,
      child: ListView.builder(
          itemCount: musics.length,
          itemBuilder: (context, index) {
            return MusicTile(musics[index]);
          }),
    );
  }
}
