import 'package:json_annotation/json_annotation.dart';

import '../../netease_api.dart';

part 'top_list_detail.g.dart';

@JsonSerializable()
class TopListDetail {
  TopListDetail(this.list, this.artistTopList, this.rewardTopList);

  factory TopListDetail.fromJson(Map<String, dynamic> json) =>
      _$TopListDetailFromJson(json);

  @JsonKey(name: 'list')
  final List<LeaderboardItem> list;

  @JsonKey(name: 'artistToplist')
  final ArtistLeaderboard artistTopList;

  @JsonKey(name: 'rewardToplist')
  final RewardLeaderboard rewardTopList;

  Map<String, dynamic> toJson() => _$TopListDetailToJson(this);
}

@JsonSerializable()
class LeaderboardItem {
  LeaderboardItem(
    this.tracks,
    this.updateFrequency,
    this.coverImgUrl,
    this.name,
    this.id,
    this.description,
  );

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardItemFromJson(json);

  @JsonKey(name: 'tracks')
  final List<LeaderboardTrackItem> tracks;

  @JsonKey(name: 'updateFrequency')
  final String updateFrequency;

  @JsonKey(name: 'coverImgUrl')
  final String coverImgUrl;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'description')
  final String? description;

  Map<String, dynamic> toJson() => _$LeaderboardItemToJson(this);
}

@JsonSerializable()
class LeaderboardTrackItem {
  LeaderboardTrackItem(this.name, this.artist);

  factory LeaderboardTrackItem.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardTrackItemFromJson(json);

  @JsonKey(name: 'first')
  final String name;

  @JsonKey(name: 'second')
  final String artist;

  Map<String, dynamic> toJson() => _$LeaderboardTrackItemToJson(this);
}

@JsonSerializable()
class ArtistLeaderboard {
  ArtistLeaderboard(
    this.coverUrl,
    this.artists,
    this.name,
    this.updateFrequency,
    this.position,
  );

  factory ArtistLeaderboard.fromJson(Map<String, dynamic> json) =>
      _$ArtistLeaderboardFromJson(json);

  @JsonKey(name: 'coverUrl')
  final String coverUrl;

  @JsonKey(name: 'artists')
  final List<ArtistLeaderboardItem> artists;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'updateFrequency')
  final String updateFrequency;
  @JsonKey(name: 'position')
  final int position;

  Map<String, dynamic> toJson() => _$ArtistLeaderboardToJson(this);
}

@JsonSerializable()
class ArtistLeaderboardItem {
  ArtistLeaderboardItem(this.name, this.id);

  factory ArtistLeaderboardItem.fromJson(Map<String, dynamic> json) =>
      _$ArtistLeaderboardItemFromJson(json);

  @JsonKey(name: 'first')
  final String name;

  @JsonKey(name: 'third')
  final int id;

  Map<String, dynamic> toJson() => _$ArtistLeaderboardItemToJson(this);
}

@JsonSerializable()
class RewardLeaderboard {
  RewardLeaderboard(this.coverUrl, this.songs, this.name, this.position);

  factory RewardLeaderboard.fromJson(Map<String, dynamic> json) =>
      _$RewardLeaderboardFromJson(json);

  @JsonKey(name: 'coverUrl')
  final String coverUrl;

  @JsonKey(name: 'songs')
  final List<FmTrackItem> songs;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'position')
  final int position;

  Map<String, dynamic> toJson() => _$RewardLeaderboardToJson(this);
}
