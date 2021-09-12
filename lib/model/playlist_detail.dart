import 'package:json_annotation/json_annotation.dart';
import 'package:quiet/model/model.dart';

part 'playlist_detail.g.dart';

@JsonSerializable()
class PlaylistDetail {
  PlaylistDetail({
    this.id,
    required this.musicList,
    this.creator,
    this.name,
    this.coverUrl,
    this.trackCount,
    this.description,
    required this.subscribed,
    this.subscribedCount,
    this.commentCount,
    this.shareCount,
    this.playCount,
  });

  factory PlaylistDetail.fromJson(Map playlist) {
    return _$PlaylistDetailFromJson(playlist);
  }

  ///null when playlist not complete loaded
  @JsonKey(name: 'tracks', defaultValue: [])
  final List<Music> musicList;

  String? name;

  @JsonKey(name: 'coverImgUrl')
  String? coverUrl;

  int? id;

  int? trackCount;

  String? description;

  bool subscribed;

  int? subscribedCount;

  int? commentCount;

  int? shareCount;

  int? playCount;

  bool get loaded => trackCount == 0 || (musicList.length == trackCount);

  ///tag fro hero transition
  String get heroTag => "playlist_hero_$id";

  ///
  /// properties:
  /// avatarUrl , nickname
  ///
  final Map<String, dynamic>? creator;

  Map toJson() => _$PlaylistDetailToJson(this);
}
