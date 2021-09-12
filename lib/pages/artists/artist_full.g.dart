// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_full.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArtistFull _$ArtistFullFromJson(Map json) {
  return ArtistFull(
    img1v1Url: json['img1v1Url'] as String?,
    picUrl: json['picUrl'] as String?,
    trans: json['trans'] as String?,
    briefDesc: json['briefDesc'] as String?,
    name: json['name'] as String?,
    picIdStr: json['picIdStr'] as String?,
    followed: json['followed'] as bool?,
    topicPerson: json['topicPerson'] as int?,
    musicSize: json['musicSize'] as int?,
    albumSize: json['albumSize'] as int?,
    id: json['id'] as int?,
    accountId: json['accountId'] as int?,
    mvSize: json['mvSize'] as int?,
    img1v1Id: json['img1v1Id'] as num?,
    picId: json['picId'] as num?,
    publishTime: json['publishTime'] as num?,
    alias: (json['alias'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$ArtistFullToJson(ArtistFull instance) =>
    <String, dynamic>{
      'img1v1Url': instance.img1v1Url,
      'picUrl': instance.picUrl,
      'trans': instance.trans,
      'briefDesc': instance.briefDesc,
      'name': instance.name,
      'picIdStr': instance.picIdStr,
      'followed': instance.followed,
      'topicPerson': instance.topicPerson,
      'musicSize': instance.musicSize,
      'albumSize': instance.albumSize,
      'id': instance.id,
      'accountId': instance.accountId,
      'mvSize': instance.mvSize,
      'img1v1Id': instance.img1v1Id,
      'picId': instance.picId,
      'publishTime': instance.publishTime,
      'alias': instance.alias,
    };
