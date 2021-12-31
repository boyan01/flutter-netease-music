import 'package:json_annotation/json_annotation.dart';

import 'track.dart';

part 'cloud_tracks_detail.g.dart';

@JsonSerializable()
class CloudTracksDetail {
  CloudTracksDetail({
    required this.tracks,
    required this.size,
    required this.maxSize,
    required this.trackCount,
  });

  factory CloudTracksDetail.fromJson(Map<String, dynamic> json) =>
      _$CloudTracksDetailFromJson(json);

  final List<Track> tracks;
  final int size;
  final int maxSize;
  final int trackCount;

  Map<String, dynamic> toJson() => _$CloudTracksDetailToJson(this);
}
