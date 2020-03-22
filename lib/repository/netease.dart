import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/cupertino.dart';
import 'package:netease_music_api/netease_cloud_music.dart' as api;
import 'package:path_provider/path_provider.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/part/part.dart';

import 'local_cache_data.dart';

export 'package:async/async.dart' show Result;
export 'package:async/async.dart' show ValueResult;
export 'package:async/async.dart' show ErrorResult;

export 'cached_image.dart';
export 'local_cache_data.dart';

NeteaseRepository neteaseRepository;

///enum for [NeteaseRepository.search] param type
class NeteaseSearchType {
  const NeteaseSearchType._(this.type);

  final int type;

  static const NeteaseSearchType song = NeteaseSearchType._(1);
  static const NeteaseSearchType album = NeteaseSearchType._(10);
  static const NeteaseSearchType artist = NeteaseSearchType._(100);
  static const NeteaseSearchType playlist = NeteaseSearchType._(1000);
  static const NeteaseSearchType user = NeteaseSearchType._(1002);
  static const NeteaseSearchType mv = NeteaseSearchType._(1004);
  static const NeteaseSearchType lyric = NeteaseSearchType._(1006);
  static const NeteaseSearchType dj = NeteaseSearchType._(1009);
  static const NeteaseSearchType video = NeteaseSearchType._(1014);
}

enum PlaylistOperation { add, remove }

const _CODE_SUCCESS = 200;

const _CODE_NEED_LOGIN = 301;

///map a result to any other
Result<R> _map<T, R>(Result<T> source, R f(T t)) {
  if (source.isError) return source.asError;
  try {
    return Result.value(f(source.asValue.value));
  } catch (e, s) {
    return Result.error(e, s);
  }
}

class NeteaseRepository {
  NeteaseRepository() {
    scheduleMicrotask(() async {
      PersistCookieJar cookieJar;
      try {
        final path = (await getApplicationDocumentsDirectory()).path;
        cookieJar = PersistCookieJar(dir: path + '/.cookies/');
      } catch (e) {
        debugPrint("error: can not create persist cookie jar");
      }
      _cookieJar.complete(cookieJar);
    });
  }

  Completer<PersistCookieJar> _cookieJar = Completer();

  Future<List<Cookie>> _loadCookies() async {
    final jar = await _cookieJar.future;
    if (jar == null) return const [];
    final uri = Uri.parse('http://music.163.com');
    return jar.loadForRequest(uri);
  }

  void _saveCookies(List<Cookie> cookies) async {
    final jar = await _cookieJar.future;
    if (jar == null) return;
    jar.saveFromResponse(Uri.parse('http://music.163.com'), cookies);
  }

  ///使用手机号码登录
  Future<Result<Map>> login(String phone, String password) async {
    return await doRequest("/login/cellphone", {"phone": phone, "password": password});
  }

  ///刷新登陆状态
  ///返回结果：true 正常登陆状态
  ///         false 需要重新登陆
  Future<bool> refreshLogin() async {
    final result = await doRequest('/login/refresh');
    return result.isValue;
  }

  ///登出,删除本地cookie信息
  Future<void> logout() async {
    //删除cookie
    _cookieJar.future.then((v) => v?.deleteAll());
  }

  ///根据用户ID获取歌单
  ///PlayListDetail 中的 tracks 都是空数据
  Future<Result<List<PlaylistDetail>>> userPlaylist(int userId, [int offset = 0, int limit = 1000]) async {
    final response = await doRequest("/user/playlist", {"offset": offset, "uid": userId, "limit": limit});

    return _map(response, (Map result) {
      final list = (result["playlist"] as List).cast<Map>().map((e) => PlaylistDetail.fromJson(e)).toList();
      neteaseLocalData.updateUserPlaylist(userId, list);
      return list;
    });
  }

  ///create new playlist by [name]
  Future<Result<PlaylistDetail>> createPlaylist(String name, {bool privacy = false}) async {
    final response = await doRequest("/playlist/create", {"name": name, 'privacy': privacy ? 10 : null});
    return _map(response, (result) {
      return PlaylistDetail.fromJson(result["playlist"]);
    });
  }

  ///根据歌单id获取歌单详情，包括歌曲
  ///
  /// [s] 歌单最近的 s 个收藏者
  Future<Result<PlaylistDetail>> playlistDetail(int id, {int s = 5}) async {
    final response = await doRequest("/playlist/detail", {"id": "$id", "s": s});
    return _map(response, (t) {
      final result = PlaylistDetail.fromJson(t["playlist"]);
      neteaseLocalData.updatePlaylistDetail(result);
      return result;
    });
  }

  ///id 歌单id
  ///return true if action success
  Future<bool> playlistSubscribe(int id, bool subscribe) async {
    final response = await doRequest("/playlist/subscribe", {"id": id, 't': subscribe ? 1 : 2});
    return response.isValue;
  }

  ///根据专辑详细信息
  Future<Result<Map>> albumDetail(int id) async {
    return doRequest("/album", {'id': id});
  }

  ///推荐歌单
  Future<Result<Map>> personalizedPlaylist({int limit = 30, int offset = 0}) {
    return doRequest("/personalized", {"limit": limit, "offset": offset, "total": true, "n": 1000});
  }

  /// 推荐的新歌（10首）
  Future<Result<Map>> personalizedNewSong() {
    return doRequest("/personalized/newsong");
  }

  /// 榜单摘要
  Future<Result<Map>> topListDetail() async {
    return doRequest("/toplist/detail");
  }

  ///推荐歌曲，需要登陆
  Future<Result<Map>> recommendSongs() async {
    return doRequest("/recommend/songs");
  }

  ///根据音乐id获取歌词
  Future<String> lyric(int id) async {
    final lyricCache = await _lyricCache();
    final key = _LyricCacheKey(id);
    //check cache first
    String cached = await lyricCache.get(key);
    if (cached != null) {
      return cached;
    }
    var result = await doRequest('/lyric', {"id": id});
    if (result.isError) {
      return Future.error(result.asError.error);
    }
    Map lyc = result.asValue.value["lrc"];
    if (lyc == null) {
      return null;
    }
    final content = lyc["lyric"];
    //update cache
    await lyricCache.update(key, content);
    return content;
  }

  ///获取搜索热词
  Future<Result<List<String>>> searchHotWords() async {
    var result = await doRequest("/search/hot", {"type": 1111});
    return _map(result, (t) {
      List hots = (t["result"] as Map)["hots"];
      return hots.cast<Map<String, dynamic>>().map((map) {
        return map["first"] as String;
      }).toList();
    });
  }

  ///search by keyword
  Future<Result<Map>> search(String keyword, NeteaseSearchType type, {int limit = 20, int offset = 0}) {
    return doRequest("/search", {"keywords": keyword, "type": type.type, "limit": limit, "offset": offset});
  }

  ///搜索建议
  ///返回搜索建议列表，结果一定不会为null
  Future<Result<List<String>>> searchSuggest(String keyword) async {
    if (keyword == null || keyword.isEmpty || keyword.trim().isEmpty) {
      return Result.value(const []);
    }
    keyword = keyword.trim();
    final response = await doRequest("https://music.163.com/weapi/search/suggest/keyword", {"s": keyword});
    if (response.isError) {
      return Result.value(const []);
    }
    return _map(response, (t) {
      List<Map> match = ((response.asValue.value["result"]["allMatch"]) as List)?.cast();
      if (match == null) {
        return [];
      }
      return match.map((m) => m["keyword"]).cast<String>().toList();
    });
  }

  ///check music is available
  Future<bool> checkMusic(int id) async {
    var result = await doRequest("https://music.163.com/weapi/song/enhance/player/url", {"ids": "[$id]", "br": 999000});
    return result.isValue && result.asValue.value["data"][0]["code"] == 200;
  }

  Future<Result<String>> getPlayUrl(int id, [int br = 320000]) async {
    final result = await doRequest("/song/url", {"id": id, "br": br});
    return _map(result, (result) {
      final data = result['data'] as List;
      if (data.isEmpty) {
        throw "无法获取播放地址";
      }
      return data.first['url'];
    });
  }

  ///fetch music detail from id
  Future<Result<Map<String, Object>>> getMusicDetail(int id) async {
    final result = await doRequest("https://music.163.com/weapi/v3/song/detail", {"ids": "[$id]", "c": '[{"id":$id}]'});

    return _map(result, (result) {
      return result["songs"][0];
    });
  }

  ///edit playlist tracks
  ///true : succeed
  Future<bool> playlistTracksEdit(PlaylistOperation operation, int playlistId, List<int> musicIds) async {
    assert(operation != null);
    assert(playlistId != null);
    assert(musicIds != null && musicIds.isNotEmpty);

    var result = await doRequest("https://music.163.com/weapi/playlist/manipulate/tracks", {
      "op": operation == PlaylistOperation.add ? "add" : "del",
      "pid": playlistId,
      "trackIds": "[${musicIds.join(",")}]"
    });
    return result.isValue;
  }

  ///update playlist name and description
  Future<bool> updatePlaylist(PlaylistDetail playlist) async {
    final response = await doRequest("/playlist/update", {
      'id': playlist.id,
      'name': playlist.name,
      'desc': playlist.description,
    });
    return _map(response, (t) {
      return true;
    }).isValue;
  }

  ///获取歌手信息和单曲
  Future<Result<Map>> artistDetail(int artistId) async {
    return doRequest("/artists", {'id': artistId});
  }

  ///获取歌手的专辑列表
  Future<Result<Map>> artistAlbums(int artistId, {int limit = 10, int offset = 0}) async {
    return doRequest("/artist/album", {
      'id': artistId,
      "limit": limit,
      "offset": offset,
      "total": true,
    });
  }

  ///获取歌手的MV列表
  Future<Result<Map>> artistMvs(int artistId, {int limit = 20, int offset = 0}) async {
    return doRequest("/artist/mv", {"id": artistId});
  }

  ///获取歌手介绍
  Future<Result<Map>> artistDesc(int artistId) async {
    return doRequest("/artist/desc", {"id": artistId});
  }

  ///get comments
  Future<Result<Map>> getComments(CommentThreadId commentThread, {int limit = 20, int offset = 0}) async {
    return doRequest('/comment/${commentThread.typePath}', {'id': commentThread.id, 'limit': limit, 'offset': offset});
  }

  ///给歌曲加红心
  Future<bool> like(int musicId, bool like) async {
    final response = await doRequest("/like", {"id": musicId, "like": like});
    return response.isValue;
  }

  ///获取用户红心歌曲id列表
  Future<Result<List<int>>> likedList(int userId) async {
    final response = await doRequest("/likelist", {"uid": userId});
    return _map(response, (t) {
      return (t["ids"] as List).cast();
    });
  }

  ///获取用户信息 , 歌单，收藏，mv, dj 数量
  FutureOr<Result<Map>> subCount() async {
    return await doRequest('/user/subcount');
  }

  ///获取用户创建的电台
  Future<Result<List<Map>>> userDj(int userId) async {
    final response = await doRequest('/user/dj', {'uid': userId, 'limit': 30, 'offset': 0});
    return _map(response, (t) {
      return (t['programs'] as List).cast();
    });
  }

  ///登陆后调用此接口 , 可获取订阅的电台列表
  Future<Result<List<Map>>> djSubList() async {
    return _map(await doRequest('/dj/sublist'), (t) {
      return (t['djRadios'] as List).cast();
    });
  }

  ///获取对应 MV 数据 , 数据包含 mv 名字 , 歌手 , 发布时间 , mv 视频地址等数据
  Future<Result<Map>> mvDetail(int mvId) {
    return doRequest('/mv/detail', {'mvid': mvId});
  }

  ///调用此接口,可收藏 MV
  Future<bool> mvSubscribe(int mvId, bool subscribe) async {
    final result = await doRequest('/mv/sub', {'id': mvId, 't': subscribe ? '1' : '0'});
    return result.isValue;
  }

  ///获取用户播放记录
  ///type : 0 all , 1 this week
  Future<Result<Map>> getRecord(int uid, int type) {
    assert(type == 0 || type == 1);
    return doRequest('/user/record', {'uid': uid, 'type': type});
  }

  ///获取用户详情
  Future<Result<Map>> getUserDetail(int uid) {
    assert(uid != null);
    return doRequest('/user/detail', {'uid': uid});
  }

  ///
  /// 获取私人 FM 推荐歌曲。一次两首歌曲。
  ///
  Future<List<Music>> getPersonalFmMusics() async {
    final result = await doRequest('/personal_fm');
    if (result.isError) {
      throw result.asError.error;
    }
    final data = result.asValue.value["data"];
    return mapJsonListToMusicList(data as List);
  }

  ///[path] request path
  ///[data] parameter
  Future<Result<Map<String, dynamic>>> doRequest(String path, [Map param = const {}]) async {
    api.Answer result;
    try {
      // convert all params to string
      final Map<String, String> convertedParams = param.map((k, v) => MapEntry(k.toString(), v.toString()));
      result = await api.cloudMusicApi(path, parameter: convertedParams, cookie: await _loadCookies());
    } catch (e, stacktrace) {
      debugPrint("request error : $e \n $stacktrace");
      return Result.error(e, stacktrace);
    }
    final map = result.body;

    if (result.status == 200) {
      _saveCookies(result.cookie);
    }
    if (map == null) {
      return Result.error('请求失败了');
    } else if (map['code'] == _CODE_NEED_LOGIN) {
      return Result.error('需要登陆才能访问哦~');
    } else if (map['code'] != _CODE_SUCCESS) {
      return Result.error(map['msg'] ?? '请求失败了~');
    }
    return Result.value(map);
  }
}

Music mapJsonToMusic(Map song, {String artistKey = "artists", String albumKey = "album"}) {
  Map album = song[albumKey] as Map;

  List<Artist> artists = (song[artistKey] as List).cast<Map>().map((e) {
    return Artist(
      name: e["name"],
      id: e["id"],
    );
  }).toList();

  return Music(
      id: song["id"],
      title: song["name"],
      mvId: song['mv'] ?? 0,
      url: "http://music.163.com/song/media/outer/url?id=${song["id"]}.mp3",
      album: Album(id: album["id"], name: album["name"], coverImageUrl: album["picUrl"]),
      artist: artists);
}

List<Music> mapJsonListToMusicList(List tracks, {String artistKey = "artists", String albumKey = "album"}) {
  if (tracks == null) {
    return null;
  }
  var list = tracks.cast<Map>().map((e) => mapJsonToMusic(e, artistKey: artistKey, albumKey: albumKey));
  return list.toList();
}

///cache key for lyric
class _LyricCacheKey implements CacheKey {
  final int musicId;

  _LyricCacheKey(this.musicId) : assert(musicId != null);

  @override
  String getKey() {
    return musicId.toString();
  }
}

_LyricCache __lyricCache;

Future<_LyricCache> _lyricCache() async {
  if (__lyricCache != null) {
    return __lyricCache;
  }
  var temp = await getTemporaryDirectory();
  var dir = Directory(temp.path + "/lyrics/");
  if (!(await dir.exists())) {
    dir = await dir.create();
  }
  __lyricCache = _LyricCache._(dir);
  return __lyricCache;
}

class _LyricCache implements Cache<String> {
  _LyricCache._(Directory dir) : provider = FileCacheProvider(dir, maxSize: 20 * 1024 * 1024 /* 20 Mb */);

  final FileCacheProvider provider;

  @override
  Future<String> get(CacheKey key) async {
    final file = provider.getFile(key);
    if (await file.exists()) {
      return file.readAsStringSync();
    }
    provider.touchFile(file);
    return null;
  }

  @override
  Future<bool> update(CacheKey key, String t) async {
    var file = provider.getFile(key);
    if (await file.exists()) {
      file.delete();
    }
    file = await file.create();
    await file.writeAsString(t);
    try {
      return await file.exists();
    } finally {
      provider.checkSize();
    }
  }
}
