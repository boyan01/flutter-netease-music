// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaylistDetail _$PlaylistDetailFromJson(Map json) => PlaylistDetail(
      id: json['id'] as int,
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      creator: User.fromJson(Map<String, dynamic>.from(json['creator'] as Map)),
      coverUrl: json['coverUrl'] as String,
      trackCount: json['trackCount'] as int,
      subscribed: json['subscribed'] as bool,
      subscribedCount: json['subscribedCount'] as int,
      shareCount: json['shareCount'] as int,
      playCount: json['playCount'] as int,
      trackUpdateTime: json['trackUpdateTime'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      commentCount: json['commentCount'] as int,
      trackIds:
          (json['trackIds'] as List<dynamic>).map((e) => e as int).toList(),
      createTime: DateTime.parse(json['createTime'] as String),
      isMyFavorite: json['isMyFavorite'] as bool,
    );

Map<String, dynamic> _$PlaylistDetailToJson(PlaylistDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tracks': instance.tracks.map((e) => e.toJson()).toList(),
      'creator': instance.creator.toJson(),
      'coverUrl': instance.coverUrl,
      'trackCount': instance.trackCount,
      'subscribed': instance.subscribed,
      'subscribedCount': instance.subscribedCount,
      'shareCount': instance.shareCount,
      'playCount': instance.playCount,
      'trackUpdateTime': instance.trackUpdateTime,
      'name': instance.name,
      'description': instance.description,
      'commentCount': instance.commentCount,
      'trackIds': instance.trackIds,
      'createTime': instance.createTime.toIso8601String(),
      'isMyFavorite': instance.isMyFavorite,
    };
