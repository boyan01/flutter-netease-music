import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/repository.dart';

class PlaylistInternalSearchDelegate extends SearchDelegate {
  PlaylistInternalSearchDelegate(this.playlist);

  final PlaylistDetail playlist;

  List<Music>? get list => playlist.tracks;

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
    return const BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSection(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  Widget buildSection(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    final result = list
        ?.where(
            (m) => m.name.contains(query) || m.displaySubtitle.contains(query))
        .toList();
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
      padding: const EdgeInsets.only(top: 50),
      child: Center(
        child: Text('未找到与"$query"相关的内容'),
      ),
    );
  }
}

class _InternalResultSection extends ConsumerWidget {
  const _InternalResultSection({
    Key? key,
    required this.musics,
  }) : super(key: key);

  ///result song list, can not be null and empty
  final List<Music> musics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MusicTileConfiguration(
      musics: musics,
      onMusicTap: (_, music) {
        ref.read(playerProvider)
          ..insertToNext(music)
          ..playFromMediaId(music.id);
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
