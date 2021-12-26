import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiet/repository.dart';

part 'daily_playlist.g.dart';

@JsonSerializable()
class DailyPlaylist with EquatableMixin {
  DailyPlaylist({
    required this.tracks,
    required this.date,
  });

  factory DailyPlaylist.fromJson(Map<String, dynamic> json) =>
      _$DailyPlaylistFromJson(json);

  final List<Track> tracks;

  final DateTime date;

  Map<String, dynamic> toJson() => _$DailyPlaylistToJson(this);

  @override
  List<Object?> get props => [tracks, date];
}
