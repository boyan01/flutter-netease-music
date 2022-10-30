// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persistence_player_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersistencePlayerState _$PersistencePlayerStateFromJson(Map json) =>
    PersistencePlayerState(
      volume: (json['volume'] as num).toDouble(),
      playingTrack: json['playingTrack'] == null
          ? null
          : Track.fromJson(
              Map<String, dynamic>.from(json['playingTrack'] as Map)),
      playingList: TrackList.fromJson(
          Map<String, dynamic>.from(json['playingList'] as Map)),
      repeatMode: $enumDecode(_$RepeatModeEnumMap, json['repeatMode']),
    );

Map<String, dynamic> _$PersistencePlayerStateToJson(
        PersistencePlayerState instance) =>
    <String, dynamic>{
      'volume': instance.volume,
      'playingTrack': instance.playingTrack?.toJson(),
      'playingList': instance.playingList.toJson(),
      'repeatMode': _$RepeatModeEnumMap[instance.repeatMode]!,
    };

const _$RepeatModeEnumMap = {
  RepeatMode.shuffle: 'shuffle',
  RepeatMode.single: 'single',
  RepeatMode.sequence: 'sequence',
  RepeatMode.heart: 'heart',
};
