import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'track.g.dart';

typedef Music = Track;

@JsonSerializable()
class Track with EquatableMixin {
  Track({
    required this.id,
    required this.uri,
    required this.name,
    required this.artists,
    required this.album,
    required this.imageUrl,
    required this.duration,
  });

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  final int id;

  final String? uri;

  final String name;

  final List<ArtistMini> artists;

  final AlbumMini? album;

  final String? imageUrl;

  final Duration duration;

  String get displaySubtitle => artists.map((artist) => artist.name).join(', ');

  @override
  List<Object?> get props =>
      [id, uri, name, artists, album, imageUrl, duration];

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}

@JsonSerializable()
class ArtistMini with EquatableMixin {
  ArtistMini({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory ArtistMini.fromJson(Map<String, dynamic> json) =>
      _$ArtistMiniFromJson(json);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, imageUrl];

  Map<String, dynamic> toJson() => _$ArtistMiniToJson(this);
}

@JsonSerializable()
class AlbumMini with EquatableMixin {
  AlbumMini({
    required this.id,
    required this.picUri,
    required this.name,
  });

  factory AlbumMini.fromJson(Map<String, dynamic> json) =>
      _$AlbumMiniFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'picUrl')
  final String? picUri;

  @JsonKey(name: 'name')
  final String name;

  @override
  List<Object?> get props => [id, picUri, name];

  Map<String, dynamic> toJson() => _$AlbumMiniToJson(this);
}
