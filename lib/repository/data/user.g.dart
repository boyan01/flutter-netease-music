// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map json) => User(
      userId: json['userId'] as int,
      avatarUrl: json['avatarUrl'] as String,
      backgroundUrl: json['backgroundUrl'] as String,
      vipType: json['vipType'] as int,
      createTime: json['createTime'] as int,
      nickname: json['nickname'] as String,
      followed: json['followed'] as bool,
      description: json['description'] as String,
      detailDescription: json['detailDescription'] as String,
      followedUsers: json['followedUsers'] as int,
      followers: json['followers'] as int,
      allSubscribedCount: json['allSubscribedCount'] as int,
      playlistBeSubscribedCount: json['playlistBeSubscribedCount'] as int,
      playlistCount: json['playlistCount'] as int,
      level: json['level'] as int,
      eventCount: json['eventCount'] as int,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'avatarUrl': instance.avatarUrl,
      'backgroundUrl': instance.backgroundUrl,
      'vipType': instance.vipType,
      'createTime': instance.createTime,
      'nickname': instance.nickname,
      'followed': instance.followed,
      'description': instance.description,
      'detailDescription': instance.detailDescription,
      'followedUsers': instance.followedUsers,
      'followers': instance.followers,
      'allSubscribedCount': instance.allSubscribedCount,
      'playlistBeSubscribedCount': instance.playlistBeSubscribedCount,
      'playlistCount': instance.playlistCount,
      'eventCount': instance.eventCount,
      'level': instance.level,
    };
