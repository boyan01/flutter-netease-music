import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'track.dart';

import 'user.dart';

part 'playlist_detail.g.dart';

@JsonSerializable()
@HiveType(typeId: 1)
class PlaylistDetail with EquatableMixin {
  PlaylistDetail({
    required this.id,
    required this.tracks,
    required this.creator,
    required this.coverUrl,
    required this.trackCount,
    required this.subscribed,
    required this.subscribedCount,
    required this.shareCount,
    required this.playCount,
    required this.trackUpdateTime,
    required this.name,
    required this.description,
    required this.commentCount,
    required this.trackIds,
    required this.createTime,
    required this.isMyFavorite,
  });

  factory PlaylistDetail.fromJson(Map<String, dynamic> json) =>
      _$PlaylistDetailFromJson(json);

  @HiveField(0)
  final int id;

  @HiveField(1)
  final List<Track> tracks;

  @HiveField(2)
  final User creator;

  int get creatorUserId => creator.userId;

  @HiveField(3)
  final String coverUrl;

  @HiveField(4)
  final int trackCount;

  @HiveField(5)
  final bool subscribed;

  @HiveField(6)
  final int subscribedCount;

  @HiveField(7)
  final int shareCount;

  @HiveField(8)
  final int playCount;

  @HiveField(9)
  final int trackUpdateTime;

  @HiveField(10)
  final String name;

  @HiveField(11)
  final String description;

  @HiveField(12)
  final int commentCount;

  @HiveField(13)
  final List<int> trackIds;

  @HiveField(14)
  final DateTime createTime;

  @HiveField(15)
  final bool isMyFavorite;

  @override
  List<Object?> get props => [
        id,
        tracks,
        creator,
        coverUrl,
        trackCount,
        subscribed,
        subscribedCount,
        shareCount,
        playCount,
        trackUpdateTime,
        name,
        description,
        commentCount,
        trackIds,
        createTime,
        isMyFavorite,
      ];

  Map<String, dynamic> toJson() => _$PlaylistDetailToJson(this);

  PlaylistDetail copyWith({
    List<Track>? tracks,
    User? creator,
    String? coverUrl,
    int? trackCount,
    bool? subscribed,
    int? subscribedCount,
    int? shareCount,
    int? playCount,
    int? trackUpdateTime,
    String? name,
    String? description,
    int? commentCount,
    List<int>? trackIds,
    DateTime? createTime,
    bool? isFavorite,
  }) {
    return PlaylistDetail(
      id: id,
      tracks: tracks ?? this.tracks,
      creator: creator ?? this.creator,
      coverUrl: coverUrl ?? this.coverUrl,
      trackCount: trackCount ?? this.trackCount,
      subscribed: subscribed ?? this.subscribed,
      subscribedCount: subscribedCount ?? this.subscribedCount,
      shareCount: shareCount ?? this.shareCount,
      playCount: playCount ?? this.playCount,
      trackUpdateTime: trackUpdateTime ?? this.trackUpdateTime,
      name: name ?? this.name,
      description: description ?? this.description,
      commentCount: commentCount ?? this.commentCount,
      trackIds: trackIds ?? this.trackIds,
      createTime: createTime ?? this.createTime,
      isMyFavorite: isFavorite ?? isMyFavorite,
    );
  }
}
