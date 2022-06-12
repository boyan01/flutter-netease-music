import 'safe_convert.dart';

class UserDetail {
  UserDetail({
    this.level = 0,
    this.listenSongs = 0,
    required this.userPoint,
    this.mobileSign = false,
    this.pcSign = false,
    required this.profile,
    this.peopleCanSeeMyPlayRecord = false,
    required this.bindings,
    this.adValid = false,
    this.code = 0,
    this.createTime = 0,
    this.createDays = 0,
    required this.profileVillageInfo,
  });

  factory UserDetail.fromJson(Map<String, dynamic>? json) => UserDetail(
        level: asInt(json, 'level'),
        listenSongs: asInt(json, 'listenSongs'),
        userPoint: UserPoint.fromJson(asMap(json, 'userPoint')),
        mobileSign: asBool(json, 'mobileSign'),
        pcSign: asBool(json, 'pcSign'),
        profile: Profile.fromJson(asMap(json, 'profile')),
        peopleCanSeeMyPlayRecord: asBool(json, 'peopleCanSeeMyPlayRecord'),
        bindings: asList(json, 'bindings')
            .map((e) => BindingsItem.fromJson(e))
            .toList(),
        adValid: asBool(json, 'adValid'),
        code: asInt(json, 'code'),
        createTime: asInt(json, 'createTime'),
        createDays: asInt(json, 'createDays'),
        profileVillageInfo:
            ProfileVillageInfo.fromJson(asMap(json, 'profileVillageInfo')),
      );

  final int level;
  final int listenSongs;
  final UserPoint userPoint;
  final bool mobileSign;
  final bool pcSign;
  final Profile profile;
  final bool peopleCanSeeMyPlayRecord;
  final List<BindingsItem> bindings;
  final bool adValid;
  final int code;
  final int createTime;
  final int createDays;
  final ProfileVillageInfo profileVillageInfo;

  Map<String, dynamic> toJson() => {
        'level': level,
        'listenSongs': listenSongs,
        'userPoint': userPoint.toJson(),
        'mobileSign': mobileSign,
        'pcSign': pcSign,
        'profile': profile.toJson(),
        'peopleCanSeeMyPlayRecord': peopleCanSeeMyPlayRecord,
        'bindings': bindings.map((e) => e.toJson()),
        'adValid': adValid,
        'code': code,
        'createTime': createTime,
        'createDays': createDays,
        'profileVillageInfo': profileVillageInfo.toJson(),
      };
}

class UserPoint {
  UserPoint({
    this.userId = 0,
    this.balance = 0,
    this.updateTime = 0,
    this.version = 0,
    this.status = 0,
    this.blockBalance = 0,
  });

  factory UserPoint.fromJson(Map<String, dynamic>? json) => UserPoint(
        userId: asInt(json, 'userId'),
        balance: asInt(json, 'balance'),
        updateTime: asInt(json, 'updateTime'),
        version: asInt(json, 'version'),
        status: asInt(json, 'status'),
        blockBalance: asInt(json, 'blockBalance'),
      );

  final int userId;
  final int balance;
  final int updateTime;
  final int version;
  final int status;
  final int blockBalance;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'balance': balance,
        'updateTime': updateTime,
        'version': version,
        'status': status,
        'blockBalance': blockBalance,
      };
}

class Profile {
  Profile({
    required this.privacyItemUnlimit,
    this.avatarDetail,
    this.userId = 0,
    this.avatarUrl = '',
    this.backgroundImgId = 0,
    this.backgroundUrl = '',
    this.djStatus = 0,
    this.province = 0,
    this.vipType = 0,
    this.followed = false,
    this.city = 0,
    this.createTime = 0,
    this.userType = 0,
    this.authStatus = 0,
    this.detailDescription = '',
    required this.experts,
    this.expertTags,
    this.defaultAvatar = false,
    this.avatarImgIdStr = '',
    this.description = '',
    this.backgroundImgIdStr = '',
    this.mutual = false,
    this.remarkName,
    this.avatarImgId = 0,
    this.birthday = 0,
    this.gender = 0,
    this.nickname = '',
    this.accountStatus = 0,
    this.signature = '',
    this.authority = 0,
    this.followeds = 0,
    this.follows = 0,
    this.blacklist = false,
    this.eventCount = 0,
    this.allSubscribedCount = 0,
    this.playlistBeSubscribedCount = 0,
    this.followTime,
    this.followMe = false,
    required this.artistIdentity,
    this.cCount = 0,
    this.sDJPCount = 0,
    this.playlistCount = 0,
    this.sCount = 0,
    this.newFollows = 0,
  });

  factory Profile.fromJson(Map<String, dynamic>? json) => Profile(
        privacyItemUnlimit:
            PrivacyItemUnlimit.fromJson(asMap(json, 'privacyItemUnlimit')),
        avatarDetail: asString(json, 'avatarDetail'),
        userId: asInt(json, 'userId'),
        avatarUrl: asString(json, 'avatarUrl'),
        backgroundImgId: asInt(json, 'backgroundImgId'),
        backgroundUrl: asString(json, 'backgroundUrl'),
        djStatus: asInt(json, 'djStatus'),
        province: asInt(json, 'province'),
        vipType: asInt(json, 'vipType'),
        followed: asBool(json, 'followed'),
        city: asInt(json, 'city'),
        createTime: asInt(json, 'createTime'),
        userType: asInt(json, 'userType'),
        authStatus: asInt(json, 'authStatus'),
        detailDescription: asString(json, 'detailDescription'),
        experts: asMap(json, 'experts'),
        expertTags: asString(json, 'expertTags'),
        defaultAvatar: asBool(json, 'defaultAvatar'),
        avatarImgIdStr: asString(json, 'avatarImgIdStr'),
        description: asString(json, 'description'),
        backgroundImgIdStr: asString(json, 'backgroundImgIdStr'),
        mutual: asBool(json, 'mutual'),
        remarkName: asString(json, 'remarkName'),
        avatarImgId: asInt(json, 'avatarImgId'),
        birthday: asInt(json, 'birthday'),
        gender: asInt(json, 'gender'),
        nickname: asString(json, 'nickname'),
        accountStatus: asInt(json, 'accountStatus'),
        signature: asString(json, 'signature'),
        authority: asInt(json, 'authority'),
        followeds: asInt(json, 'followeds'),
        follows: asInt(json, 'follows'),
        blacklist: asBool(json, 'blacklist'),
        eventCount: asInt(json, 'eventCount'),
        allSubscribedCount: asInt(json, 'allSubscribedCount'),
        playlistBeSubscribedCount: asInt(json, 'playlistBeSubscribedCount'),
        followTime: asString(json, 'followTime'),
        followMe: asBool(json, 'followMe'),
        artistIdentity: asList(json, 'artistIdentity'),
        cCount: asInt(json, 'cCount'),
        sDJPCount: asInt(json, 'sDJPCount'),
        playlistCount: asInt(json, 'playlistCount'),
        sCount: asInt(json, 'sCount'),
        newFollows: asInt(json, 'newFollows'),
      );

  final PrivacyItemUnlimit privacyItemUnlimit;
  final dynamic avatarDetail;
  final int userId;
  final String avatarUrl;
  final int backgroundImgId;
  final String backgroundUrl;
  final int djStatus;
  final int province;
  final int vipType;
  final bool followed;
  final int city;
  final int createTime;
  final int userType;
  final int authStatus;
  final String detailDescription;
  final Map<String, dynamic> experts;
  final dynamic expertTags;
  final bool defaultAvatar;
  final String avatarImgIdStr;
  final String description;
  final String backgroundImgIdStr;
  final bool mutual;
  final dynamic remarkName;
  final int avatarImgId;
  final int birthday;
  final int gender;
  final String nickname;
  final int accountStatus;
  final String signature;
  final int authority;
  final int followeds;
  final int follows;
  final bool blacklist;
  final int eventCount;
  final int allSubscribedCount;
  final int playlistBeSubscribedCount;
  final dynamic followTime;
  final bool followMe;
  final List<dynamic> artistIdentity;
  final int cCount;
  final int sDJPCount;
  final int playlistCount;
  final int sCount;
  final int newFollows;

  Map<String, dynamic> toJson() => {
        'privacyItemUnlimit': privacyItemUnlimit.toJson(),
        'avatarDetail': avatarDetail,
        'userId': userId,
        'avatarUrl': avatarUrl,
        'backgroundImgId': backgroundImgId,
        'backgroundUrl': backgroundUrl,
        'djStatus': djStatus,
        'province': province,
        'vipType': vipType,
        'followed': followed,
        'city': city,
        'createTime': createTime,
        'userType': userType,
        'authStatus': authStatus,
        'detailDescription': detailDescription,
        'experts': experts,
        'expertTags': expertTags,
        'defaultAvatar': defaultAvatar,
        'avatarImgIdStr': avatarImgIdStr,
        'description': description,
        'backgroundImgIdStr': backgroundImgIdStr,
        'mutual': mutual,
        'remarkName': remarkName,
        'avatarImgId': avatarImgId,
        'birthday': birthday,
        'gender': gender,
        'nickname': nickname,
        'accountStatus': accountStatus,
        'signature': signature,
        'authority': authority,
        'followeds': followeds,
        'follows': follows,
        'blacklist': blacklist,
        'eventCount': eventCount,
        'allSubscribedCount': allSubscribedCount,
        'playlistBeSubscribedCount': playlistBeSubscribedCount,
        'avatarImgId_str': avatarImgIdStr,
        'followTime': followTime,
        'followMe': followMe,
        'artistIdentity': artistIdentity.map((e) => e),
        'cCount': cCount,
        'sDJPCount': sDJPCount,
        'playlistCount': playlistCount,
        'sCount': sCount,
        'newFollows': newFollows,
      };
}

class PrivacyItemUnlimit {
  PrivacyItemUnlimit({
    this.area = false,
    this.college = false,
    this.age = false,
    this.villageAge = false,
  });

  factory PrivacyItemUnlimit.fromJson(Map<String, dynamic>? json) =>
      PrivacyItemUnlimit(
        area: asBool(json, 'area'),
        college: asBool(json, 'college'),
        age: asBool(json, 'age'),
        villageAge: asBool(json, 'villageAge'),
      );

  final bool area;
  final bool college;
  final bool age;
  final bool villageAge;

  Map<String, dynamic> toJson() => {
        'area': area,
        'college': college,
        'age': age,
        'villageAge': villageAge,
      };
}

class BindingsItem {
  BindingsItem({
    this.userId = 0,
    this.expiresIn = 0,
    this.refreshTime = 0,
    this.bindingTime = 0,
    this.tokenJsonStr,
    this.expired = false,
    this.url = '',
    this.id = 0,
    this.type = 0,
  });

  factory BindingsItem.fromJson(Map<String, dynamic>? json) => BindingsItem(
        userId: asInt(json, 'userId'),
        expiresIn: asInt(json, 'expiresIn'),
        refreshTime: asInt(json, 'refreshTime'),
        bindingTime: asInt(json, 'bindingTime'),
        tokenJsonStr: asString(json, 'tokenJsonStr'),
        expired: asBool(json, 'expired'),
        url: asString(json, 'url'),
        id: asInt(json, 'id'),
        type: asInt(json, 'type'),
      );

  final int userId;
  final int expiresIn;
  final int refreshTime;
  final int bindingTime;
  final dynamic tokenJsonStr;
  final bool expired;
  final String url;
  final int id;
  final int type;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'expiresIn': expiresIn,
        'refreshTime': refreshTime,
        'bindingTime': bindingTime,
        'tokenJsonStr': tokenJsonStr,
        'expired': expired,
        'url': url,
        'id': id,
        'type': type,
      };
}

class ProfileVillageInfo {
  ProfileVillageInfo({
    this.title = '',
    this.imageUrl = '',
    this.targetUrl = '',
  });

  factory ProfileVillageInfo.fromJson(Map<String, dynamic>? json) =>
      ProfileVillageInfo(
        title: asString(json, 'title'),
        imageUrl: asString(json, 'imageUrl'),
        targetUrl: asString(json, 'targetUrl'),
      );
  final String title;
  final String imageUrl;
  final String targetUrl;

  Map<String, dynamic> toJson() => {
        'title': title,
        'imageUrl': imageUrl,
        'targetUrl': targetUrl,
      };
}
