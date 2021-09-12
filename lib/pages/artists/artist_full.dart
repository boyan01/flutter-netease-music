import 'package:json_annotation/json_annotation.dart';

part 'artist_full.g.dart';

@JsonSerializable()
class ArtistFull {
  ArtistFull({
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
  });

  factory ArtistFull.fromJson(Map json) => _$ArtistFullFromJson(json);

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

  Map<String, dynamic> toJson() => _$ArtistFullToJson(this);
}
