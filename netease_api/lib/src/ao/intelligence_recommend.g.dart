// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intelligence_recommend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntelligenceRecommend _$IntelligenceRecommendFromJson(
        Map<String, dynamic> json) =>
    IntelligenceRecommend(
      id: json['id'] as int,
      recommended: json['recommended'] as bool,
      alg: json['alg'] as String,
      songInfo: TracksItem.fromJson(json['songInfo'] as Map<String, dynamic>?),
    );

Map<String, dynamic> _$IntelligenceRecommendToJson(
        IntelligenceRecommend instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recommended': instance.recommended,
      'alg': instance.alg,
      'songInfo': instance.songInfo,
    };
