class User {
  Object locationInfo;
  int userId;
  Object remarkName;
  Object expertTags;
  String nickname;
  int userType;
  VipRights vipRights;
  int vipType;
  int authStatus;
  String avatarUrl;
  Object experts;

  User.fromJsonMap(Map<String, dynamic> map)
      : locationInfo = map["locationInfo"],
        userId = map["userId"],
        remarkName = map["remarkName"],
        expertTags = map["expertTags"],
        nickname = map["nickname"],
        userType = map["userType"],
        vipRights = map["vipRights"] == null
            ? null
            : VipRights.fromJsonMap(map["vipRights"]),
        vipType = map["vipType"],
        authStatus = map["authStatus"],
        avatarUrl = map["avatarUrl"],
        experts = map["experts"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['locationInfo'] = locationInfo;
    data['userId'] = userId;
    data['remarkName'] = remarkName;
    data['expertTags'] = expertTags;
    data['nickname'] = nickname;
    data['userType'] = userType;
    data['vipRights'] = vipRights == null ? null : vipRights.toJson();
    data['vipType'] = vipType;
    data['authStatus'] = authStatus;
    data['avatarUrl'] = avatarUrl;
    data['experts'] = experts;
    return data;
  }
}

class VipRights {
  Associator associator;
  Object musicPackage;
  int redVipAnnualCount;

  VipRights.fromJsonMap(Map<String, dynamic> map)
      : associator = map["associator"] == null
            ? null
            : Associator.fromJsonMap(map["associator"]),
        musicPackage = map["musicPackage"],
        redVipAnnualCount = map["redVipAnnualCount"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['associator'] = associator == null ? null : associator.toJson();
    data['musicPackage'] = musicPackage;
    data['redVipAnnualCount'] = redVipAnnualCount;
    return data;
  }
}

class Associator {
  int vipCode;
  bool rights;

  Associator.fromJsonMap(Map<String, dynamic> map)
      : vipCode = map["vipCode"],
        rights = map["rights"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vipCode'] = vipCode;
    data['rights'] = rights;
    return data;
  }
}
