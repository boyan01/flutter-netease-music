// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'netease_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NeteaseUser _$NeteaseUserFromJson(Map json) => NeteaseUser(
      user: User.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      loginByQrCode: json['loginByQrCode'] as bool,
    );

Map<String, dynamic> _$NeteaseUserToJson(NeteaseUser instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'loginByQrCode': instance.loginByQrCode,
    };
