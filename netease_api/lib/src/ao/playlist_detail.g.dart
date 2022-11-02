// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackPc _$TrackPcFromJson(Map<String, dynamic> json) => TrackPc(
      nickname: json['nickname'] as String,
      userId: json['uid'] as int,
      filename: json['fn'] as String,
      cid: json['cid'] as String,
      album: json['alb'] as String,
      artist: json['ar'] as String,
      songName: json['sn'] as String,
      bitrate: json['br'] as int,
    );

Map<String, dynamic> _$TrackPcToJson(TrackPc instance) => <String, dynamic>{
      'nickname': instance.nickname,
      'uid': instance.userId,
      'fn': instance.filename,
      'cid': instance.cid,
      'alb': instance.album,
      'ar': instance.artist,
      'sn': instance.songName,
      'br': instance.bitrate,
    };
