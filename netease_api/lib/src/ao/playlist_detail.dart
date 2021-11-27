import 'package:json_annotation/json_annotation.dart';

part 'playlist_detail.g.dart';

@JsonSerializable()
class PlaylistDetail {
  PlaylistDetail({
    this.id,
    required this.musicList,
    this.creator,
    this.name,
    this.coverUrl,
    required this.trackCount,
    this.description,
    required this.subscribed,
    this.subscribedCount,
    this.commentCount,
    this.shareCount,
    this.playCount,
    required this.trackUpdateTime,
    required this.trackIds,
  });

  factory PlaylistDetail.fromJson(Map playlist) {
    return _$PlaylistDetailFromJson(playlist);
  }

  ///null when playlist not complete loaded
  @JsonKey(name: 'tracks', defaultValue: [])
  List<Music> musicList;

  @JsonKey(defaultValue: [])
  List<TrackId> trackIds;

  String? name;

  @JsonKey(name: 'coverImgUrl')
  String? coverUrl;

  int? id;

  int trackCount;

  String? description;

  @JsonKey(defaultValue: false)
  bool subscribed;

  int? subscribedCount;

  int? commentCount;

  int? shareCount;

  int? playCount;

  @JsonKey(defaultValue: 0)
  int trackUpdateTime;

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

@JsonSerializable()
class TrackId {
  TrackId({
    required this.id,
    required this.v,
    required this.t,
    required this.at,
    required this.uid,
    required this.rcmdReason,
  });

  factory TrackId.fromJson(Map json) => _$TrackIdFromJson(json);

  final int id;
  final int v;
  final int t;
  final int at;
  final int uid;
  final String rcmdReason;

  Map<String, dynamic> toJson() => _$TrackIdToJson(this);
}
