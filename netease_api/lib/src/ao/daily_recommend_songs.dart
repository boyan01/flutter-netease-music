import 'package:json_annotation/json_annotation.dart';

import 'personal_fm.dart';

part 'daily_recommend_songs.g.dart';

@JsonSerializable()
class DailyRecommendSongs {
  DailyRecommendSongs({
    required this.dailySongs,
    required this.recommendReasons,
  });

  factory DailyRecommendSongs.fromJson(Map<String, dynamic> json) =>
      _$DailyRecommendSongsFromJson(json);

  final List<FmTrackItem> dailySongs;
  final List<RecommendReason>? recommendReasons;

  Map<String, dynamic> toJson() => _$DailyRecommendSongsToJson(this);
}

@JsonSerializable()
class RecommendReason {
  RecommendReason({required this.songId, required this.reason});

  factory RecommendReason.fromJson(Map<String, dynamic> json) =>
      _$RecommendReasonFromJson(json);

  final int songId;
  final String reason;

  Map<String, dynamic> toJson() => _$RecommendReasonToJson(this);
}
