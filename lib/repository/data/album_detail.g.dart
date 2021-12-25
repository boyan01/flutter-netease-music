// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbumDetail _$AlbumDetailFromJson(Map json) => AlbumDetail(
      album: Album.fromJson(Map<String, dynamic>.from(json['album'] as Map)),
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$AlbumDetailToJson(AlbumDetail instance) =>
    <String, dynamic>{
      'album': instance.album.toJson(),
      'tracks': instance.tracks.map((e) => e.toJson()).toList(),
    };

Album _$AlbumFromJson(Map json) => Album(
      name: json['name'] as String,
      id: json['id'] as int,
      briefDesc: json['briefDesc'] as String,
      publishTime: DateTime.parse(json['publishTime'] as String),
      company: json['company'] as String,
      picUrl: json['picUrl'] as String,
      description: json['description'] as String,
      artist:
          ArtistMini.fromJson(Map<String, dynamic>.from(json['artist'] as Map)),
      paid: json['paid'] as bool,
      onSale: json['onSale'] as bool,
      size: json['size'] as int,
      liked: json['liked'] as bool,
      commentCount: json['commentCount'] as int,
      likedCount: json['likedCount'] as int,
      shareCount: json['shareCount'] as int,
    );

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'briefDesc': instance.briefDesc,
      'publishTime': instance.publishTime.toIso8601String(),
      'company': instance.company,
      'picUrl': instance.picUrl,
      'description': instance.description,
      'artist': instance.artist.toJson(),
      'paid': instance.paid,
      'onSale': instance.onSale,
      'size': instance.size,
      'liked': instance.liked,
      'commentCount': instance.commentCount,
      'likedCount': instance.likedCount,
      'shareCount': instance.shareCount,
    };
