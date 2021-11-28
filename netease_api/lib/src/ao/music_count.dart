import 'package:json_annotation/json_annotation.dart';

part 'music_count.g.dart';

@JsonSerializable()
class MusicCount {
  const MusicCount({
    this.artistCount = 0,
    this.djRadioCount = 0,
    this.mvCount = 0,
    this.createDjRadioCount = 0,
    this.createdPlaylistCount = 0,
    this.subPlaylistCount = 0,
  });

  factory MusicCount.fromJson(Map<String, dynamic> json) => _$MusicCountFromJson(json);

  @JsonKey(defaultValue: 0)
  final int artistCount;

  @JsonKey(defaultValue: 0)
  final int djRadioCount;

  @JsonKey(defaultValue: 0)
  final int mvCount;

  @JsonKey(defaultValue: 0)
  final int createDjRadioCount;

  @JsonKey(defaultValue: 0)
  final int createdPlaylistCount;

  @JsonKey(defaultValue: 0)
  final int subPlaylistCount;

  Map<String,dynamic> toJson() => _$MusicCountToJson(this);
}
