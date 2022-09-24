import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
@HiveType(typeId: 7)
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

  @HiveField(0)
  final int userId;

  @HiveField(1)
  final String avatarUrl;

  @HiveField(2)
  final String backgroundUrl;

  @HiveField(3)
  final int vipType;

  @HiveField(4)
  final int createTime;

  @HiveField(5)
  final String nickname;

  @HiveField(6)
  final bool followed;

  @HiveField(7)
  final String description;

  @HiveField(8)
  final String detailDescription;

  @HiveField(9)
  final int followedUsers;

  @HiveField(10)
  final int followers;

  @HiveField(11)
  final int allSubscribedCount;

  @HiveField(12)
  final int playlistBeSubscribedCount;

  @HiveField(13)
  final int playlistCount;

  @HiveField(14)
  final int eventCount;

  @HiveField(15)
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
