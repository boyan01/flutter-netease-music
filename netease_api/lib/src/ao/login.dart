import 'safe_convert.dart';
import 'user_detail.dart';

class Login {
  Login({
    this.loginType = 0,
    this.code = 0,
    required this.account,
    this.token = "",
    required this.profile,
    required this.bindings,
    this.cookie = "",
  });

  factory Login.fromJson(Map<String, dynamic>? json) => Login(
        loginType: asInt(json, 'loginType'),
        code: asInt(json, 'code'),
        account: Account.fromJson(asMap(json, 'account')),
        token: asString(json, 'token'),
        profile: Profile.fromJson(asMap(json, 'profile')),
        bindings: asList(json, 'bindings')
            .map((e) => BindingsItem.fromJson(e))
            .toList(),
        cookie: asString(json, 'cookie'),
      );
  final int loginType;
  final int code;
  final Account account;
  final String token;
  final Profile profile;
  final List<BindingsItem> bindings;
  final String cookie;

  Map<String, dynamic> toJson() => {
        'loginType': loginType,
        'code': code,
        'account': account.toJson(),
        'token': token,
        'profile': profile.toJson(),
        'bindings': bindings.map((e) => e.toJson()),
        'cookie': cookie,
      };
}

class Account {
  Account({
    this.id = 0,
    this.userName = "",
    this.type = 0,
    this.status = 0,
    this.whitelistAuthority = 0,
    this.createTime = 0,
    this.salt = "",
    this.tokenVersion = 0,
    this.ban = 0,
    this.baoyueVersion = 0,
    this.donateVersion = 0,
    this.vipType = 0,
    this.viptypeVersion = 0,
    this.anonimousUser = false,
  });

  factory Account.fromJson(Map<String, dynamic>? json) => Account(
        id: asInt(json, 'id'),
        userName: asString(json, 'userName'),
        type: asInt(json, 'type'),
        status: asInt(json, 'status'),
        whitelistAuthority: asInt(json, 'whitelistAuthority'),
        createTime: asInt(json, 'createTime'),
        salt: asString(json, 'salt'),
        tokenVersion: asInt(json, 'tokenVersion'),
        ban: asInt(json, 'ban'),
        baoyueVersion: asInt(json, 'baoyueVersion'),
        donateVersion: asInt(json, 'donateVersion'),
        vipType: asInt(json, 'vipType'),
        viptypeVersion: asInt(json, 'viptypeVersion'),
        anonimousUser: asBool(json, 'anonimousUser'),
      );
  final int id;
  final String userName;
  final int type;
  final int status;
  final int whitelistAuthority;
  final int createTime;
  final String salt;
  final int tokenVersion;
  final int ban;
  final int baoyueVersion;
  final int donateVersion;
  final int vipType;
  final int viptypeVersion;
  final bool anonimousUser;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'type': type,
        'status': status,
        'whitelistAuthority': whitelistAuthority,
        'createTime': createTime,
        'salt': salt,
        'tokenVersion': tokenVersion,
        'ban': ban,
        'baoyueVersion': baoyueVersion,
        'donateVersion': donateVersion,
        'vipType': vipType,
        'viptypeVersion': viptypeVersion,
        'anonimousUser': anonimousUser,
      };
}
