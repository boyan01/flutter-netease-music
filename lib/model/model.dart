import 'package:json_annotation/json_annotation.dart';

export 'music.dart';

part 'model.g.dart';

@JsonSerializable()
class Album {
  Album({
    this.coverImageUrl,
    this.name,
    this.id,
  });

  @JsonKey(name: 'picUrl')
  String? coverImageUrl;

  String? name;

  int? id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id;

  @override
  int get hashCode => name.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'Album{name: $name, id: $id}';
  }

  static Album fromJson(Map map) => _$AlbumFromJson(map);

  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}

@JsonSerializable()
class Artist {
  Artist({
    this.name,
    this.id,
    this.imageUrl,
  });

  String? name;

  int? id;

  String? imageUrl;

  @override
  String toString() {
    return 'Artist{name: $name, id: $id, imageUrl: $imageUrl}';
  }

  static Artist fromJson(Map json) {
    return _$ArtistFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$ArtistToJson(this);
  }
}
