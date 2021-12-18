import 'package:netease_api/netease_api.dart';

import 'safe_convert.dart';

class UserPlayList {
  final String version;
  final bool more;
  final List<Playlist> playlist;
  final int code;

  UserPlayList({
    this.version = "",
    this.more = false,
    required this.playlist,
    this.code = 0,
  });

  factory UserPlayList.fromJson(Map<String, dynamic>? json) => UserPlayList(
        version: asString(json, 'version'),
        more: asBool(json, 'more'),
        playlist:
            asList(json, 'playlist').map((e) => Playlist.fromJson(e)).toList(),
        code: asInt(json, 'code'),
      );

  Map<String, dynamic> toJson() => {
        'version': version,
        'more': more,
        'playlist': playlist.map((e) => e.toJson()).toList(),
        'code': code,
      };
}
