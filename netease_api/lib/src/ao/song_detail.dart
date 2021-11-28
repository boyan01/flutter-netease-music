import '../../netease_api.dart';
import 'safe_convert.dart';

class SongDetail {
  final List<TracksItem> songs;
  final List<PrivilegesItem> privileges;
  final int code;

  SongDetail({
    required this.songs,
    required this.privileges,
    this.code = 0,
  });

  factory SongDetail.fromJson(Map<String, dynamic>? json) => SongDetail(
        songs:
            asList(json, 'songs').map((e) => TracksItem.fromJson(e)).toList(),
        privileges: asList(json, 'privileges')
            .map((e) => PrivilegesItem.fromJson(e))
            .toList(),
        code: asInt(json, 'code'),
      );

  Map<String, dynamic> toJson() => {
        'songs': songs.map((e) => e.toJson()),
        'privileges': privileges.map((e) => e.toJson()),
        'code': code,
      };
}
