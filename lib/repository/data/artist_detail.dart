import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'track.dart';

part 'artist_detail.g.dart';

class ArtistDetail {
  ArtistDetail({
    required this.hotSongs,
    required this.more,
    required this.artist,
  });

  final List<Track> hotSongs;

  final bool more;

  final Artist artist;
}

@JsonSerializable()
class Artist with EquatableMixin {
  Artist({
    required this.name,
    required this.id,
    required this.publishTime,
    required this.image1v1Url,
    required this.picUrl,
    required this.albumSize,
    required this.mvSize,
    required this.musicSize,
    required this.followed,
    required this.briefDesc,
    required this.alias,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  final String name;
  final int id;

  final int publishTime;
  final String image1v1Url;
  final String picUrl;

  final int albumSize;
  final int mvSize;
  final int musicSize;

  final bool followed;

  final String briefDesc;

  final List<String> alias;

  @override
  List<Object?> get props => [
        name,
        id,
        publishTime,
        image1v1Url,
        picUrl,
        albumSize,
        mvSize,
        musicSize,
        followed,
        briefDesc,
        alias,
      ];

  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}
