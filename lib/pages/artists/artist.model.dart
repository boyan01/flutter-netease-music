import 'package:quiet/model/model.dart' as model;

class Artist extends model.Artist {
  String img1v1Url;
  String picUrl;
  String trans;
  String briefDesc;
  String name;
  String picIdStr;
  bool followed;
  int topicPerson;
  int musicSize;
  int albumSize;
  int id;
  int accountId;
  int mvSize;
  num img1v1Id;
  num picId;
  num publishTime;
  List<String> alias;

  Artist(
      {this.img1v1Url,
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
      this.alias})
      : super(name: name, id: id, imageUrl: picUrl);

  Artist.fromJson(Map<String, dynamic> json) {
    this.img1v1Url = json['img1v1Url'];
    this.picUrl = json['picUrl'];
    this.trans = json['trans'];
    this.briefDesc = json['briefDesc'];
    this.name = json['name'];
    this.picIdStr = json['picId_str'];
    this.followed = json['followed'];
    this.topicPerson = json['topicPerson'];
    this.musicSize = json['musicSize'];
    this.albumSize = json['albumSize'];
    this.id = json['id'];
    this.accountId = json['accountId'];
    this.mvSize = json['mvSize'];
    this.img1v1Id = json['img1v1Id'];
    this.picId = json['picId'];
    this.publishTime = json['publishTime'];

    this.imageUrl = picUrl;

    List<dynamic> aliasList = json['alias'];
    this.alias = new List();
    this.alias.addAll(aliasList.map((o) => o.toString()));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['img1v1Url'] = this.img1v1Url;
    data['picUrl'] = this.picUrl;
    data['trans'] = this.trans;
    data['briefDesc'] = this.briefDesc;
    data['name'] = this.name;
    data['picId_str'] = this.picIdStr;
    data['followed'] = this.followed;
    data['topicPerson'] = this.topicPerson;
    data['musicSize'] = this.musicSize;
    data['albumSize'] = this.albumSize;
    data['id'] = this.id;
    data['accountId'] = this.accountId;
    data['mvSize'] = this.mvSize;
    data['img1v1Id'] = this.img1v1Id;
    data['picId'] = this.picId;
    data['publishTime'] = this.publishTime;
    data['alias'] = this.alias;
    return data;
  }
}
