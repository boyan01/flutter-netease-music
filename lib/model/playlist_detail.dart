import 'package:quiet/model/model.dart';
import 'package:quiet/repository/netease.dart';

class PlaylistDetail {
  PlaylistDetail(
      this.id,
      this.musicList,
      this.creator,
      this.name,
      this.coverUrl,
      this.trackCount,
      this.description,
      this.subscribed,
      this.subscribedCount);

  ///null when playlist not complete loaded
  final List<Music> musicList;

  String name;

  String coverUrl;

  int id;

  int trackCount;

  String description;

  bool subscribed;

  int subscribedCount;

  bool get loaded => musicList != null && musicList.length == trackCount;

  ///tag fro hero transition
  String get heroTag => "playlist_hero_$id";

  ///
  /// properties:
  /// avatarUrl , nickname
  ///
  final Map<String, dynamic> creator;

  static PlaylistDetail fromJson(Map playlist) {
    return PlaylistDetail(
        playlist["id"],
        mapJsonListToMusicList(playlist["tracks"],
            artistKey: "ar", albumKey: "al"),
        playlist["creator"],
        playlist["name"],
        playlist["coverImgUrl"],
        playlist["trackCount"],
        playlist["description"],
        playlist["subscribed"],
        playlist["subscribedCount"]);
  }
}
