class LoginResult {
  int loginType;
  int code;
  Account account;
  String token;
  Profile profile;
  List<Bindings> bindings;

  LoginResult({this.loginType, this.code, this.account, this.token, this.profile, this.bindings});

  LoginResult.fromJson(Map<String, dynamic> json) {
    loginType = json['loginType'];
    code = json['code'];
    account = json['account'] != null ? new Account.fromJson(json['account']) : null;
    token = json['token'];
    profile = json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
    if (json['bindings'] != null) {
      bindings = new List<Bindings>();
      json['bindings'].forEach((v) { bindings.add(new Bindings.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['loginType'] = this.loginType;
    data['code'] = this.code;
    if (this.account != null) {
      data['account'] = this.account.toJson();
    }
    data['token'] = this.token;
    if (this.profile != null) {
      data['profile'] = this.profile.toJson();
    }
    if (this.bindings != null) {
      data['bindings'] = this.bindings.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Account {
  int id;
  String userName;
  int type;
  int status;
  int whitelistAuthority;
  int createTime;
  String salt;
  int tokenVersion;
  int ban;
  int baoyueVersion;
  int donateVersion;
  int vipType;
  int viptypeVersion;
  bool anonimousUser;

  Account({this.id, this.userName, this.type, this.status, this.whitelistAuthority, this.createTime, this.salt, this.tokenVersion, this.ban, this.baoyueVersion, this.donateVersion, this.vipType, this.viptypeVersion, this.anonimousUser});

  Account.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['userName'];
    type = json['type'];
    status = json['status'];
    whitelistAuthority = json['whitelistAuthority'];
    createTime = json['createTime'];
    salt = json['salt'];
    tokenVersion = json['tokenVersion'];
    ban = json['ban'];
    baoyueVersion = json['baoyueVersion'];
    donateVersion = json['donateVersion'];
    vipType = json['vipType'];
    viptypeVersion = json['viptypeVersion'];
    anonimousUser = json['anonimousUser'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userName'] = this.userName;
    data['type'] = this.type;
    data['status'] = this.status;
    data['whitelistAuthority'] = this.whitelistAuthority;
    data['createTime'] = this.createTime;
    data['salt'] = this.salt;
    data['tokenVersion'] = this.tokenVersion;
    data['ban'] = this.ban;
    data['baoyueVersion'] = this.baoyueVersion;
    data['donateVersion'] = this.donateVersion;
    data['vipType'] = this.vipType;
    data['viptypeVersion'] = this.viptypeVersion;
    data['anonimousUser'] = this.anonimousUser;
    return data;
  }
}

class Profile {
  int userId;
  int userType;
  bool followed;
  String backgroundUrl;
  String detailDescription;
  String backgroundImgIdStr;
  String avatarImgIdStr;
  int city;
  int vipType;
  int gender;
  int birthday;
  int accountStatus;
  String avatarUrl;
  bool defaultAvatar;
  int province;
  int avatarImgId;
  String nickname;
  int backgroundImgId;
  String description;
  int djStatus;
  bool mutual;
  Null remarkName;
  int authStatus;
  Null expertTags;
  Experts experts;
  String signature;
  int authority;
  int followeds;
  int follows;
  int eventCount;
  Null avatarDetail;
  int playlistCount;
  int playlistBeSubscribedCount;

  Profile({this.userId, this.userType, this.followed, this.backgroundUrl, this.detailDescription, this.backgroundImgIdStr, this.avatarImgIdStr, this.city, this.vipType, this.gender, this.birthday, this.accountStatus, this.avatarUrl, this.defaultAvatar, this.province, this.avatarImgId, this.nickname, this.backgroundImgId, this.description, this.djStatus, this.mutual, this.remarkName, this.authStatus, this.expertTags, this.experts, this.signature, this.authority, this.followeds, this.follows, this.eventCount, this.avatarDetail, this.playlistCount, this.playlistBeSubscribedCount});

  Profile.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userType = json['userType'];
    followed = json['followed'];
    backgroundUrl = json['backgroundUrl'];
    detailDescription = json['detailDescription'];
    backgroundImgIdStr = json['backgroundImgIdStr'];
    avatarImgIdStr = json['avatarImgIdStr'];
    city = json['city'];
    vipType = json['vipType'];
    gender = json['gender'];
    birthday = json['birthday'];
    accountStatus = json['accountStatus'];
    avatarUrl = json['avatarUrl'];
    defaultAvatar = json['defaultAvatar'];
    province = json['province'];
    avatarImgId = json['avatarImgId'];
    nickname = json['nickname'];
    backgroundImgId = json['backgroundImgId'];
    description = json['description'];
    djStatus = json['djStatus'];
    mutual = json['mutual'];
    remarkName = json['remarkName'];
    authStatus = json['authStatus'];
    expertTags = json['expertTags'];
    experts = json['experts'] != null ? new Experts.fromJson(json['experts']) : null;
    signature = json['signature'];
    authority = json['authority'];
    followeds = json['followeds'];
    follows = json['follows'];
    eventCount = json['eventCount'];
    avatarDetail = json['avatarDetail'];
    playlistCount = json['playlistCount'];
    playlistBeSubscribedCount = json['playlistBeSubscribedCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userType'] = this.userType;
    data['followed'] = this.followed;
    data['backgroundUrl'] = this.backgroundUrl;
    data['detailDescription'] = this.detailDescription;
    data['backgroundImgIdStr'] = this.backgroundImgIdStr;
    data['avatarImgIdStr'] = this.avatarImgIdStr;
    data['city'] = this.city;
    data['vipType'] = this.vipType;
    data['gender'] = this.gender;
    data['birthday'] = this.birthday;
    data['accountStatus'] = this.accountStatus;
    data['avatarUrl'] = this.avatarUrl;
    data['defaultAvatar'] = this.defaultAvatar;
    data['province'] = this.province;
    data['avatarImgId'] = this.avatarImgId;
    data['nickname'] = this.nickname;
    data['backgroundImgId'] = this.backgroundImgId;
    data['description'] = this.description;
    data['djStatus'] = this.djStatus;
    data['mutual'] = this.mutual;
    data['remarkName'] = this.remarkName;
    data['authStatus'] = this.authStatus;
    data['expertTags'] = this.expertTags;
    if (this.experts != null) {
      data['experts'] = this.experts.toJson();
    }
    data['signature'] = this.signature;
    data['authority'] = this.authority;
    data['followeds'] = this.followeds;
    data['follows'] = this.follows;
    data['eventCount'] = this.eventCount;
    data['avatarDetail'] = this.avatarDetail;
    data['playlistCount'] = this.playlistCount;
    data['playlistBeSubscribedCount'] = this.playlistBeSubscribedCount;
    return data;
  }
}

class Experts {


  Experts({});

Experts.fromJson(Map<String, dynamic> json) {
}

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  return data;
}
}

class Bindings {
  int userId;
  String url;
  bool expired;
  String tokenJsonStr;
  int bindingTime;
  int expiresIn;
  int refreshTime;
  int id;
  int type;

  Bindings({this.userId, this.url, this.expired, this.tokenJsonStr, this.bindingTime, this.expiresIn, this.refreshTime, this.id, this.type});

  Bindings.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    url = json['url'];
    expired = json['expired'];
    tokenJsonStr = json['tokenJsonStr'];
    bindingTime = json['bindingTime'];
    expiresIn = json['expiresIn'];
    refreshTime = json['refreshTime'];
    id = json['id'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['url'] = this.url;
    data['expired'] = this.expired;
    data['tokenJsonStr'] = this.tokenJsonStr;
    data['bindingTime'] = this.bindingTime;
    data['expiresIn'] = this.expiresIn;
    data['refreshTime'] = this.refreshTime;
    data['id'] = this.id;
    data['type'] = this.type;
    return data;
  }
}
