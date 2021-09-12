import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
@immutable
class User {
  const User({
    this.locationInfo,
    this.userId,
    this.remarkName,
    this.expertTags,
    this.nickname,
    this.userType,
    this.vipRights,
    this.vipType,
    this.authStatus,
    this.avatarUrl,
    this.experts,
  });

  factory User.fromJsonMap(Map<String, dynamic> map) => _$UserFromJson(map);

  final Object? locationInfo;
  final int? userId;
  final Object? remarkName;
  final Object? expertTags;
  final String? nickname;
  final int? userType;
  final VipRights? vipRights;
  final int? vipType;
  final int? authStatus;
  final String? avatarUrl;
  final Object? experts;

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
@immutable
class VipRights {
  const VipRights({
    this.associator,
    this.musicPackage,
    this.redVipAnnualCount,
  });

  factory VipRights.fromJson(Map json) => _$VipRightsFromJson(json);

  final Associator? associator;
  final Object? musicPackage;
  final int? redVipAnnualCount;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['associator'] = associator == null ? null : associator!.toJson();
    data['musicPackage'] = musicPackage;
    data['redVipAnnualCount'] = redVipAnnualCount;
    return data;
  }
}

@JsonSerializable()
class Associator {
  Associator({
    this.vipCode,
    this.rights,
  });

  factory Associator.fromJson(Map map) => _$AssociatorFromJson(map);

  int? vipCode;
  bool? rights;

  Map<String, dynamic> toJson() => _$AssociatorToJson(this);
}
