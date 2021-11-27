import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'track.g.dart';

typedef Music = Track;

class Track with EquatableMixin {
  Track({
    required this.id,
    required this.uri,
    required this.name,
    required this.artists,
    required this.album,
    required this.imageUrl,
  });

  final int id;

  final String? uri;

  final String name;

  final List<Artist> artists;

  final Album? album;

  final String? imageUrl;

  String get displaySubtitle => artists.map((artist) => artist.name).join(', ');

  @override
  List<Object?> get props => [id, uri, name, artists, album, imageUrl];
}

@JsonSerializable()
class Artist with EquatableMixin {
  Artist({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, imageUrl];

  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}

@JsonSerializable()
class Album with EquatableMixin {
  Album({
    required this.id,
    required this.picUri,
    required this.name,
  });

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'picUrl')
  final String? picUri;

  @JsonKey(name: 'name')
  final String name;

  @override
  List<Object?> get props => [id, picUri, name];

  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}
