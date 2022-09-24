// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 7;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      userId: fields[0] as int,
      avatarUrl: fields[1] as String,
      backgroundUrl: fields[2] as String,
      vipType: fields[3] as int,
      createTime: fields[4] as int,
      nickname: fields[5] as String,
      followed: fields[6] as bool,
      description: fields[7] as String,
      detailDescription: fields[8] as String,
      followedUsers: fields[9] as int,
      followers: fields[10] as int,
      allSubscribedCount: fields[11] as int,
      playlistBeSubscribedCount: fields[12] as int,
      playlistCount: fields[13] as int,
      level: fields[15] as int,
      eventCount: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.avatarUrl)
      ..writeByte(2)
      ..write(obj.backgroundUrl)
      ..writeByte(3)
      ..write(obj.vipType)
      ..writeByte(4)
      ..write(obj.createTime)
      ..writeByte(5)
      ..write(obj.nickname)
      ..writeByte(6)
      ..write(obj.followed)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.detailDescription)
      ..writeByte(9)
      ..write(obj.followedUsers)
      ..writeByte(10)
      ..write(obj.followers)
      ..writeByte(11)
      ..write(obj.allSubscribedCount)
      ..writeByte(12)
      ..write(obj.playlistBeSubscribedCount)
      ..writeByte(13)
      ..write(obj.playlistCount)
      ..writeByte(14)
      ..write(obj.eventCount)
      ..writeByte(15)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
