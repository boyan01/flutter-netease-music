// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_recommend_songs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecommendSongs _$DailyRecommendSongsFromJson(Map<String, dynamic> json) =>
    DailyRecommendSongs(
      dailySongs: (json['dailySongs'] as List<dynamic>)
          .map((e) => FmTrackItem.fromJson(e as Map<String, dynamic>?))
          .toList(),
      recommendReasons: (json['recommendReasons'] as List<dynamic>?)
          ?.map((e) => RecommendReason.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DailyRecommendSongsToJson(
        DailyRecommendSongs instance) =>
    <String, dynamic>{
      'dailySongs': instance.dailySongs,
      'recommendReasons': instance.recommendReasons,
    };

RecommendReason _$RecommendReasonFromJson(Map<String, dynamic> json) =>
    RecommendReason(
      songId: json['songId'] as int,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$RecommendReasonToJson(RecommendReason instance) =>
    <String, dynamic>{
      'songId': instance.songId,
      'reason': instance.reason,
    };
