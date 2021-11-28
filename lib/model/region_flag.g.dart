// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region_flag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegionFlag _$RegionFlagFromJson(Map json) => RegionFlag(
      code: json['code'] as String,
      emoji: json['emoji'] as String,
      unicode: json['unicode'] as String,
      name: json['name'] as String,
      dialCode: json['dialCode'] as String?,
    );

Map<String, dynamic> _$RegionFlagToJson(RegionFlag instance) =>
    <String, dynamic>{
      'code': instance.code,
      'emoji': instance.emoji,
      'unicode': instance.unicode,
      'name': instance.name,
      'dialCode': instance.dialCode,
    };
