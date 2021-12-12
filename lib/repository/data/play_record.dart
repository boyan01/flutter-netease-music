import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiet/repository.dart';

part 'play_record.g.dart';

@JsonSerializable()
class PlayRecord with EquatableMixin {
  const PlayRecord({
    required this.playCount,
    required this.score,
    required this.song,
  });

  factory PlayRecord.fromJson(Map<String, dynamic> json) =>
      _$PlayRecordFromJson(json);

  final int playCount;
  final int score;
  final Track song;

  Map<String, dynamic> toJson() => _$PlayRecordToJson(this);

  @override
  List<Object?> get props => [
        playCount,
        score,
        song,
      ];
}
