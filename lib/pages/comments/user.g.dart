// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map json) => User(
      locationInfo: json['locationInfo'],
      userId: json['userId'] as int?,
      remarkName: json['remarkName'],
      expertTags: json['expertTags'],
      nickname: json['nickname'] as String?,
      userType: json['userType'] as int?,
      vipRights: json['vipRights'] == null
          ? null
          : VipRights.fromJson(json['vipRights'] as Map),
      vipType: json['vipType'] as int?,
      authStatus: json['authStatus'] as int?,
      avatarUrl: json['avatarUrl'] as String?,
      experts: json['experts'],
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'locationInfo': instance.locationInfo,
      'userId': instance.userId,
      'remarkName': instance.remarkName,
      'expertTags': instance.expertTags,
      'nickname': instance.nickname,
      'userType': instance.userType,
      'vipRights': instance.vipRights?.toJson(),
      'vipType': instance.vipType,
      'authStatus': instance.authStatus,
      'avatarUrl': instance.avatarUrl,
      'experts': instance.experts,
    };

VipRights _$VipRightsFromJson(Map json) => VipRights(
      associator: json['associator'] == null
          ? null
          : Associator.fromJson(json['associator'] as Map),
      musicPackage: json['musicPackage'],
      redVipAnnualCount: json['redVipAnnualCount'] as int?,
    );

Map<String, dynamic> _$VipRightsToJson(VipRights instance) => <String, dynamic>{
      'associator': instance.associator?.toJson(),
      'musicPackage': instance.musicPackage,
      'redVipAnnualCount': instance.redVipAnnualCount,
    };

Associator _$AssociatorFromJson(Map json) => Associator(
      vipCode: json['vipCode'] as int?,
      rights: json['rights'] as bool?,
    );

Map<String, dynamic> _$AssociatorToJson(Associator instance) =>
    <String, dynamic>{
      'vipCode': instance.vipCode,
      'rights': instance.rights,
    };
