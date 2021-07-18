// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Album _$AlbumFromJson(Map json) {
  return Album(
    coverImageUrl: json['coverImageUrl'] as String?,
    name: json['name'] as String?,
    id: json['id'] as int?,
  );
}

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
      'coverImageUrl': instance.coverImageUrl,
      'name': instance.name,
      'id': instance.id,
    };

Artist _$ArtistFromJson(Map json) {
  return Artist(
    name: json['name'] as String?,
    id: json['id'] as int?,
    imageUrl: json['imageUrl'] as String?,
  );
}

Map<String, dynamic> _$ArtistToJson(Artist instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'imageUrl': instance.imageUrl,
    };
