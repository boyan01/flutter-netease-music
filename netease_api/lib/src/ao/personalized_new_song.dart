import 'personal_fm.dart';
import 'safe_convert.dart';

class PersonalizedNewSong {
  final int code;
  final int category;
  final List<SongItem> result;

  PersonalizedNewSong({
    this.code = 0,
    this.category = 0,
    required this.result,
  });

  factory PersonalizedNewSong.fromJson(Map<String, dynamic>? json) =>
      PersonalizedNewSong(
        code: asInt(json, 'code'),
        category: asInt(json, 'category'),
        result:
            asList(json, 'result').map((e) => SongItem.fromJson(e)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'category': category,
        'result': result.map((e) => e.toJson()),
      };
}

class SongItem {
  final int id;
  final int type;
  final String name;
  final dynamic copywriter;
  final String picUrl;
  final bool canDislike;
  final dynamic trackNumberUpdateTime;
  final FmTrackItem song;
  final String alg;

  SongItem({
    this.id = 0,
    this.type = 0,
    this.name = "",
    this.copywriter,
    this.picUrl = "",
    this.canDislike = false,
    this.trackNumberUpdateTime,
    required this.song,
    this.alg = "",
  });

  factory SongItem.fromJson(Map<String, dynamic>? json) => SongItem(
        id: asInt(json, 'id'),
        type: asInt(json, 'type'),
        name: asString(json, 'name'),
        copywriter: asString(json, 'copywriter'),
        picUrl: asString(json, 'picUrl'),
        canDislike: asBool(json, 'canDislike'),
        trackNumberUpdateTime: asString(json, 'trackNumberUpdateTime'),
        song: FmTrackItem.fromJson(asMap(json, 'song')),
        alg: asString(json, 'alg'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'copywriter': copywriter,
        'picUrl': picUrl,
        'canDislike': canDislike,
        'trackNumberUpdateTime': trackNumberUpdateTime,
        'song': song.toJson(),
        'alg': alg,
      };
}
