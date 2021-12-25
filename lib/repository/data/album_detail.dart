import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'track.dart';

part 'album_detail.g.dart';

@JsonSerializable()
class AlbumDetail {
  AlbumDetail({
    required this.album,
    required this.tracks,
  });

  factory AlbumDetail.fromJson(Map<String, dynamic> json) =>
      _$AlbumDetailFromJson(json);

  final Album album;

  final List<Track> tracks;

  Map<String, dynamic> toJson() => _$AlbumDetailToJson(this);
}

@JsonSerializable()
class Album with EquatableMixin {
  Album({
    required this.name,
    required this.id,
    required this.briefDesc,
    required this.publishTime,
    required this.company,
    required this.picUrl,
    required this.description,
    required this.artist,
    required this.paid,
    required this.onSale,
    required this.size,
    required this.liked,
    required this.commentCount,
    required this.likedCount,
    required this.shareCount,
  });

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

  final String name;
  final int id;

  final String briefDesc;
  final DateTime publishTime;
  final String company;
  final String picUrl;

  final String description;

  final ArtistMini artist;

  final bool paid;
  final bool onSale;

  final int size;

  final bool liked;
  final int commentCount;
  final int likedCount;
  final int shareCount;

  @override
  List<Object?> get props => [
        name,
        id,
        briefDesc,
        publishTime,
        company,
        picUrl,
        description,
        artist,
        paid,
        onSale,
        size,
        liked,
        commentCount,
        likedCount,
        shareCount,
      ];

  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}
