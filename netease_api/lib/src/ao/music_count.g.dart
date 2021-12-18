// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_count.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicCount _$MusicCountFromJson(Map<String, dynamic> json) => MusicCount(
      artistCount: json['artistCount'] as int? ?? 0,
      djRadioCount: json['djRadioCount'] as int? ?? 0,
      mvCount: json['mvCount'] as int? ?? 0,
      createDjRadioCount: json['createDjRadioCount'] as int? ?? 0,
      createdPlaylistCount: json['createdPlaylistCount'] as int? ?? 0,
      subPlaylistCount: json['subPlaylistCount'] as int? ?? 0,
    );

Map<String, dynamic> _$MusicCountToJson(MusicCount instance) =>
    <String, dynamic>{
      'artistCount': instance.artistCount,
      'djRadioCount': instance.djRadioCount,
      'mvCount': instance.mvCount,
      'createDjRadioCount': instance.createDjRadioCount,
      'createdPlaylistCount': instance.createdPlaylistCount,
      'subPlaylistCount': instance.subPlaylistCount,
    };
