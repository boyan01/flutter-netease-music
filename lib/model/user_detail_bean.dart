class UserDetail {
  final int level;
  final int listenSongs;
  final UserPoint userPoint;
  final bool mobileSign;
  final bool pcSign;
  final UserProfile profile;
  final bool peopleCanSeeMyPlayRecord;
  final List<Bindings> bindings;
  final bool adValid;
  final int code;
  final int createTime;
  final int createDays;

  UserDetail.fromJsonMap(Map<String, dynamic> map)
      : level = map["level"],
        listenSongs = map["listenSongs"],
        userPoint = UserPoint.fromJsonMap(map["userPoint"]),
        mobileSign = map["mobileSign"],
        pcSign = map["pcSign"],
        profile = UserProfile.fromJsonMap(map["profile"]),
        peopleCanSeeMyPlayRecord = map["peopleCanSeeMyPlayRecord"],
        bindings = List<Bindings>.from(map["bindings"].map((it) => Bindings.fromJsonMap(it))),
        adValid = map["adValid"],
        code = map["code"],
        createTime = map["createTime"],
        createDays = map["createDays"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['level'] = level;
    data['listenSongs'] = listenSongs;
    data['userPoint'] = userPoint == null ? null : userPoint.toJson();
    data['mobileSign'] = mobileSign;
    data['pcSign'] = pcSign;
    data['profile'] = profile == null ? null : profile.toJson();
    data['peopleCanSeeMyPlayRecord'] = peopleCanSeeMyPlayRecord;
    data['bindings'] = bindings != null ? this.bindings.map((v) => v.toJson()).toList() : null;
    data['adValid'] = adValid;
    data['code'] = code;
    data['createTime'] = createTime;
    data['createDays'] = createDays;
    return data;
  }
}

class UserPoint {
  final int userId;
  final int balance;
  final int updateTime;
  final int version;
  final int status;
  final int blockBalance;

  UserPoint.fromJsonMap(Map<String, dynamic> map)
      : userId = map["userId"],
        balance = map["balance"],
        updateTime = map["updateTime"],
        version = map["version"],
        status = map["status"],
        blockBalance = map["blockBalance"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = userId;
    data['balance'] = balance;
    data['updateTime'] = updateTime;
    data['version'] = version;
    data['status'] = status;
    data['blockBalance'] = blockBalance;
    return data;
  }
}

class UserProfile {
  final String detailDescription;
  final bool followed;
  final String avatarImgIdStr;
  final String backgroundImgIdStr;
  final bool defaultAvatar;
  final String avatarUrl;
  final int userId;
  final int gender;
  final int accountStatus;
  final int vipType;
  final int avatarImgId;
  final String nickname;
  final int birthday;
  final int city;
  final int province;
  final int djStatus;
  final Object experts;
  final int backgroundImgId;
  final int userType;
  final bool mutual;
  final Object remarkName;
  final Object expertTags;
  final int authStatus;
  final String description;
  final String backgroundUrl;
  final String signature;
  final int authority;
  final List<Object> artistIdentity;
  final int followeds;
  final int follows;
  final int cCount;
  final bool blacklist;
  final int eventCount;
  final int sDJPCount;
  final int allSubscribedCount;
  final int playlistCount;
  final int playlistBeSubscribedCount;
  final int sCount;

  UserProfile.fromJsonMap(Map<String, dynamic> map)
      : detailDescription = map["detailDescription"],
        followed = map["followed"],
        avatarImgIdStr = map["avatarImgIdStr"],
        backgroundImgIdStr = map["backgroundImgIdStr"],
        defaultAvatar = map["defaultAvatar"],
        avatarUrl = map["avatarUrl"],
        userId = map["userId"],
        gender = map["gender"],
        accountStatus = map["accountStatus"],
        vipType = map["vipType"],
        avatarImgId = map["avatarImgId"],
        nickname = map["nickname"],
        birthday = map["birthday"],
        city = map["city"],
        province = map["province"],
        djStatus = map["djStatus"],
        experts = map["experts"],
        backgroundImgId = map["backgroundImgId"],
        userType = map["userType"],
        mutual = map["mutual"],
        remarkName = map["remarkName"],
        expertTags = map["expertTags"],
        authStatus = map["authStatus"],
        description = map["description"],
        backgroundUrl = map["backgroundUrl"],
        signature = map["signature"],
        authority = map["authority"],
        artistIdentity = map["artistIdentity"],
        followeds = map["followeds"],
        follows = map["follows"],
        cCount = map["cCount"],
        blacklist = map["blacklist"],
        eventCount = map["eventCount"],
        sDJPCount = map["sDJPCount"],
        allSubscribedCount = map["allSubscribedCount"],
        playlistCount = map["playlistCount"],
        playlistBeSubscribedCount = map["playlistBeSubscribedCount"],
        sCount = map["sCount"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['detailDescription'] = detailDescription;
    data['followed'] = followed;
    data['avatarImgIdStr'] = avatarImgIdStr;
    data['backgroundImgIdStr'] = backgroundImgIdStr;
    data['defaultAvatar'] = defaultAvatar;
    data['avatarUrl'] = avatarUrl;
    data['userId'] = userId;
    data['gender'] = gender;
    data['accountStatus'] = accountStatus;
    data['vipType'] = vipType;
    data['avatarImgId'] = avatarImgId;
    data['nickname'] = nickname;
    data['birthday'] = birthday;
    data['city'] = city;
    data['province'] = province;
    data['djStatus'] = djStatus;
    data['experts'] = experts;
    data['backgroundImgId'] = backgroundImgId;
    data['userType'] = userType;
    data['mutual'] = mutual;
    data['remarkName'] = remarkName;
    data['expertTags'] = expertTags;
    data['authStatus'] = authStatus;
    data['description'] = description;
    data['backgroundUrl'] = backgroundUrl;
    data['signature'] = signature;
    data['authority'] = authority;
    data['artistIdentity'] = artistIdentity;
    data['followeds'] = followeds;
    data['follows'] = follows;
    data['cCount'] = cCount;
    data['blacklist'] = blacklist;
    data['eventCount'] = eventCount;
    data['sDJPCount'] = sDJPCount;
    data['allSubscribedCount'] = allSubscribedCount;
    data['playlistCount'] = playlistCount;
    data['playlistBeSubscribedCount'] = playlistBeSubscribedCount;
    data['sCount'] = sCount;
    return data;
  }
}

class Bindings {
  final int refreshTime;
  final int expiresIn;
  final int userId;
  final Object tokenJsonStr;
  final String url;
  final bool expired;
  final int bindingTime;
  final int id;
  final int type;

  Bindings.fromJsonMap(Map<String, dynamic> map)
      : refreshTime = map["refreshTime"],
        expiresIn = map["expiresIn"],
        userId = map["userId"],
        tokenJsonStr = map["tokenJsonStr"],
        url = map["url"],
        expired = map["expired"],
        bindingTime = map["bindingTime"],
        id = map["id"],
        type = map["type"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['refreshTime'] = refreshTime;
    data['expiresIn'] = expiresIn;
    data['userId'] = userId;
    data['tokenJsonStr'] = tokenJsonStr;
    data['url'] = url;
    data['expired'] = expired;
    data['bindingTime'] = bindingTime;
    data['id'] = id;
    data['type'] = type;
    return data;
  }
}
