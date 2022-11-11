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
    required this.isUserFavoriteList,
    required this.rawPlaylistId,
  });

  const TrackList.empty()
      : id = '',
        tracks = const [],
        isFM = false,
        isUserFavoriteList = false,
        rawPlaylistId = null;

  const TrackList.fm({required this.tracks})
      : isFM = true,
        id = kFmTrackListId,
        isUserFavoriteList = false,
        rawPlaylistId = null;

  const TrackList.playlist({
    required this.id,
    required this.tracks,
    required this.rawPlaylistId,
    this.isUserFavoriteList = false,
  })  : assert(
          id != kFmTrackListId,
          'Cannot create a playlist with id $kFmTrackListId',
        ),
        isFM = false;

  factory TrackList.fromJson(Map<String, dynamic> json) =>
      _$TrackListFromJson(json);

  final String id;
  final List<Track> tracks;

  final bool isFM;
  final bool isUserFavoriteList;

  // netease playlist id
  final int? rawPlaylistId;

  Map<String, dynamic> toJson() => _$TrackListToJson(this);

  bool get isEmpty => id.isEmpty || tracks.isEmpty;

  TrackList copyWith({
    String? id,
    List<Track>? tracks,
    bool? isFM,
    bool? isUserFavoriteList,
    int? rawPlaylistId,
  }) {
    return TrackList._private(
      id: id ?? this.id,
      tracks: tracks ?? this.tracks,
      isFM: isFM ?? this.isFM,
      isUserFavoriteList: isUserFavoriteList ?? this.isUserFavoriteList,
      rawPlaylistId: rawPlaylistId ?? this.rawPlaylistId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tracks,
        isFM,
        isUserFavoriteList,
        rawPlaylistId,
      ];
}
