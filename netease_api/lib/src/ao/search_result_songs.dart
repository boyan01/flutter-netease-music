import '../../netease_api.dart';

import 'safe_convert.dart';

class SearchResultSongs {
  SearchResultSongs({
    required this.songs,
    this.hasMore = false,
    this.songCount = 0,
  });

  factory SearchResultSongs.fromJson(Map<String, dynamic>? json) =>
      SearchResultSongs(
        songs:
            asList(json, 'songs').map((e) => TracksItem.fromJson(e)).toList(),
        hasMore: asBool(json, 'hasMore'),
        songCount: asInt(json, 'songCount'),
      );

  final List<TracksItem> songs;
  final bool hasMore;
  final int songCount;

  Map<String, dynamic> toJson() => {
        'songs': songs.map((e) => e.toJson()),
        'hasMore': hasMore,
        'songCount': songCount,
      };
}
