// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Music _$MusicFromJson(Map json) {
  return Music(
    id: json['id'] as int,
    title: json['name'] as String? ?? '',
    url: json['url'] as String?,
    album: json['al'] == null ? null : Album.fromJson(json['al'] as Map),
    artist: (json['ar'] as List<dynamic>?)
        ?.map((e) => Artist.fromJson(e as Map))
        .toList(),
    mvId: json['mv'] as int?,
  );
}

Map<String, dynamic> _$MusicToJson(Music instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.title,
      'url': instance.url,
      'al': instance.album?.toJson(),
      'ar': instance.artist?.map((e) => e.toJson()).toList(),
      'mv': instance.mvId,
    };
