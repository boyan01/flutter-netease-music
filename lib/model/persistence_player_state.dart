import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../media/tracks/track_list.dart';
import '../repository/data/track.dart';

part 'persistence_player_state.g.dart';

@JsonSerializable()
class PersistencePlayerState with EquatableMixin {
  PersistencePlayerState({
    required this.volume,
    required this.playingTrack,
    required this.playingList,
  });

  factory PersistencePlayerState.fromJson(Map<String, dynamic> json) =>
      _$PersistencePlayerStateFromJson(json);

  final double volume;
  final Track? playingTrack;
  final TrackList playingList;

  @override
  List<Object?> get props => [
        volume,
        playingTrack,
        playingList,
      ];

  Map<String, dynamic> toJson() => _$PersistencePlayerStateToJson(this);
}
