import 'package:quiet/model/model.dart' as model;

class Artist extends model.Artist {
  String? img1v1Url;
  String? picUrl;
  String? trans;
  String? briefDesc;
  String? name;
  String? picIdStr;
  bool? followed;
  int? topicPerson;
  int? musicSize;
  int? albumSize;
  int? id;
  int? accountId;
  int? mvSize;
  num? img1v1Id;
  num? picId;
  num? publishTime;
  List<String>? alias;

  Artist({
    this.img1v1Url,
    this.picUrl,
    this.trans,
    this.briefDesc,
    this.name,
    this.picIdStr,
    this.followed,
    this.topicPerson,
    this.musicSize,
    this.albumSize,
    this.id,
    this.accountId,
    this.mvSize,
    this.img1v1Id,
    this.picId,
    this.publishTime,
    this.alias,
  }) : super(name: name, id: id, imageUrl: picUrl);

  Artist.fromJson(Map<String, dynamic> json) {
    img1v1Url = json['img1v1Url'];
    picUrl = json['picUrl'];
    trans = json['trans'];
    briefDesc = json['briefDesc'];
    name = json['name'];
    picIdStr = json['picId_str'];
    followed = json['followed'];
    topicPerson = json['topicPerson'];
    musicSize = json['musicSize'];
    albumSize = json['albumSize'];
    id = json['id'];
    accountId = json['accountId'];
    mvSize = json['mvSize'];
    img1v1Id = json['img1v1Id'];
    picId = json['picId'];
    publishTime = json['publishTime'];

    imageUrl = picUrl;

    final List<dynamic> aliasList = json['alias'];
    alias = [];
    alias!.addAll(aliasList.map((o) => o.toString()));
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['img1v1Url'] = img1v1Url;
    data['picUrl'] = picUrl;
    data['trans'] = trans;
    data['briefDesc'] = briefDesc;
    data['name'] = name;
    data['picId_str'] = picIdStr;
    data['followed'] = followed;
    data['topicPerson'] = topicPerson;
    data['musicSize'] = musicSize;
    data['albumSize'] = albumSize;
    data['id'] = id;
    data['accountId'] = accountId;
    data['mvSize'] = mvSize;
    data['img1v1Id'] = img1v1Id;
    data['picId'] = picId;
    data['publishTime'] = publishTime;
    data['alias'] = alias;
    return data;
  }
}
