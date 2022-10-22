// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_list_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopListDetail _$TopListDetailFromJson(Map<String, dynamic> json) =>
    TopListDetail(
      (json['list'] as List<dynamic>)
          .map((e) => LeaderboardItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      ArtistLeaderboard.fromJson(json['artistToplist'] as Map<String, dynamic>),
      RewardLeaderboard.fromJson(json['rewardToplist'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TopListDetailToJson(TopListDetail instance) =>
    <String, dynamic>{
      'list': instance.list,
      'artistToplist': instance.artistTopList,
      'rewardToplist': instance.rewardTopList,
    };

LeaderboardItem _$LeaderboardItemFromJson(Map<String, dynamic> json) =>
    LeaderboardItem(
      (json['tracks'] as List<dynamic>)
          .map((e) => LeaderboardTrackItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['updateFrequency'] as String,
      json['coverImgUrl'] as String,
      json['name'] as String,
      json['id'] as int,
      json['description'] as String?,
    );

Map<String, dynamic> _$LeaderboardItemToJson(LeaderboardItem instance) =>
    <String, dynamic>{
      'tracks': instance.tracks,
      'updateFrequency': instance.updateFrequency,
      'coverImgUrl': instance.coverImgUrl,
      'name': instance.name,
      'id': instance.id,
      'description': instance.description,
    };

LeaderboardTrackItem _$LeaderboardTrackItemFromJson(
        Map<String, dynamic> json) =>
    LeaderboardTrackItem(
      json['first'] as String,
      json['second'] as String,
    );

Map<String, dynamic> _$LeaderboardTrackItemToJson(
        LeaderboardTrackItem instance) =>
    <String, dynamic>{
      'first': instance.name,
      'second': instance.artist,
    };

ArtistLeaderboard _$ArtistLeaderboardFromJson(Map<String, dynamic> json) =>
    ArtistLeaderboard(
      json['coverUrl'] as String,
      (json['artists'] as List<dynamic>)
          .map((e) => ArtistLeaderboardItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['name'] as String,
      json['updateFrequency'] as String,
      json['position'] as int,
    );

Map<String, dynamic> _$ArtistLeaderboardToJson(ArtistLeaderboard instance) =>
    <String, dynamic>{
      'coverUrl': instance.coverUrl,
      'artists': instance.artists,
      'name': instance.name,
      'updateFrequency': instance.updateFrequency,
      'position': instance.position,
    };

ArtistLeaderboardItem _$ArtistLeaderboardItemFromJson(
        Map<String, dynamic> json) =>
    ArtistLeaderboardItem(
      json['first'] as String,
      json['third'] as int,
    );

Map<String, dynamic> _$ArtistLeaderboardItemToJson(
        ArtistLeaderboardItem instance) =>
    <String, dynamic>{
      'first': instance.name,
      'third': instance.id,
    };

RewardLeaderboard _$RewardLeaderboardFromJson(Map<String, dynamic> json) =>
    RewardLeaderboard(
      json['coverUrl'] as String,
      (json['songs'] as List<dynamic>)
          .map((e) => FmTrackItem.fromJson(e as Map<String, dynamic>?))
          .toList(),
      json['name'] as String,
      json['position'] as int,
    );

Map<String, dynamic> _$RewardLeaderboardToJson(RewardLeaderboard instance) =>
    <String, dynamic>{
      'coverUrl': instance.coverUrl,
      'songs': instance.songs,
      'name': instance.name,
      'position': instance.position,
    };
