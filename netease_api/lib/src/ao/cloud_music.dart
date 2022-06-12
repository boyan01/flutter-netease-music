import 'personal_fm.dart';
import 'playlist_detail.dart';
import 'safe_convert.dart';

class CloudMusicDetail {
  CloudMusicDetail({
    required this.data,
    this.count = 0,
    this.size = '',
    this.maxSize = '',
    this.upgradeSign = 0,
    this.hasMore = false,
    this.code = 0,
  });

  factory CloudMusicDetail.fromJson(Map<String, dynamic>? json) =>
      CloudMusicDetail(
        data:
            asList(json, 'data').map((e) => CloudSongItem.fromJson(e)).toList(),
        count: asInt(json, 'count'),
        size: asString(json, 'size'),
        maxSize: asString(json, 'maxSize'),
        upgradeSign: asInt(json, 'upgradeSign'),
        hasMore: asBool(json, 'hasMore'),
        code: asInt(json, 'code'),
      );

  final List<CloudSongItem> data;
  final int count;
  final String size;
  final String maxSize;
  final int upgradeSign;
  final bool hasMore;
  final int code;

  Map<String, dynamic> toJson() => {
        'data': data.map((e) => e.toJson()),
        'count': count,
        'size': size,
        'maxSize': maxSize,
        'upgradeSign': upgradeSign,
        'hasMore': hasMore,
        'code': code,
      };
}

class CloudSongItem {
  CloudSongItem({
    required this.simpleSong,
    this.fileSize = 0,
    this.album = '',
    this.artist = '',
    this.bitrate = 0,
    this.songId = 0,
    this.addTime = 0,
    this.songName = '',
    this.cover = 0,
    this.coverId = '',
    this.lyricId = '',
    this.version = 0,
    this.fileName = '',
  });

  factory CloudSongItem.fromJson(Map<String, dynamic>? json) => CloudSongItem(
        simpleSong: SimpleSong.fromJson(asMap(json, 'simpleSong')),
        fileSize: asInt(json, 'fileSize'),
        album: asString(json, 'album'),
        artist: asString(json, 'artist'),
        bitrate: asInt(json, 'bitrate'),
        songId: asInt(json, 'songId'),
        addTime: asInt(json, 'addTime'),
        songName: asString(json, 'songName'),
        cover: asInt(json, 'cover'),
        coverId: asString(json, 'coverId'),
        lyricId: asString(json, 'lyricId'),
        version: asInt(json, 'version'),
        fileName: asString(json, 'fileName'),
      );
  final SimpleSong simpleSong;
  final int fileSize;
  final String album;
  final String artist;
  final int bitrate;
  final int songId;
  final int addTime;
  final String songName;
  final int cover;
  final String coverId;
  final String lyricId;
  final int version;
  final String fileName;

  Map<String, dynamic> toJson() => {
        'simpleSong': simpleSong.toJson(),
        'fileSize': fileSize,
        'album': album,
        'artist': artist,
        'bitrate': bitrate,
        'songId': songId,
        'addTime': addTime,
        'songName': songName,
        'cover': cover,
        'coverId': coverId,
        'lyricId': lyricId,
        'version': version,
        'fileName': fileName,
      };
}

class SimpleSong {
  SimpleSong({
    this.name = '',
    this.id = 0,
    this.pst = 0,
    this.t = 0,
    required this.ar,
    required this.alia,
    this.pop = 0.0,
    this.st = 0,
    this.rt,
    this.fee = 0,
    this.v = 0,
    this.crbt,
    this.cf,
    required this.al,
    this.dt = 0,
    this.h,
    this.m,
    required this.l,
    this.a,
    this.cd,
    this.no = 0,
    this.rtUrl,
    this.ftype = 0,
    required this.rtUrls,
    this.djId = 0,
    this.copyright = 0,
    this.sId = 0,
    this.mark = 0,
    this.originCoverType = 0,
    this.originSongSimpleData,
    this.single = 0,
    this.noCopyrightRcmd,
    this.rtype = 0,
    this.rurl,
    this.mst = 0,
    this.cp = 0,
    this.mv = 0,
    this.publishTime = 0,
    required this.privilege,
  });

  factory SimpleSong.fromJson(Map<String, dynamic>? json) => SimpleSong(
        name: asString(json, 'name'),
        id: asInt(json, 'id'),
        pst: asInt(json, 'pst'),
        t: asInt(json, 't'),
        ar: asList(json, 'ar')
            .map((e) => SimpleSongArtistItem.fromJson(e))
            .toList(),
        alia: asList(json, 'alia').toList(),
        pop: asDouble(json, 'pop'),
        st: asInt(json, 'st'),
        rt: asString(json, 'rt'),
        fee: asInt(json, 'fee'),
        v: asInt(json, 'v'),
        crbt: asString(json, 'crbt'),
        cf: asString(json, 'cf'),
        al: SimpleSongAlbum.fromJson(asMap(json, 'al')),
        dt: asInt(json, 'dt'),
        h: asString(json, 'h'),
        m: asString(json, 'm'),
        l: L.fromJson(asMap(json, 'l')),
        a: asString(json, 'a'),
        cd: asString(json, 'cd'),
        no: asInt(json, 'no'),
        rtUrl: asString(json, 'rtUrl'),
        ftype: asInt(json, 'ftype'),
        rtUrls: asList(json, 'rtUrls').toList(),
        djId: asInt(json, 'djId'),
        copyright: asInt(json, 'copyright'),
        sId: asInt(json, 's_id'),
        mark: asInt(json, 'mark'),
        originCoverType: asInt(json, 'originCoverType'),
        originSongSimpleData: asString(json, 'originSongSimpleData'),
        single: asInt(json, 'single'),
        noCopyrightRcmd: asString(json, 'noCopyrightRcmd'),
        rtype: asInt(json, 'rtype'),
        rurl: asString(json, 'rurl'),
        mst: asInt(json, 'mst'),
        cp: asInt(json, 'cp'),
        mv: asInt(json, 'mv'),
        publishTime: asInt(json, 'publishTime'),
        privilege: Privilege.fromJson(asMap(json, 'privilege')),
      );
  final String name;
  final int id;
  final int pst;
  final int t;
  final List<SimpleSongArtistItem> ar;
  final List<dynamic> alia;
  final double pop;
  final int st;
  final dynamic rt;
  final int fee;
  final int v;
  final dynamic crbt;
  final dynamic cf;
  final SimpleSongAlbum al;
  final int dt;
  final dynamic h;
  final dynamic m;
  final L l;
  final dynamic a;
  final dynamic cd;
  final int no;
  final dynamic rtUrl;
  final int ftype;
  final List<dynamic> rtUrls;
  final int djId;
  final int copyright;
  final int sId;
  final int mark;
  final int originCoverType;
  final dynamic originSongSimpleData;
  final int single;
  final dynamic noCopyrightRcmd;
  final int rtype;
  final dynamic rurl;
  final int mst;
  final int cp;
  final int mv;
  final int publishTime;
  final Privilege privilege;

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
        'crbt': crbt,
        'cf': cf,
        'al': al.toJson(),
        'dt': dt,
        'h': h,
        'm': m,
        'l': l.toJson(),
        'a': a,
        'cd': cd,
        'no': no,
        'rtUrl': rtUrl,
        'ftype': ftype,
        'rtUrls': rtUrls.map((e) => e),
        'djId': djId,
        'copyright': copyright,
        's_id': sId,
        'mark': mark,
        'originCoverType': originCoverType,
        'originSongSimpleData': originSongSimpleData,
        'single': single,
        'noCopyrightRcmd': noCopyrightRcmd,
        'rtype': rtype,
        'rurl': rurl,
        'mst': mst,
        'cp': cp,
        'mv': mv,
        'publishTime': publishTime,
        'privilege': privilege.toJson(),
      };
}

class SimpleSongArtistItem {
  SimpleSongArtistItem({
    this.id = 0,
    this.name,
    required this.tns,
    required this.alias,
  });

  factory SimpleSongArtistItem.fromJson(Map<String, dynamic>? json) =>
      SimpleSongArtistItem(
        id: asInt(json, 'id'),
        name: asString(json, 'name'),
        tns: asList(json, 'tns').toList(),
        alias: asList(json, 'alias').toList(),
      );
  final int id;
  final dynamic name;
  final List<dynamic> tns;
  final List<dynamic> alias;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tns': tns.map((e) => e),
        'alias': alias.map((e) => e),
      };
}

class SimpleSongAlbum {
  SimpleSongAlbum({
    this.id = 0,
    this.name,
    this.picUrl = '',
    required this.tns,
    this.pic = 0,
  });

  factory SimpleSongAlbum.fromJson(Map<String, dynamic>? json) =>
      SimpleSongAlbum(
        id: asInt(json, 'id'),
        name: asString(json, 'name'),
        picUrl: asString(json, 'picUrl'),
        tns: asList(json, 'tns').toList(),
        pic: asInt(json, 'pic'),
      );
  final int id;
  final dynamic name;
  final String picUrl;
  final List<dynamic> tns;
  final int pic;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'picUrl': picUrl,
        'tns': tns.map((e) => e),
        'pic': pic,
      };
}
