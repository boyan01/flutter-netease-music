import 'package:quiet/model/model.dart';

class MusicVideoDetail {
  int id;
  String name;
  int artistId;
  String artistName;
  String briefDesc;
  String desc;
  String cover;
  int coverId;
  int playCount;
  int subCount;
  int shareCount;
  int likeCount;
  int commentCount;
  int duration;
  int nType;
  String publishTime;

  ///key: video stream name
  ///value:video stream url
  Map brs;
  List<Artist> artists;
  bool isReward;
  String commentThreadId;

  MusicVideoDetail.fromJsonMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map["name"],
        artistId = map["artistId"],
        artistName = map["artistName"],
        briefDesc = map["briefDesc"],
        desc = map["desc"],
        cover = map["cover"],
        coverId = map["coverId"],
        playCount = map["playCount"],
        subCount = map["subCount"],
        shareCount = map["shareCount"],
        likeCount = map["likeCount"],
        commentCount = map["commentCount"],
        duration = map["duration"],
        nType = map["nType"],
        publishTime = map["publishTime"],
        brs = map["brs"],
        artists =
            List<Artist>.from(map["artists"].map((it) => Artist.fromMap(it))),
        isReward = map["isReward"],
        commentThreadId = map["commentThreadId"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['artistId'] = artistId;
    data['artistName'] = artistName;
    data['briefDesc'] = briefDesc;
    data['desc'] = desc;
    data['cover'] = cover;
    data['coverId'] = coverId;
    data['playCount'] = playCount;
    data['subCount'] = subCount;
    data['shareCount'] = shareCount;
    data['likeCount'] = likeCount;
    data['commentCount'] = commentCount;
    data['duration'] = duration;
    data['nType'] = nType;
    data['publishTime'] = publishTime;
    data['brs'] = brs;
    data['artists'] =
        artists != null ? this.artists.map((v) => v.toMap()).toList() : null;
    data['isReward'] = isReward;
    data['commentThreadId'] = commentThreadId;
    return data;
  }
}
