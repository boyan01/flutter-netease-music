// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Music _$MusicFromJson(Map json) {
  return Music(
    id: json['id'] as int,
    title: json['title'] as String?,
    url: json['url'] as String?,
    album: json['album'] == null ? null : Album.fromJson(json['album'] as Map),
    artist: (json['artist'] as List<dynamic>?)
        ?.map((e) => Artist.fromJson(e as Map))
        .toList(),
    mvId: json['mvId'] as int?,
  );
}

Map<String, dynamic> _$MusicToJson(Music instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'album': instance.album,
      'artist': instance.artist,
      'mvId': instance.mvId,
    };
