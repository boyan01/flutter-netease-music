import '../../netease_api.dart';
import 'safe_convert.dart';

class PersonalFm {
  PersonalFm({
    this.popAdjust = false,
    required this.data,
    this.code = 0,
  });

  factory PersonalFm.fromJson(Map<String, dynamic>? json) => PersonalFm(
        popAdjust: asBool(json, 'popAdjust'),
        data: asList(json, 'data').map((e) => FmTrackItem.fromJson(e)).toList(),
        code: asInt(json, 'code'),
      );
  final bool popAdjust;
  final List<FmTrackItem> data;
  final int code;

  Map<String, dynamic> toJson() => {
        'popAdjust': popAdjust,
        'data': data.map((e) => e.toJson()),
        'code': code,
      };
}

class FmTrackItem {
  FmTrackItem({
    this.name = '',
    this.id = 0,
    this.position = 0,
    required this.alias,
    this.status = 0,
    this.fee = 0,
    this.copyrightId = 0,
    this.disc = '',
    this.no = 0,
    required this.artists,
    required this.album,
    this.starred = false,
    this.popularity = 0,
    this.score = 0,
    this.starredNum = 0,
    this.duration = 0,
    this.playedNum = 0,
    this.dayPlays = 0,
    this.hearTime = 0,
    this.ringtone = '',
    this.crbt,
    this.audition,
    this.copyFrom = '',
    this.commentThreadId = '',
    this.rtUrl,
    this.ftype = 0,
    required this.rtUrls,
    this.copyright = 0,
    this.transName,
    this.sign,
    this.mark = 0,
    this.originCoverType = 0,
    this.originSongSimpleData,
    this.single = 0,
    this.noCopyrightRcmd,
    required this.hMusic,
    required this.mMusic,
    required this.lMusic,
    required this.bMusic,
    this.mvid = 0,
    this.mp3Url,
    this.rtype = 0,
    this.rurl,
    required this.privilege,
    this.alg = '',
  });

  factory FmTrackItem.fromJson(Map<String, dynamic>? json) => FmTrackItem(
        name: asString(json, 'name'),
        id: asInt(json, 'id'),
        position: asInt(json, 'position'),
        alias: asList(json, 'alias').cast(),
        status: asInt(json, 'status'),
        fee: asInt(json, 'fee'),
        copyrightId: asInt(json, 'copyrightId'),
        disc: asString(json, 'disc'),
        no: asInt(json, 'no'),
        artists:
            asList(json, 'artists').map((e) => FmArtist.fromJson(e)).toList(),
        album: FmAlbum.fromJson(asMap(json, 'album')),
        starred: asBool(json, 'starred'),
        popularity: asInt(json, 'popularity'),
        score: asInt(json, 'score'),
        starredNum: asInt(json, 'starredNum'),
        duration: asInt(json, 'duration'),
        playedNum: asInt(json, 'playedNum'),
        dayPlays: asInt(json, 'dayPlays'),
        hearTime: asInt(json, 'hearTime'),
        ringtone: asString(json, 'ringtone'),
        crbt: asString(json, 'crbt'),
        audition: asString(json, 'audition'),
        copyFrom: asString(json, 'copyFrom'),
        commentThreadId: asString(json, 'commentThreadId'),
        rtUrl: asString(json, 'rtUrl'),
        ftype: asInt(json, 'ftype'),
        rtUrls: asList(json, 'rtUrls'),
        copyright: asInt(json, 'copyright'),
        transName: asString(json, 'transName'),
        sign: asString(json, 'sign'),
        mark: asInt(json, 'mark'),
        originCoverType: asInt(json, 'originCoverType'),
        originSongSimpleData: asString(json, 'originSongSimpleData'),
        single: asInt(json, 'single'),
        noCopyrightRcmd: asString(json, 'noCopyrightRcmd'),
        hMusic: MusicRes.fromJson(asMap(json, 'hMusic')),
        mMusic: MusicRes.fromJson(asMap(json, 'mMusic')),
        lMusic: MusicRes.fromJson(asMap(json, 'lMusic')),
        bMusic: MusicRes.fromJson(asMap(json, 'bMusic')),
        mvid: asInt(json, 'mvid'),
        mp3Url: asString(json, 'mp3Url'),
        rtype: asInt(json, 'rtype'),
        rurl: asString(json, 'rurl'),
        privilege: Privilege.fromJson(asMap(json, 'privilege')),
        alg: asString(json, 'alg'),
      );
  final String name;
  final int id;
  final int position;
  final List<String> alias;
  final int status;
  final int fee;
  final int copyrightId;
  final String disc;
  final int no;
  final List<FmArtist> artists;
  final FmAlbum album;
  final bool starred;
  final int popularity;
  final int score;
  final int starredNum;
  final int duration;
  final int playedNum;
  final int dayPlays;
  final int hearTime;
  final String ringtone;
  final dynamic crbt;
  final dynamic audition;
  final String copyFrom;
  final String commentThreadId;
  final dynamic rtUrl;
  final int ftype;
  final List<dynamic> rtUrls;
  final int copyright;
  final dynamic transName;
  final dynamic sign;
  final int mark;
  final int originCoverType;
  final dynamic originSongSimpleData;
  final int single;
  final dynamic noCopyrightRcmd;
  final MusicRes hMusic;
  final MusicRes mMusic;
  final MusicRes lMusic;
  final MusicRes bMusic;
  final int mvid;
  final dynamic mp3Url;
  final int rtype;
  final dynamic rurl;
  final Privilege privilege;
  final String alg;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'position': position,
        'alias': alias.map((e) => e),
        'status': status,
        'fee': fee,
        'copyrightId': copyrightId,
        'disc': disc,
        'no': no,
        'artists': artists.map((e) => e.toJson()),
        'album': album.toJson(),
        'starred': starred,
        'popularity': popularity,
        'score': score,
        'starredNum': starredNum,
        'duration': duration,
        'playedNum': playedNum,
        'dayPlays': dayPlays,
        'hearTime': hearTime,
        'ringtone': ringtone,
        'crbt': crbt,
        'audition': audition,
        'copyFrom': copyFrom,
        'commentThreadId': commentThreadId,
        'rtUrl': rtUrl,
        'ftype': ftype,
        'rtUrls': rtUrls.map((e) => e),
        'copyright': copyright,
        'transName': transName,
        'sign': sign,
        'mark': mark,
        'originCoverType': originCoverType,
        'originSongSimpleData': originSongSimpleData,
        'single': single,
        'noCopyrightRcmd': noCopyrightRcmd,
        'hMusic': hMusic.toJson(),
        'mMusic': mMusic.toJson(),
        'lMusic': lMusic.toJson(),
        'bMusic': bMusic.toJson(),
        'mvid': mvid,
        'mp3Url': mp3Url,
        'rtype': rtype,
        'rurl': rurl,
        'privilege': privilege.toJson(),
        'alg': alg,
      };
}

class FmAlbum {
  FmAlbum({
    this.name = '',
    this.id = 0,
    this.type = '',
    this.size = 0,
    this.picId = 0,
    this.blurPicUrl = '',
    this.companyId = 0,
    this.pic = 0,
    this.picUrl = '',
    this.publishTime = 0,
    this.description = '',
    this.tags = '',
    this.company = '',
    this.briefDesc = '',
    required this.artist,
    required this.songs,
    required this.alias,
    this.status = 0,
    this.copyrightId = 0,
    this.commentThreadId = '',
    required this.artists,
    this.subType = '',
    this.transName,
    this.onSale = false,
    this.mark = 0,
    this.picIdStr = '',
  });

  factory FmAlbum.fromJson(Map<String, dynamic>? json) => FmAlbum(
        name: asString(json, 'name'),
        id: asInt(json, 'id'),
        type: asString(json, 'type'),
        size: asInt(json, 'size'),
        picId: asInt(json, 'picId'),
        blurPicUrl: asString(json, 'blurPicUrl'),
        companyId: asInt(json, 'companyId'),
        pic: asInt(json, 'pic'),
        picUrl: asString(json, 'picUrl'),
        publishTime: asInt(json, 'publishTime'),
        description: asString(json, 'description'),
        tags: asString(json, 'tags'),
        company: asString(json, 'company'),
        briefDesc: asString(json, 'briefDesc'),
        artist: FmArtist.fromJson(asMap(json, 'artist')),
        songs: asList(json, 'songs'),
        alias: asList(json, 'alias'),
        status: asInt(json, 'status'),
        copyrightId: asInt(json, 'copyrightId'),
        commentThreadId: asString(json, 'commentThreadId'),
        artists:
            asList(json, 'artists').map((e) => FmArtist.fromJson(e)).toList(),
        subType: asString(json, 'subType'),
        transName: asString(json, 'transName'),
        onSale: asBool(json, 'onSale'),
        mark: asInt(json, 'mark'),
        picIdStr: asString(json, 'picId_str'),
      );

  final String name;
  final int id;
  final String type;
  final int size;
  final int picId;
  final String blurPicUrl;
  final int companyId;
  final int pic;
  final String picUrl;
  final int publishTime;
  final String description;
  final String tags;
  final String company;
  final String briefDesc;
  final FmArtist artist;
  final List<dynamic> songs;
  final List<dynamic> alias;
  final int status;
  final int copyrightId;
  final String commentThreadId;
  final List<FmArtist> artists;
  final String subType;
  final dynamic transName;
  final bool onSale;
  final int mark;
  final String picIdStr;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'type': type,
        'size': size,
        'picId': picId,
        'blurPicUrl': blurPicUrl,
        'companyId': companyId,
        'pic': pic,
        'picUrl': picUrl,
        'publishTime': publishTime,
        'description': description,
        'tags': tags,
        'company': company,
        'briefDesc': briefDesc,
        'artist': artist.toJson(),
        'songs': songs.map((e) => e),
        'alias': alias.map((e) => e),
        'status': status,
        'copyrightId': copyrightId,
        'commentThreadId': commentThreadId,
        'artists': artists.map((e) => e.toJson()),
        'subType': subType,
        'transName': transName,
        'onSale': onSale,
        'mark': mark,
        'picId_str': picIdStr,
      };
}

class FmArtist {
  FmArtist({
    this.name = '',
    this.id = 0,
    this.picId = 0,
    this.img1v1Id = 0,
    this.briefDesc = '',
    this.picUrl = '',
    this.img1v1Url = '',
    this.albumSize = 0,
    required this.alias,
    this.trans = '',
    this.musicSize = 0,
    this.topicPerson = 0,
  });

  factory FmArtist.fromJson(Map<String, dynamic>? json) => FmArtist(
        name: asString(json, 'name'),
        id: asInt(json, 'id'),
        picId: asInt(json, 'picId'),
        img1v1Id: asInt(json, 'img1v1Id'),
        briefDesc: asString(json, 'briefDesc'),
        picUrl: asString(json, 'picUrl'),
        img1v1Url: asString(json, 'img1v1Url'),
        albumSize: asInt(json, 'albumSize'),
        alias: asList(json, 'alias').cast(),
        trans: asString(json, 'trans'),
        musicSize: asInt(json, 'musicSize'),
        topicPerson: asInt(json, 'topicPerson'),
      );

  final String name;
  final int id;
  final int picId;
  final int img1v1Id;
  final String briefDesc;
  final String picUrl;
  final String img1v1Url;
  final int albumSize;
  final List<String> alias;
  final String trans;
  final int musicSize;
  final int topicPerson;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'picId': picId,
        'img1v1Id': img1v1Id,
        'briefDesc': briefDesc,
        'picUrl': picUrl,
        'img1v1Url': img1v1Url,
        'albumSize': albumSize,
        'alias': alias.map((e) => e),
        'trans': trans,
        'musicSize': musicSize,
        'topicPerson': topicPerson,
      };
}

class MusicRes {
  MusicRes({
    this.name,
    this.id = 0,
    this.size = 0,
    this.extension = '',
    this.sr = 0,
    this.dfsId = 0,
    this.bitrate = 0,
    this.playTime = 0,
    this.volumeDelta = 0,
  });

  factory MusicRes.fromJson(Map<String, dynamic>? json) => MusicRes(
        name: asString(json, 'name'),
        id: asInt(json, 'id'),
        size: asInt(json, 'size'),
        extension: asString(json, 'extension'),
        sr: asInt(json, 'sr'),
        dfsId: asInt(json, 'dfsId'),
        bitrate: asInt(json, 'bitrate'),
        playTime: asInt(json, 'playTime'),
        volumeDelta: asInt(json, 'volumeDelta'),
      );
  final dynamic name;
  final int id;
  final int size;
  final String extension;
  final int sr;
  final int dfsId;
  final int bitrate;
  final int playTime;
  final int volumeDelta;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'size': size,
        'extension': extension,
        'sr': sr,
        'dfsId': dfsId,
        'bitrate': bitrate,
        'playTime': playTime,
        'volumeDelta': volumeDelta,
      };
}

class Privilege {
  Privilege({
    this.id = 0,
    this.fee = 0,
    this.payed = 0,
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
    this.preSell = false,
    this.playMaxbr = 0,
    this.downloadMaxbr = 0,
    this.rscl,
    required this.freeTrialPrivilege,
    required this.chargeInfoList,
  });

  factory Privilege.fromJson(Map<String, dynamic>? json) => Privilege(
        id: asInt(json, 'id'),
        fee: asInt(json, 'fee'),
        payed: asInt(json, 'payed'),
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
        preSell: asBool(json, 'preSell'),
        playMaxbr: asInt(json, 'playMaxbr'),
        downloadMaxbr: asInt(json, 'downloadMaxbr'),
        rscl: asString(json, 'rscl'),
        freeTrialPrivilege:
            FreeTrialPrivilege.fromJson(asMap(json, 'freeTrialPrivilege')),
        chargeInfoList: asList(json, 'chargeInfoList')
            .map((e) => ChargeInfoListItem.fromJson(e))
            .toList(),
      );
  final int id;
  final int fee;
  final int payed;
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
  final bool preSell;
  final int playMaxbr;
  final int downloadMaxbr;
  final dynamic rscl;
  final FreeTrialPrivilege freeTrialPrivilege;
  final List<ChargeInfoListItem> chargeInfoList;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fee': fee,
        'payed': payed,
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
        'preSell': preSell,
        'playMaxbr': playMaxbr,
        'downloadMaxbr': downloadMaxbr,
        'rscl': rscl,
        'freeTrialPrivilege': freeTrialPrivilege.toJson(),
        'chargeInfoList': chargeInfoList.map((e) => e.toJson()),
      };
}
