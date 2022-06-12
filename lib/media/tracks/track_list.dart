import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../repository/data/track.dart';

part 'track_list.g.dart';

const kFmTrackListId = '_fm_playlist';

@JsonSerializable(constructor: '_private')
class TrackList with EquatableMixin {
  const TrackList._private({
    required this.id,
    required this.tracks,
    required this.isFM,
  });

  const TrackList.empty()
      : id = '',
        tracks = const [],
        isFM = false;

  const TrackList.fm({required this.tracks})
      : isFM = true,
        id = kFmTrackListId;

  const TrackList.playlist({required this.id, required this.tracks})
      : assert(id != kFmTrackListId,
            'Cannot create a playlist with id $kFmTrackListId',),
        isFM = false;

  factory TrackList.fromJson(Map<String, dynamic> json) =>
      _$TrackListFromJson(json);

  final String id;
  final List<Track> tracks;

  final bool isFM;

  Map<String, dynamic> toJson() => _$TrackListToJson(this);

  @override
  List<Object?> get props => [id, tracks, isFM];
}
