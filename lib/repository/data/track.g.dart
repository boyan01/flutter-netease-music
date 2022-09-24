// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackAdapter extends TypeAdapter<Track> {
  @override
  final int typeId = 2;

  @override
  Track read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Track(
      id: fields[0] as int,
      uri: fields[1] as String?,
      name: fields[2] as String,
      artists: (fields[3] as List).cast<ArtistMini>(),
      album: fields[4] as AlbumMini?,
      imageUrl: fields[5] as String?,
      duration: fields[6] as Duration,
      type: fields[7] as TrackType,
    );
  }

  @override
  void write(BinaryWriter writer, Track obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uri)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.artists)
      ..writeByte(4)
      ..write(obj.album)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ArtistMiniAdapter extends TypeAdapter<ArtistMini> {
  @override
  final int typeId = 4;

  @override
  ArtistMini read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArtistMini(
      id: fields[0] as int,
      name: fields[1] as String,
      imageUrl: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ArtistMini obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistMiniAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlbumMiniAdapter extends TypeAdapter<AlbumMini> {
  @override
  final int typeId = 5;

  @override
  AlbumMini read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlbumMini(
      id: fields[0] as int,
      picUri: fields[1] as String?,
      name: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AlbumMini obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.picUri)
      ..writeByte(2)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumMiniAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TrackTypeAdapter extends TypeAdapter<TrackType> {
  @override
  final int typeId = 3;

  @override
  TrackType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TrackType.free;
      case 1:
        return TrackType.payAlbum;
      case 2:
        return TrackType.vip;
      case 3:
        return TrackType.cloud;
      case 4:
        return TrackType.noCopyright;
      default:
        return TrackType.free;
    }
  }

  @override
  void write(BinaryWriter writer, TrackType obj) {
    switch (obj) {
      case TrackType.free:
        writer.writeByte(0);
        break;
      case TrackType.payAlbum:
        writer.writeByte(1);
        break;
      case TrackType.vip:
        writer.writeByte(2);
        break;
      case TrackType.cloud:
        writer.writeByte(3);
        break;
      case TrackType.noCopyright:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map json) => Track(
      id: json['id'] as int,
      uri: json['uri'] as String?,
      name: json['name'] as String,
      artists: (json['artists'] as List<dynamic>)
          .map((e) => ArtistMini.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      album: json['album'] == null
          ? null
          : AlbumMini.fromJson(Map<String, dynamic>.from(json['album'] as Map)),
      imageUrl: json['imageUrl'] as String?,
      duration: Duration(microseconds: json['duration'] as int),
      type: $enumDecode(_$TrackTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'id': instance.id,
      'uri': instance.uri,
      'name': instance.name,
      'artists': instance.artists.map((e) => e.toJson()).toList(),
      'album': instance.album?.toJson(),
      'imageUrl': instance.imageUrl,
      'duration': instance.duration.inMicroseconds,
      'type': _$TrackTypeEnumMap[instance.type]!,
    };

const _$TrackTypeEnumMap = {
  TrackType.free: 'free',
  TrackType.payAlbum: 'payAlbum',
  TrackType.vip: 'vip',
  TrackType.cloud: 'cloud',
  TrackType.noCopyright: 'noCopyright',
};

ArtistMini _$ArtistMiniFromJson(Map json) => ArtistMini(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ArtistMiniToJson(ArtistMini instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };

AlbumMini _$AlbumMiniFromJson(Map json) => AlbumMini(
      id: json['id'] as int,
      picUri: json['picUrl'] as String?,
      name: json['name'] as String,
    );

Map<String, dynamic> _$AlbumMiniToJson(AlbumMini instance) => <String, dynamic>{
      'id': instance.id,
      'picUrl': instance.picUri,
      'name': instance.name,
    };
