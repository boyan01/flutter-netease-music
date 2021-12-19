import 'playlist_detail.dart';
import 'safe_convert.dart';

class PlayRecord {
  PlayRecord({
    this.playCount = 0,
    this.score = 0,
    required this.song,
  });

  factory PlayRecord.fromJson(Map<String, dynamic>? json) => PlayRecord(
        playCount: asInt(json, 'playCount'),
        score: asInt(json, 'score'),
        song: TracksItem.fromJson(asMap(json, 'song')),
      );

  final int playCount;
  final int score;
  final TracksItem song;

  Map<String, dynamic> toJson() => {
        'playCount': playCount,
        'score': score,
        'song': song.toJson(),
      };
}
