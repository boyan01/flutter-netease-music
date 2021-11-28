// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Artist _$ArtistFromJson(Map json) => Artist(
      name: json['name'] as String,
      id: json['id'] as int,
      publishTime: json['publishTime'] as int,
      image1v1Url: json['image1v1Url'] as String,
      picUrl: json['picUrl'] as String,
      albumSize: json['albumSize'] as int,
      mvSize: json['mvSize'] as int,
      musicSize: json['musicSize'] as int,
      followed: json['followed'] as bool,
      briefDesc: json['briefDesc'] as String,
      alias: (json['alias'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ArtistToJson(Artist instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'publishTime': instance.publishTime,
      'image1v1Url': instance.image1v1Url,
      'picUrl': instance.picUrl,
      'albumSize': instance.albumSize,
      'mvSize': instance.mvSize,
      'musicSize': instance.musicSize,
      'followed': instance.followed,
      'briefDesc': instance.briefDesc,
      'alias': instance.alias,
    };
