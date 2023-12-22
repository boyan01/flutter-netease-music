import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User with EquatableMixin {
  User({
    required this.userId,
    required this.avatarUrl,
    required this.backgroundUrl,
    required this.vipType,
    required this.createTime,
    required this.nickname,
    required this.followed,
    required this.description,
    required this.detailDescription,
    required this.followedUsers,
    required this.followers,
    required this.allSubscribedCount,
    required this.playlistBeSubscribedCount,
    required this.playlistCount,
    required this.level,
    required this.eventCount,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  final int userId;

  final String avatarUrl;

  final String backgroundUrl;

  final int vipType;

  final int createTime;

  final String nickname;

  final bool followed;

  final String description;

  final String detailDescription;

  final int followedUsers;

  final int followers;

  final int allSubscribedCount;

  final int playlistBeSubscribedCount;

  final int playlistCount;

  final int eventCount;

  final int level;

  @override
  List<Object?> get props => [
        userId,
        avatarUrl,
        backgroundUrl,
        vipType,
        createTime,
        nickname,
        followed,
        description,
        detailDescription,
        followedUsers,
        followers,
        allSubscribedCount,
        playlistBeSubscribedCount,
        playlistCount,
        level,
        eventCount,
      ];

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
