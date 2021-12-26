// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyPlaylist _$DailyPlaylistFromJson(Map json) => DailyPlaylist(
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$DailyPlaylistToJson(DailyPlaylist instance) =>
    <String, dynamic>{
      'tracks': instance.tracks.map((e) => e.toJson()).toList(),
      'date': instance.date.toIso8601String(),
    };
