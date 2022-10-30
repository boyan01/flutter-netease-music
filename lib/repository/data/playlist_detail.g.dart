// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_detail.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistDetailAdapter extends TypeAdapter<PlaylistDetail> {
  @override
  final int typeId = 1;

  @override
  PlaylistDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaylistDetail(
      id: fields[0] as int,
      tracks: (fields[1] as List).cast<Track>(),
      creator: fields[2] as User,
      coverUrl: fields[3] as String,
      trackCount: fields[4] as int,
      subscribed: fields[5] as bool,
      subscribedCount: fields[6] as int,
      shareCount: fields[7] as int,
      playCount: fields[8] as int,
      trackUpdateTime: fields[9] as int,
      name: fields[10] as String,
      description: fields[11] as String,
      commentCount: fields[12] as int,
      trackIds: (fields[13] as List).cast<int>(),
      createTime: fields[14] as DateTime,
      isFavorite: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlaylistDetail obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tracks)
      ..writeByte(2)
      ..write(obj.creator)
      ..writeByte(3)
      ..write(obj.coverUrl)
      ..writeByte(4)
      ..write(obj.trackCount)
      ..writeByte(5)
      ..write(obj.subscribed)
      ..writeByte(6)
      ..write(obj.subscribedCount)
      ..writeByte(7)
      ..write(obj.shareCount)
      ..writeByte(8)
      ..write(obj.playCount)
      ..writeByte(9)
      ..write(obj.trackUpdateTime)
      ..writeByte(10)
      ..write(obj.name)
      ..writeByte(11)
      ..write(obj.description)
      ..writeByte(12)
      ..write(obj.commentCount)
      ..writeByte(13)
      ..write(obj.trackIds)
      ..writeByte(14)
      ..write(obj.createTime)
      ..writeByte(15)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      isFavorite: json['isFavorite'] as bool,
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
      'isFavorite': instance.isFavorite,
    };
