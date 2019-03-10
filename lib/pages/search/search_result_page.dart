import 'package:flutter/material.dart';

import 'result_albums.dart';
import 'result_artists.dart';
import 'result_playlists.dart';
import 'result_songs.dart';
import 'result_videos.dart';

///搜索结果分类
const List<String> SECTIONS = ["单曲", "视频", "歌手", "专辑", "歌单"];

class SearchResultPage extends StatefulWidget {
  SearchResultPage({Key key, this.query})
      : assert(query != null && query.isNotEmpty),
        super(key: key);

  final String query;

  @override
  _SearchResultPageState createState() {
    return new _SearchResultPageState();
  }
}

class _SearchResultPageState extends State<SearchResultPage> {
  String query;

  @override
  void initState() {
    super.initState();
    query = widget.query;
  }

  @override
  void didUpdateWidget(SearchResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      setState(() {
        query = widget.query;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        SongsResultSection(query: query, key: Key("SongTab_$query")),
        VideosResultSection(query: query, key: Key("VideoTab_$query")),
        ArtistsResultSection(query: query, key: Key("Artists_$query")),
        AlbumsResultSection(query: query, key: Key("AlbumTab_$query")),
        PlaylistResultSection(query: query, key: Key("PlaylistTab_$query")),
      ],
    );
  }
}
