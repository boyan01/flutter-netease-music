import 'safe_convert.dart';

class PlayListDetail {
  PlayListDetail({
    this.code = 0,
    required this.playlist,
    required this.privileges,
  });

  factory PlayListDetail.fromJson(Map<String, dynamic>? json) => PlayListDetail(
        code: asInt(json, 'code'),
        playlist: Playlist.fromJson(asMap(json, 'playlist')),
        privileges: asList(json, 'privileges')
            .map((e) => PrivilegesItem.fromJson(e))
            .toList(),
      );
  final int code;
  final Playlist playlist;
  final List<PrivilegesItem> privileges;

  Map<String, dynamic> toJson() => {
        'code': code,
        'playlist': playlist.toJson(),
        'privileges': privileges.map((e) => e.toJson()),
      };
}

class Playlist {
  Playlist({
    this.id = 0,
    this.name = "",
    this.coverImgId = 0,
    this.coverImgUrl = "",
    this.coverImgIdStr = "",
    this.adType = 0,
    this.userId = 0,
    this.createTime = 0,
    this.status = 0,
    this.opRecommend = false,
    this.highQuality = false,
    this.newImported = false,
    this.updateTime = 0,
    this.trackCount = 0,
    this.specialType = 0,
    this.privacy = 0,
    this.trackUpdateTime = 0,
    this.commentThreadId = "",
    this.playCount = 0,
    this.trackNumberUpdateTime = 0,
    this.subscribedCount = 0,
    this.cloudTrackCount = 0,
    this.ordered = false,
    this.description = "",
    required this.tags,
    this.backgroundCoverId = 0,
    this.titleImage = 0,
    required this.subscribers,
    this.subscribed = false,
    required this.creator,
    required this.tracks,
    required this.trackIds,
    this.shareCount = 0,
    this.commentCount = 0,
  });

  factory Playlist.fromJson(Map<String, dynamic>? json) => Playlist(
        id: asInt(json, 'id'),
        name: asString(json, 'name'),
        coverImgId: asInt(json, 'coverImgId'),
        coverImgUrl: asString(json, 'coverImgUrl'),
        coverImgIdStr: asString(json, 'coverImgId_str'),
        adType: asInt(json, 'adType'),
        userId: asInt(json, 'userId'),
        createTime: asInt(json, 'createTime'),
        status: asInt(json, 'status'),
        opRecommend: asBool(json, 'opRecommend'),
        highQuality: asBool(json, 'highQuality'),
        newImported: asBool(json, 'newImported'),
        updateTime: asInt(json, 'updateTime'),
        trackCount: asInt(json, 'trackCount'),
        specialType: asInt(json, 'specialType'),
        privacy: asInt(json, 'privacy'),
        trackUpdateTime: asInt(json, 'trackUpdateTime'),
        commentThreadId: asString(json, 'commentThreadId'),
        playCount: asInt(json, 'playCount'),
        trackNumberUpdateTime: asInt(json, 'trackNumberUpdateTime'),
        subscribedCount: asInt(json, 'subscribedCount'),
        cloudTrackCount: asInt(json, 'cloudTrackCount'),
        ordered: asBool(json, 'ordered'),
        description: asString(json, 'description'),
        tags: asList(json, 'tags').map((e) => e.toString()).toList(),
        backgroundCoverId: asInt(json, 'backgroundCoverId'),
        titleImage: asInt(json, 'titleImage'),
        subscribers: asList(json, 'subscribers')
            .map((e) => SubscribersItem.fromJson(e))
            .toList(),
        subscribed: asBool(json, 'subscribed'),
        creator: Creator.fromJson(asMap(json, 'creator')),
        tracks:
            asList(json, 'tracks').map((e) => TracksItem.fromJson(e)).toList(),
        trackIds: asList(json, 'trackIds')
            .map((e) => TrackIdsItem.fromJson(e))
            .toList(),
        shareCount: asInt(json, 'shareCount'),
        commentCount: asInt(json, 'commentCount'),
      );
  final int id;
  final String name;
  final int coverImgId;
  final String coverImgUrl;
  final String coverImgIdStr;
  final int adType;
  final int userId;
  final int createTime;
  final int status;
  final bool opRecommend;
  final bool highQuality;
  final bool newImported;
  final int updateTime;
  final int trackCount;
  final int specialType;
  final int privacy;
  final int trackUpdateTime;
  final String commentThreadId;
  final int playCount;
  final int trackNumberUpdateTime;
  final int subscribedCount;
  final int cloudTrackCount;
  final bool ordered;
  final String description;
  final List<String> tags;
  final int backgroundCoverId;
  final int titleImage;
  final List<SubscribersItem> subscribers;
  final bool subscribed;
  final Creator creator;
  final List<TracksItem> tracks;
  final List<TrackIdsItem> trackIds;
  final int shareCount;
  final int commentCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'coverImgId': coverImgId,
        'coverImgUrl': coverImgUrl,
        'coverImgId_str': coverImgIdStr,
        'adType': adType,
        'userId': userId,
        'createTime': createTime,
        'status': status,
        'opRecommend': opRecommend,
        'highQuality': highQuality,
        'newImported': newImported,
        'updateTime': updateTime,
        'trackCount': trackCount,
        'specialType': specialType,
        'privacy': privacy,
        'trackUpdateTime': trackUpdateTime,
        'commentThreadId': commentThreadId,
        'playCount': playCount,
        'trackNumberUpdateTime': trackNumberUpdateTime,
        'subscribedCount': subscribedCount,
        'cloudTrackCount': cloudTrackCount,
        'ordered': ordered,
        'description': description,
        'tags': tags.map((e) => e),
        'backgroundCoverId': backgroundCoverId,
        'titleImage': titleImage,
        'subscribers': subscribers.map((e) => e.toJson()),
        'subscribed': subscribed,
        'creator': creator.toJson(),
        'tracks': tracks.map((e) => e.toJson()),
        'trackIds': trackIds.map((e) => e.toJson()),
        'shareCount': shareCount,
        'commentCount': commentCount,
      };
}

class SubscribersItem {
  SubscribersItem({
    this.defaultAvatar = false,
    this.province = 0,
    this.authStatus = 0,
    this.followed = false,
    this.avatarUrl = "",
    this.accountStatus = 0,
    this.gender = 0,
    this.city = 0,
    this.birthday = 0,
    this.userId = 0,
    this.userType = 0,
    this.nickname = "",
    this.signature = "",
    this.description = "",
    this.detailDescription = "",
    this.avatarImgId = 0,
    this.backgroundImgId = 0,
    this.backgroundUrl = "",
    this.authority = 0,
    this.mutual = false,
    this.djStatus = 0,
    this.vipType = 0,
    this.authenticationTypes = 0,
    this.avatarImgIdStr = "",
    this.backgroundImgIdStr = "",
    this.anchor = false,
  });

  factory SubscribersItem.fromJson(Map<String, dynamic>? json) =>
      SubscribersItem(
        defaultAvatar: asBool(json, 'defaultAvatar'),
        province: asInt(json, 'province'),
        authStatus: asInt(json, 'authStatus'),
        followed: asBool(json, 'followed'),
        avatarUrl: asString(json, 'avatarUrl'),
        accountStatus: asInt(json, 'accountStatus'),
        gender: asInt(json, 'gender'),
        city: asInt(json, 'city'),
        birthday: asInt(json, 'birthday'),
        userId: asInt(json, 'userId'),
        userType: asInt(json, 'userType'),
        nickname: asString(json, 'nickname'),
        signature: asString(json, 'signature'),
        description: asString(json, 'description'),
        detailDescription: asString(json, 'detailDescription'),
        avatarImgId: asInt(json, 'avatarImgId'),
        backgroundImgId: asInt(json, 'backgroundImgId'),
        backgroundUrl: asString(json, 'backgroundUrl'),
        authority: asInt(json, 'authority'),
        mutual: asBool(json, 'mutual'),
        djStatus: asInt(json, 'djStatus'),
        vipType: asInt(json, 'vipType'),
        authenticationTypes: asInt(json, 'authenticationTypes'),
        avatarImgIdStr: asString(json, 'avatarImgIdStr'),
        backgroundImgIdStr: asString(json, 'backgroundImgIdStr'),
        anchor: asBool(json, 'anchor'),
      );

  final bool defaultAvatar;
  final int province;
  final int authStatus;
  final bool followed;
  final String avatarUrl;
  final int accountStatus;
  final int gender;
  final int city;
  final int birthday;
  final int userId;
  final int userType;
  final String nickname;
  final String signature;
  final String description;
  final String detailDescription;
  final int avatarImgId;
  final int backgroundImgId;
  final String backgroundUrl;
  final int authority;
  final bool mutual;
  final int djStatus;
  final int vipType;
  final int authenticationTypes;
  final String avatarImgIdStr;
  final String backgroundImgIdStr;
  final bool anchor;

  Map<String, dynamic> toJson() => {
        'defaultAvatar': defaultAvatar,
        'province': province,
        'authStatus': authStatus,
        'followed': followed,
        'avatarUrl': avatarUrl,
        'accountStatus': accountStatus,
        'gender': gender,
        'city': city,
        'birthday': birthday,
        'userId': userId,
        'userType': userType,
        'nickname': nickname,
        'signature': signature,
        'description': description,
        'detailDescription': detailDescription,
        'avatarImgId': avatarImgId,
        'backgroundImgId': backgroundImgId,
        'backgroundUrl': backgroundUrl,
        'authority': authority,
        'mutual': mutual,
        'djStatus': djStatus,
        'vipType': vipType,
        'authenticationTypes': authenticationTypes,
        'avatarImgIdStr': avatarImgIdStr,
        'backgroundImgIdStr': backgroundImgIdStr,
        'anchor': anchor,
        'avatarImgId_str': avatarImgIdStr,
      };
}

class Creator {
  Creator({
    this.defaultAvatar = false,
    this.province = 0,
    this.authStatus = 0,
    this.followed = false,
    this.avatarUrl = "",
    this.accountStatus = 0,
    this.gender = 0,
    this.city = 0,
    this.birthday = 0,
    this.userId = 0,
    this.userType = 0,
    this.nickname = "",
    this.signature = "",
    this.description = "",
    this.detailDescription = "",
    this.avatarImgId = 0,
    this.backgroundImgId = 0,
    this.backgroundUrl = "",
    this.authority = 0,
    this.mutual = false,
    this.djStatus = 0,
    this.vipType = 0,
    this.authenticationTypes = 0,
    this.avatarImgIdStr = "",
    this.backgroundImgIdStr = "",
    this.anchor = false,
  });

  factory Creator.fromJson(Map<String, dynamic>? json) => Creator(
        defaultAvatar: asBool(json, 'defaultAvatar'),
        province: asInt(json, 'province'),
        authStatus: asInt(json, 'authStatus'),
        followed: asBool(json, 'followed'),
        avatarUrl: asString(json, 'avatarUrl'),
        accountStatus: asInt(json, 'accountStatus'),
        gender: asInt(json, 'gender'),
        city: asInt(json, 'city'),
        birthday: asInt(json, 'birthday'),
        userId: asInt(json, 'userId'),
        userType: asInt(json, 'userType'),
        nickname: asString(json, 'nickname'),
        signature: asString(json, 'signature'),
        description: asString(json, 'description'),
        detailDescription: asString(json, 'detailDescription'),
        avatarImgId: asInt(json, 'avatarImgId'),
        backgroundImgId: asInt(json, 'backgroundImgId'),
        backgroundUrl: asString(json, 'backgroundUrl'),
        authority: asInt(json, 'authority'),
        mutual: asBool(json, 'mutual'),
        djStatus: asInt(json, 'djStatus'),
        vipType: asInt(json, 'vipType'),
        authenticationTypes: asInt(json, 'authenticationTypes'),
        avatarImgIdStr: asString(json, 'avatarImgIdStr'),
        backgroundImgIdStr: asString(json, 'backgroundImgIdStr'),
        anchor: asBool(json, 'anchor'),
      );
  final bool defaultAvatar;
  final int province;
  final int authStatus;
  final bool followed;
  final String avatarUrl;
  final int accountStatus;
  final int gender;
  final int city;
  final int birthday;
  final int userId;
  final int userType;
  final String nickname;
  final String signature;
  final String description;
  final String detailDescription;
  final int avatarImgId;
  final int backgroundImgId;
  final String backgroundUrl;
  final int authority;
  final bool mutual;
  final int djStatus;
  final int vipType;
  final int authenticationTypes;
  final String avatarImgIdStr;
  final String backgroundImgIdStr;
  final bool anchor;

  Map<String, dynamic> toJson() => {
        'defaultAvatar': defaultAvatar,
        'province': province,
        'authStatus': authStatus,
        'followed': followed,
        'avatarUrl': avatarUrl,
        'accountStatus': accountStatus,
        'gender': gender,
        'city': city,
        'birthday': birthday,
        'userId': userId,
        'userType': userType,
        'nickname': nickname,
        'signature': signature,
        'description': description,
        'detailDescription': detailDescription,
        'avatarImgId': avatarImgId,
        'backgroundImgId': backgroundImgId,
        'backgroundUrl': backgroundUrl,
        'authority': authority,
        'mutual': mutual,
        'djStatus': djStatus,
        'vipType': vipType,
        'authenticationTypes': authenticationTypes,
        'avatarImgIdStr': avatarImgIdStr,
        'backgroundImgIdStr': backgroundImgIdStr,
        'anchor': anchor,
        'avatarImgId_str': avatarImgIdStr,
      };
}

class TracksItem {
  TracksItem({
    this.name = "",
    this.id = 0,
    this.pst = 0,
    this.t = 0,
    required this.ar,
    required this.alia,
    this.pop = 0,
    this.st = 0,
    this.rt = "",
    this.fee = 0,
    this.v = 0,
    this.cf = "",
    required this.al,
    this.dt = 0,
    required this.h,
    required this.m,
    required this.l,
    this.cd = "",
    this.no = 0,
    this.ftype = 0,
    required this.rtUrls,
    this.djId = 0,
    this.copyright = 0,
    this.sId = 0,
    this.mark = 0,
    this.originCoverType = 0,
    this.single = 0,
    this.mst = 0,
    this.cp = 0,
    this.mv = 0,
    this.rtype = 0,
    this.publishTime = 0,
    required this.tns,
    this.privilege,
  });

  factory TracksItem.fromJson(Map<String, dynamic>? json) => TracksItem(
        name: asString(json, 'name'),
        id: asInt(json, 'id'),
        pst: asInt(json, 'pst'),
        t: asInt(json, 't'),
        ar: asList(json, 'ar').map((e) => ArtistItem.fromJson(e)).toList(),
        alia: asList(json, 'alia').map((e) => e.toString()).toList(),
        pop: asInt(json, 'pop'),
        st: asInt(json, 'st'),
        rt: asString(json, 'rt'),
        fee: asInt(json, 'fee'),
        v: asInt(json, 'v'),
        cf: asString(json, 'cf'),
        al: AlbumItem.fromJson(asMap(json, 'al')),
        dt: asInt(json, 'dt'),
        h: H.fromJson(asMap(json, 'h')),
        m: M.fromJson(asMap(json, 'm')),
        l: L.fromJson(asMap(json, 'l')),
        cd: asString(json, 'cd'),
        no: asInt(json, 'no'),
        ftype: asInt(json, 'ftype'),
        rtUrls: asList(json, 'rtUrls'),
        djId: asInt(json, 'djId'),
        copyright: asInt(json, 'copyright'),
        sId: asInt(json, 's_id'),
        mark: asInt(json, 'mark'),
        originCoverType: asInt(json, 'originCoverType'),
        single: asInt(json, 'single'),
        mst: asInt(json, 'mst'),
        cp: asInt(json, 'cp'),
        mv: asInt(json, 'mv'),
        rtype: asInt(json, 'rtype'),
        publishTime: asInt(json, 'publishTime'),
        tns: asList(json, 'tns').map((e) => e.toString()).toList(),
        privilege: PrivilegesItem.fromJson(asMap(json, 'privilege')),
      );

  final String name;
  final int id;
  final int pst;
  final int t;
  final List<ArtistItem> ar;
  final List<String> alia;
  final int pop;
  final int st;
  final String rt;
  final int fee;
  final int v;
  final String cf;
  final AlbumItem al;
  final int dt;
  final H h;
  final M m;
  final L l;
  final String cd;
  final int no;
  final int ftype;
  final List<dynamic> rtUrls;
  final int djId;
  final int copyright;
  final int sId;
  final int mark;
  final int originCoverType;
  final int single;
  final int mst;
  final int cp;
  final int mv;
  final int rtype;
  final int publishTime;
  final List<String> tns;
  final PrivilegesItem? privilege;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'pst': pst,
        't': t,
        'ar': ar.map((e) => e.toJson()),
        'alia': alia.map((e) => e),
        'pop': pop,
        'st': st,
        'rt': rt,
        'fee': fee,
        'v': v,
        'cf': cf,
        'al': al.toJson(),
        'dt': dt,
        'h': h.toJson(),
        'm': m.toJson(),
        'l': l.toJson(),
        'cd': cd,
        'no': no,
        'ftype': ftype,
        'rtUrls': rtUrls.map((e) => e),
        'djId': djId,
        'copyright': copyright,
        's_id': sId,
        'mark': mark,
        'originCoverType': originCoverType,
        'single': single,
        'mst': mst,
        'cp': cp,
        'mv': mv,
        'rtype': rtype,
        'publishTime': publishTime,
        'tns': tns.map((e) => e),
        'privilege': privilege?.toJson(),
      };
}

class ArtistItem {
  ArtistItem({
    this.id = 0,
    this.name = "",
    required this.tns,
    required this.alias,
  });

  factory ArtistItem.fromJson(Map<String, dynamic>? json) => ArtistItem(
        id: asInt(json, 'id'),
        name: asString(json, 'name'),
        tns: asList(json, 'tns').cast(),
        alias: asList(json, 'alias').cast(),
      );
  final int id;
  final String name;
  final List<String> tns;
  final List<String> alias;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tns': tns,
        'alias': alias,
      };
}

class AlbumItem {
  AlbumItem({
    this.id = 0,
    this.name = "",
    this.picUrl = "",
    required this.tns,
    this.picStr = "",
    this.pic = 0,
  });

  factory AlbumItem.fromJson(Map<String, dynamic>? json) => AlbumItem(
        id: asInt(json, 'id'),
        name: asString(json, 'name'),
        picUrl: asString(json, 'picUrl'),
        tns: asList(json, 'tns').cast(),
        picStr: asString(json, 'pic_str'),
        pic: asInt(json, 'pic'),
      );
  final int id;
  final String name;
  final String picUrl;
  final List<String> tns;
  final String picStr;
  final int pic;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'picUrl': picUrl,
        'tns': tns.map((e) => e),
        'pic_str': picStr,
        'pic': pic,
      };
}

class H {
  H({
    this.br = 0,
    this.fid = 0,
    this.size = 0,
    this.vd = 0,
  });

  factory H.fromJson(Map<String, dynamic>? json) => H(
        br: asInt(json, 'br'),
        fid: asInt(json, 'fid'),
        size: asInt(json, 'size'),
        vd: asInt(json, 'vd'),
      );

  final int br;
  final int fid;
  final int size;
  final int vd;

  Map<String, dynamic> toJson() => {
        'br': br,
        'fid': fid,
        'size': size,
        'vd': vd,
      };
}

class M {
  M({
    this.br = 0,
    this.fid = 0,
    this.size = 0,
    this.vd = 0,
  });

  factory M.fromJson(Map<String, dynamic>? json) => M(
        br: asInt(json, 'br'),
        fid: asInt(json, 'fid'),
        size: asInt(json, 'size'),
        vd: asInt(json, 'vd'),
      );
  final int br;
  final int fid;
  final int size;
  final int vd;

  Map<String, dynamic> toJson() => {
        'br': br,
        'fid': fid,
        'size': size,
        'vd': vd,
      };
}

class L {
  L({
    this.br = 0,
    this.fid = 0,
    this.size = 0,
    this.vd = 0,
  });

  factory L.fromJson(Map<String, dynamic>? json) => L(
        br: asInt(json, 'br'),
        fid: asInt(json, 'fid'),
        size: asInt(json, 'size'),
        vd: asInt(json, 'vd'),
      );
  final int br;
  final int fid;
  final int size;
  final int vd;

  Map<String, dynamic> toJson() => {
        'br': br,
        'fid': fid,
        'size': size,
        'vd': vd,
      };
}

class TrackIdsItem {
  TrackIdsItem({
    this.id = 0,
    this.v = 0,
    this.t = 0,
    this.at = 0,
    this.uid = 0,
    this.rcmdReason = "",
  });

  factory TrackIdsItem.fromJson(Map<String, dynamic>? json) => TrackIdsItem(
        id: asInt(json, 'id'),
        v: asInt(json, 'v'),
        t: asInt(json, 't'),
        at: asInt(json, 'at'),
        uid: asInt(json, 'uid'),
        rcmdReason: asString(json, 'rcmdReason'),
      );
  final int id;
  final int v;
  final int t;
  final int at;
  final int uid;
  final String rcmdReason;

  Map<String, dynamic> toJson() => {
        'id': id,
        'v': v,
        't': t,
        'at': at,
        'uid': uid,
        'rcmdReason': rcmdReason,
      };
}

class PrivilegesItem {
  PrivilegesItem({
    this.id = 0,
    this.fee = 0,
    this.payed = 0,
    this.realPayed = 0,
    this.st = 0,
    this.pl = 0,
    this.dl = 0,
    this.sp = 0,
    this.cp = 0,
    this.subp = 0,
    this.cs = false,
    this.maxbr = 0,
    this.fl = 0,
    this.toast = false,
    this.flag = 0,
    this.paidBigBang = false,
    this.preSell = false,
    this.playMaxbr = 0,
    this.downloadMaxbr = 0,
    required this.freeTrialPrivilege,
    required this.chargeInfoList,
  });

  factory PrivilegesItem.fromJson(Map<String, dynamic>? json) => PrivilegesItem(
        id: asInt(json, 'id'),
        fee: asInt(json, 'fee'),
        payed: asInt(json, 'payed'),
        realPayed: asInt(json, 'realPayed'),
        st: asInt(json, 'st'),
        pl: asInt(json, 'pl'),
        dl: asInt(json, 'dl'),
        sp: asInt(json, 'sp'),
        cp: asInt(json, 'cp'),
        subp: asInt(json, 'subp'),
        cs: asBool(json, 'cs'),
        maxbr: asInt(json, 'maxbr'),
        fl: asInt(json, 'fl'),
        toast: asBool(json, 'toast'),
        flag: asInt(json, 'flag'),
        paidBigBang: asBool(json, 'paidBigBang'),
        preSell: asBool(json, 'preSell'),
        playMaxbr: asInt(json, 'playMaxbr'),
        downloadMaxbr: asInt(json, 'downloadMaxbr'),
        freeTrialPrivilege:
            FreeTrialPrivilege.fromJson(asMap(json, 'freeTrialPrivilege')),
        chargeInfoList: asList(json, 'chargeInfoList')
            .map((e) => ChargeInfoListItem.fromJson(e))
            .toList(),
      );
  final int id;
  final int fee;
  final int payed;
  final int realPayed;
  final int st;
  final int pl;
  final int dl;
  final int sp;
  final int cp;
  final int subp;
  final bool cs;
  final int maxbr;
  final int fl;
  final bool toast;
  final int flag;
  final bool paidBigBang;
  final bool preSell;
  final int playMaxbr;
  final int downloadMaxbr;
  final FreeTrialPrivilege freeTrialPrivilege;
  final List<ChargeInfoListItem> chargeInfoList;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fee': fee,
        'payed': payed,
        'realPayed': realPayed,
        'st': st,
        'pl': pl,
        'dl': dl,
        'sp': sp,
        'cp': cp,
        'subp': subp,
        'cs': cs,
        'maxbr': maxbr,
        'fl': fl,
        'toast': toast,
        'flag': flag,
        'paidBigBang': paidBigBang,
        'preSell': preSell,
        'playMaxbr': playMaxbr,
        'downloadMaxbr': downloadMaxbr,
        'freeTrialPrivilege': freeTrialPrivilege.toJson(),
        'chargeInfoList': chargeInfoList.map((e) => e.toJson()),
      };
}

class FreeTrialPrivilege {
  FreeTrialPrivilege({
    this.resConsumable = false,
    this.userConsumable = false,
  });

  factory FreeTrialPrivilege.fromJson(Map<String, dynamic>? json) =>
      FreeTrialPrivilege(
        resConsumable: asBool(json, 'resConsumable'),
        userConsumable: asBool(json, 'userConsumable'),
      );
  final bool resConsumable;
  final bool userConsumable;

  Map<String, dynamic> toJson() => {
        'resConsumable': resConsumable,
        'userConsumable': userConsumable,
      };
}

class ChargeInfoListItem {
  ChargeInfoListItem({
    this.rate = 0,
    this.chargeType = 0,
  });

  factory ChargeInfoListItem.fromJson(Map<String, dynamic>? json) =>
      ChargeInfoListItem(
        rate: asInt(json, 'rate'),
        chargeType: asInt(json, 'chargeType'),
      );
  final int rate;
  final int chargeType;

  Map<String, dynamic> toJson() => {
        'rate': rate,
        'chargeType': chargeType,
      };
}
