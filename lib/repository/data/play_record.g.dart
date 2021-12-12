// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayRecord _$PlayRecordFromJson(Map json) => PlayRecord(
      playCount: json['playCount'] as int,
      score: json['score'] as int,
      song: Track.fromJson(Map<String, dynamic>.from(json['song'] as Map)),
    );

Map<String, dynamic> _$PlayRecordToJson(PlayRecord instance) =>
    <String, dynamic>{
      'playCount': instance.playCount,
      'score': instance.score,
      'song': instance.song.toJson(),
    };
