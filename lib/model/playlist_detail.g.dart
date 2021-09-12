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
    trackCount: json['trackCount'] as int,
    description: json['description'] as String?,
    subscribed: json['subscribed'] as bool,
    subscribedCount: json['subscribedCount'] as int?,
    commentCount: json['commentCount'] as int?,
    shareCount: json['shareCount'] as int?,
    playCount: json['playCount'] as int?,
    trackUpdateTime: json['trackUpdateTime'] as int? ?? 0,
    trackIds: (json['trackIds'] as List<dynamic>?)
            ?.map((e) => TrackId.fromJson(e as Map))
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$PlaylistDetailToJson(PlaylistDetail instance) =>
    <String, dynamic>{
      'tracks': instance.musicList.map((e) => e.toJson()).toList(),
      'trackIds': instance.trackIds.map((e) => e.toJson()).toList(),
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
      'trackUpdateTime': instance.trackUpdateTime,
      'creator': instance.creator,
    };

TrackId _$TrackIdFromJson(Map json) {
  return TrackId(
    id: json['id'] as int,
    v: json['v'] as int,
    t: json['t'] as int,
    at: json['at'] as int,
    uid: json['uid'] as int,
    rcmdReason: json['rcmdReason'] as String,
  );
}

Map<String, dynamic> _$TrackIdToJson(TrackId instance) => <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      't': instance.t,
      'at': instance.at,
      'uid': instance.uid,
      'rcmdReason': instance.rcmdReason,
    };
