// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_video_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicVideoDetailResult _$MusicVideoDetailResultFromJson(
        Map<String, dynamic> json) =>
    MusicVideoDetailResult(
      loadingPic: json['loadingPic'] as String,
      bufferPic: json['bufferPic'] as String,
      loadingPicFS: json['loadingPicFS'] as String,
      bufferPicFS: json['bufferPicFS'] as String,
      subscribed: json['subed'] as bool,
      data: MusicVideoDetail.fromJson(json['data'] as Map<String, dynamic>),
      code: json['code'] as int,
    );

Map<String, dynamic> _$MusicVideoDetailResultToJson(
        MusicVideoDetailResult instance) =>
    <String, dynamic>{
      'loadingPic': instance.loadingPic,
      'bufferPic': instance.bufferPic,
      'loadingPicFS': instance.loadingPicFS,
      'bufferPicFS': instance.bufferPicFS,
      'subed': instance.subscribed,
      'data': instance.data,
      'code': instance.code,
    };

MusicVideoDetail _$MusicVideoDetailFromJson(Map<String, dynamic> json) =>
    MusicVideoDetail(
      artists: (json['artists'] as List<dynamic>)
          .map((e) => ArtistItem.fromJson(e as Map<String, dynamic>?))
          .toList(),
      id: json['id'] as int?,
      name: json['name'] as String?,
      artistId: json['artistId'] as int?,
      artistName: json['artistName'] as String?,
      briefDesc: json['briefDesc'] as String?,
      desc: json['desc'] as String?,
      cover: json['cover'] as String?,
      coverId: json['coverId'] as int?,
      playCount: json['playCount'] as int?,
      subCount: json['subCount'] as int?,
      shareCount: json['shareCount'] as int?,
      likeCount: json['likeCount'] as int?,
      commentCount: json['commentCount'] as int?,
      duration: json['duration'] as int?,
      nType: json['nType'] as int?,
      publishTime: json['publishTime'] as String?,
      brs: json['brs'] as Map<String, dynamic>?,
      isReward: json['isReward'] as bool?,
      commentThreadId: json['commentThreadId'] as String?,
    );

Map<String, dynamic> _$MusicVideoDetailToJson(MusicVideoDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'artistId': instance.artistId,
      'artistName': instance.artistName,
      'briefDesc': instance.briefDesc,
      'desc': instance.desc,
      'cover': instance.cover,
      'coverId': instance.coverId,
      'playCount': instance.playCount,
      'subCount': instance.subCount,
      'shareCount': instance.shareCount,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'duration': instance.duration,
      'nType': instance.nType,
      'publishTime': instance.publishTime,
      'brs': instance.brs,
      'artists': instance.artists,
      'isReward': instance.isReward,
      'commentThreadId': instance.commentThreadId,
    };
