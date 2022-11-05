import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'track.g.dart';

typedef Music = Track;

@HiveType(typeId: 3)
enum TrackType {
  @HiveField(0)
  free,
  @HiveField(1)
  payAlbum,
  @HiveField(2)
  vip,
  @HiveField(3)
  cloud,
  @HiveField(4)
  noCopyright,
}

@JsonSerializable()
@HiveType(typeId: 2)
class Track with EquatableMixin {
  Track({
    required this.id,
    required this.uri,
    required this.name,
    required this.artists,
    required this.album,
    required this.imageUrl,
    required this.duration,
    required this.type,
    this.isRecommend = false,
  });

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String? uri;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final List<ArtistMini> artists;

  @HiveField(4)
  final AlbumMini? album;

  @HiveField(5)
  final String? imageUrl;

  @HiveField(6)
  final Duration duration;

  @HiveField(7)
  final TrackType type;

  @HiveField(8, defaultValue: false)
  final bool isRecommend;

  String get displaySubtitle {
    final artist = artists.map((artist) => artist.name).join('/');
    return '$artist - ${album?.name ?? ''}';
  }

  String get artistString {
    return artists.map((artist) => artist.name).join('/');
  }

  @override
  List<Object?> get props => [
        id,
        uri,
        name,
        artists,
        album,
        imageUrl,
        duration,
        type,
        isRecommend,
      ];

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 4)
class ArtistMini with EquatableMixin {
  ArtistMini({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory ArtistMini.fromJson(Map<String, dynamic> json) =>
      _$ArtistMiniFromJson(json);

  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;
  @JsonKey(name: 'name')
  @HiveField(1)
  final String name;
  @JsonKey(name: 'imageUrl')
  @HiveField(2)
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, imageUrl];

  Map<String, dynamic> toJson() => _$ArtistMiniToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 5)
class AlbumMini with EquatableMixin {
  AlbumMini({
    required this.id,
    required this.picUri,
    required this.name,
  });

  factory AlbumMini.fromJson(Map<String, dynamic> json) =>
      _$AlbumMiniFromJson(json);

  @JsonKey(name: 'id')
  @HiveField(0)
  final int id;

  @JsonKey(name: 'picUrl')
  @HiveField(1)
  final String? picUri;

  @JsonKey(name: 'name')
  @HiveField(2)
  final String name;

  @override
  List<Object?> get props => [id, picUri, name];

  Map<String, dynamic> toJson() => _$AlbumMiniToJson(this);
}
