// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaylistDetail _$PlaylistDetailFromJson(Map json) {
  return PlaylistDetail(
    id: json['id'] as int?,
    musicList: (json['tracks'] as List<dynamic>?)
            ?.map((e) => Music.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [],
    creator: (json['creator'] as Map?)?.map(
      (k, e) => MapEntry(k as String, e),
    ),
    name: json['name'] as String?,
    coverUrl: json['coverImgUrl'] as String?,
    trackCount: json['trackCount'] as int?,
    description: json['description'] as String?,
    subscribed: json['subscribed'] as bool,
    subscribedCount: json['subscribedCount'] as int?,
    commentCount: json['commentCount'] as int?,
    shareCount: json['shareCount'] as int?,
    playCount: json['playCount'] as int?,
  );
}

Map<String, dynamic> _$PlaylistDetailToJson(PlaylistDetail instance) =>
    <String, dynamic>{
      'tracks': instance.musicList.map((e) => e.toJson()).toList(),
      'name': instance.name,
      'coverImgUrl': instance.coverUrl,
      'id': instance.id,
      'trackCount': instance.trackCount,
      'description': instance.description,
      'subscribed': instance.subscribed,
      'subscribedCount': instance.subscribedCount,
      'commentCount': instance.commentCount,
      'shareCount': instance.shareCount,
      'playCount': instance.playCount,
      'creator': instance.creator,
    };
