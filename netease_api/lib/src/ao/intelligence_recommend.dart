import 'package:json_annotation/json_annotation.dart';

import '../../netease_api.dart';

part 'intelligence_recommend.g.dart';

@JsonSerializable()
class IntelligenceRecommend {
  IntelligenceRecommend({
    required this.id,
    required this.recommended,
    required this.alg,
    required this.songInfo,
  });

  factory IntelligenceRecommend.fromJson(Map<String, dynamic> json) =>
      _$IntelligenceRecommendFromJson(json);

  final int id;
  final bool recommended;
  final String alg;

  final TracksItem songInfo;

  Map<String, dynamic> toJson() => _$IntelligenceRecommendToJson(this);
}
