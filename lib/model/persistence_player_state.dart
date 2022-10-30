import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../media/tracks/track_list.dart';
import '../media/tracks/tracks_player.dart';
import '../repository/data/track.dart';

part 'persistence_player_state.g.dart';

@JsonSerializable()
class PersistencePlayerState with EquatableMixin {
  PersistencePlayerState({
    required this.volume,
    required this.playingTrack,
    required this.playingList,
    required this.repeatMode,
  });

  factory PersistencePlayerState.fromJson(Map<String, dynamic> json) =>
      _$PersistencePlayerStateFromJson(json);

  final double volume;
  final Track? playingTrack;
  final TrackList playingList;
  final RepeatMode repeatMode;

  @override
  List<Object?> get props => [
        volume,
        playingTrack,
        playingList,
        repeatMode,
      ];

  Map<String, dynamic> toJson() => _$PersistencePlayerStateToJson(this);
}
