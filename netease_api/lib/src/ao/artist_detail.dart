import 'package:netease_api/netease_api.dart';

import 'safe_convert.dart';

class ArtistDetail {
  ArtistDetail({
    required this.artist,
    required this.hotSongs,
    this.more = false,
    this.code = 0,
  });

  factory ArtistDetail.fromJson(Map<String, dynamic>? json) => ArtistDetail(
        artist: Artist.fromJson(asMap(json, 'artist')),
        hotSongs: asList(json, 'hotSongs')
            .map((e) => TracksItem.fromJson(e))
            .toList(),
        more: asBool(json, 'more'),
        code: asInt(json, 'code'),
      );
  final Artist artist;
  final List<TracksItem> hotSongs;
  final bool more;
  final int code;

  Map<String, dynamic> toJson() => {
        'artist': artist.toJson(),
        'hotSongs': hotSongs.map((e) => e.toJson()),
        'more': more,
        'code': code,
      };
}

class Artist {
  Artist({
    this.img1v1Id = 0,
    this.topicPerson = 0,
    required this.alias,
    this.picId = 0,
    this.briefDesc = '',
    this.musicSize = 0,
    this.albumSize = 0,
    this.picUrl = '',
    this.followed = false,
    this.img1v1Url = '',
    this.trans = '',
    this.name = '',
    this.id = 0,
    this.publishTime = 0,
    this.picIdStr = '',
    this.img1v1IdStr = '',
    this.mvSize = 0,
  });

  factory Artist.fromJson(Map<String, dynamic>? json) => Artist(
        img1v1Id: asInt(json, 'img1v1Id'),
        topicPerson: asInt(json, 'topicPerson'),
        alias: asList(json, 'alias').map((e) => e.toString()).toList(),
        picId: asInt(json, 'picId'),
        briefDesc: asString(json, 'briefDesc'),
        musicSize: asInt(json, 'musicSize'),
        albumSize: asInt(json, 'albumSize'),
        picUrl: asString(json, 'picUrl'),
        followed: asBool(json, 'followed'),
        img1v1Url: asString(json, 'img1v1Url'),
        trans: asString(json, 'trans'),
        name: asString(json, 'name'),
        id: asInt(json, 'id'),
        publishTime: asInt(json, 'publishTime'),
        picIdStr: asString(json, 'picId_str'),
        img1v1IdStr: asString(json, 'img1v1Id_str'),
        mvSize: asInt(json, 'mvSize'),
      );
  final int img1v1Id;
  final int topicPerson;
  final List<String> alias;
  final int picId;
  final String briefDesc;
  final int musicSize;
  final int albumSize;
  final String picUrl;
  final bool followed;
  final String img1v1Url;
  final String trans;
  final String name;
  final int id;
  final int publishTime;
  final String picIdStr;
  final String img1v1IdStr;
  final int mvSize;

  Map<String, dynamic> toJson() => {
        'img1v1Id': img1v1Id,
        'topicPerson': topicPerson,
        'alias': alias.map((e) => e),
        'picId': picId,
        'briefDesc': briefDesc,
        'musicSize': musicSize,
        'albumSize': albumSize,
        'picUrl': picUrl,
        'followed': followed,
        'img1v1Url': img1v1Url,
        'trans': trans,
        'name': name,
        'id': id,
        'publishTime': publishTime,
        'picId_str': picIdStr,
        'img1v1Id_str': img1v1IdStr,
        'mvSize': mvSize,
      };
}
