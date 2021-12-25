import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiet/repository/data/track.dart';

import 'user.dart';

part 'playlist_detail.g.dart';

@JsonSerializable()
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
  });

  factory PlaylistDetail.fromJson(Map<String, dynamic> json) =>
      _$PlaylistDetailFromJson(json);

  final int id;

  final List<Track> tracks;

  final User creator;

  final String coverUrl;

  final int trackCount;

  final bool subscribed;

  final int subscribedCount;

  final int shareCount;

  final int playCount;

  final int trackUpdateTime;

  final String name;

  final String description;

  final int commentCount;

  final List<int> trackIds;

  final DateTime createTime;

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
    );
  }
}
