import 'package:json_annotation/json_annotation.dart';
import 'package:quiet/model/model.dart';

part 'music_video_detail.g.dart';

@JsonSerializable()
class MusicVideoDetailResult {
  MusicVideoDetailResult({
    required this.loadingPic,
    required this.bufferPic,
    required this.loadingPicFS,
    required this.bufferPicFS,
    required this.subscribed,
    required this.data,
    required this.code,
  });

  factory MusicVideoDetailResult.fromJson(Map json) =>
      _$MusicVideoDetailResultFromJson(json);

  final String loadingPic;
  final String bufferPic;

  final String loadingPicFS;

  final String bufferPicFS;

  @JsonKey(name: "subed")
  final bool subscribed;

  final MusicVideoDetail data;

  final int code;
}

@JsonSerializable()
class MusicVideoDetail {
  MusicVideoDetail({
    required this.artists,
    this.id,
    this.name,
    this.artistId,
    this.artistName,
    this.briefDesc,
    this.desc,
    this.cover,
    this.coverId,
    this.playCount,
    this.subCount,
    this.shareCount,
    this.likeCount,
    this.commentCount,
    this.duration,
    this.nType,
    this.publishTime,
    this.brs,
    this.isReward,
    this.commentThreadId,
  });

  factory MusicVideoDetail.fromJson(Map<String, dynamic> json) =>
      _$MusicVideoDetailFromJson(json);

  int? id;
  String? name;
  int? artistId;
  String? artistName;
  String? briefDesc;
  String? desc;
  String? cover;
  int? coverId;
  int? playCount;
  int? subCount;
  int? shareCount;
  int? likeCount;
  int? commentCount;
  int? duration;
  int? nType;
  String? publishTime;

  ///key: video stream name
  ///value:video stream url
  Map? brs;
  List<Artist> artists;
  bool? isReward;
  String? commentThreadId;

  Map<String, dynamic> toJson() => _$MusicVideoDetailToJson(this);
}
