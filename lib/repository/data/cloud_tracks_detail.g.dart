// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_tracks_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CloudTracksDetail _$CloudTracksDetailFromJson(Map json) => CloudTracksDetail(
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      size: json['size'] as int,
      maxSize: json['maxSize'] as int,
      trackCount: json['trackCount'] as int,
    );

Map<String, dynamic> _$CloudTracksDetailToJson(CloudTracksDetail instance) =>
    <String, dynamic>{
      'tracks': instance.tracks.map((e) => e.toJson()).toList(),
      'size': instance.size,
      'maxSize': instance.maxSize,
      'trackCount': instance.trackCount,
    };
