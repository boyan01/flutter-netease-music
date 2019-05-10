import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/comments/page_comment.dart';
import 'package:quiet/part/part.dart';

import 'netease_local_data.dart';
import 'network/netease_request.dart';

export 'netease_image.dart';
export 'netease_local_data.dart';

NeteaseRepository neteaseRepository = NeteaseRepository._private();

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

class NeteaseRepository {
  ///to verify api response is success
  final TaskResultVerify responseVerify = (dynamic result) {
    if (result == null) {
      return VerifyValue.errorMsg("请求失败");
    }
    if (result["code"] != _CODE_SUCCESS) {
      return VerifyValue.errorMsg(
          "code:${result["code"]} \nmsg:${result["msg"]}");
    }
    return VerifyValue.success(result);
  };

  NeteaseRepository._private();

  ///使用手机号码登录
  Future<Map> login(String phone, String password) async {
    var request = {
      "phone": phone,
      "password": md5.convert(utf8.encode(password)).toString()
    };
    var result = await doRequest("/weapi/login/cellphone", request,
        options: Options(headers: {"User-Agent": chooseUserAgent(ua: "pc")}));

    if (result["code"] == 200) {
      return result;
    }
    throw '登陆失败';
  }

  ///刷新登陆状态
  ///返回结果：true 正常登陆状态
  ///         false 需要重新登陆
  Future<bool> refreshLogin() async {
    final result = await doRequest(
        'https://music.163.com/weapi/login/token/refresh', {},
        options: Options(headers: {"User-Agent": chooseUserAgent(ua: "pc")}));
    if (result['code'] == _CODE_SUCCESS) {
      return true;
    } else if (result['code'] == _CODE_NEED_LOGIN) {
      return false;
    }
    throw '服务器错误';
  }

  ///登出,删除本地cookie信息
  Future<void> logout() async {
    NeteaseRequestService().clearCookie();
  }

  ///根据用户ID获取歌单
  ///PlayListDetail 中的 tracks 都是空数据
  Future<List<PlaylistDetail>> userPlaylist(int userId,
      [int offset = 0, int limit = 1000]) async {
    final response = await doRequest("/weapi/user/playlist",
        {"offset": offset, "uid": userId, "limit": limit, "csrf_token": ""});
    if (responseVerify(response).isSuccess) {
      final list = (response["playlist"] as List)
          .cast<Map>()
          .map((e) => PlaylistDetail.fromJson(e))
          .toList();
      neteaseLocalData.updateUserPlaylist(userId, list);
      return list;
    }
    return null;
  }

  ///create new playlist by [name]
  Future<PlaylistDetail> createPlaylist(String name) async {
    final response = await doRequest(
        "https://music.163.com/weapi/playlist/create", {"name": name},
        options: Options(headers: {"User-Agent": chooseUserAgent(ua: "pc")}));
    if (responseVerify(response).isSuccess) {
      return PlaylistDetail.fromJson(response["playlist"]);
    }
    return Future.error(response["msg"] ?? "error:${response["code"]}");
  }

  ///根据歌单id获取歌单详情，包括歌曲
  Future<PlaylistDetail> playlistDetail(int id) async {
    final response = await doRequest(
        "https://music.163.com/weapi/v3/playlist/detail",
        {"id": "$id", "n": 100000, "s": 8},
        crypto: Crypto.linux);
    if (responseVerify(response).isSuccess) {
      final result = PlaylistDetail.fromJson(response["playlist"]);
      neteaseLocalData.updatePlaylistDetail(result);
      return result;
    }
    return null;
  }

  ///id 歌单id
  ///return true if action success
  Future<bool> playlistSubscribe(int id, bool subscribe) async {
    String action = subscribe ? "subscribe" : "unsubscribe";
    final response = await doRequest(
        "https://music.163.com/weapi/playlist/$action", {"id": id});
    return responseVerify(response).isSuccess;
  }

  ///根据专辑详细信息
  Future<Map> albumDetail(int id) async {
    return doRequest("https://music.163.com/weapi/v1/album/$id", {});
  }

  ///推荐歌单
  Future<Map<String, Object>> personalizedPlaylist(
      {int limit = 30, int offset = 0}) {
    return doRequest("/weapi/personalized/playlist",
        {"limit": limit, "offset": offset, "total": true, "n": 1000});
  }

  /// 推荐的新歌（10首）
  Future<Map<String, Object>> personalizedNewSong() {
    return doRequest("/weapi/personalized/newsong", {"type": "recommend"});
  }

  /// 榜单摘要
  Future<Map<String, Object>> topListDetail() async {
    return doRequest("/weapi/toplist/detail", {
      "offset": 0,
      "total": true,
      "limit": 20,
    });
  }

  ///推荐歌曲
  Future<Map<String, Object>> recommendSongs() async {
    return doRequest("/weapi/v1/discovery/recommend/songs", {});
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
    var result = await doRequest(
        'https://music.163.com/weapi/song/lyric?lv=-1&kv=-1&tv=-1', {"id": id},
        crypto: Crypto.linux);
    if (!responseVerify(result).isSuccess) {
      return Future.error(result["msg"]);
    }
    Map lyc = result["lrc"];
    if (lyc == null) {
      return null;
    }
    final content = lyc["lyric"];
    //update cache
    await lyricCache.update(key, content);
    return content;
  }

  ///获取搜索热词
  Future<List<String>> searchHotWords() async {
    var result = await doRequest(
        "https://music.163.com/weapi/search/hot", {"type": 1111},
        options:
            Options(headers: {"User-Agent": chooseUserAgent(ua: "mobile")}));
    if (result["code"] != 200) {
      return null;
    } else {
      List hots = (result["result"] as Map)["hots"];
      return hots.cast<Map<String, dynamic>>().map((map) {
        return map["first"] as String;
      }).toList();
    }
  }

  ///search by keyword
  Future<Map<String, dynamic>> search(String keyword, NeteaseSearchType type,
      {int limit = 20, int offset = 0}) {
    return doRequest("https://music.163.com/weapi/search/get",
        {"s": keyword, "type": type.type, "limit": limit, "offset": offset});
  }

  ///搜索建议
  ///返回搜索建议列表，结果一定不会为null
  Future<List<String>> searchSuggest(String keyword) async {
    if (keyword == null || keyword.isEmpty || keyword.trim().isEmpty) {
      return [];
    }
    keyword = keyword.trim();
    try {
      final response = await doRequest(
          "https://music.163.com/weapi/search/suggest/keyword", {"s": keyword});
      if (!responseVerify(response).isSuccess) {
        return [];
      }
      List<Map> match = ((response["result"]["allMatch"]) as List)?.cast();
      if (match == null) {
        return [];
      }
      return match.map((m) => m["keyword"]).cast<String>().toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  ///check music is available
  Future<bool> checkMusic(int id) async {
    var result = await doRequest(
        "https://music.163.com/weapi/song/enhance/player/url",
        {"ids": "[$id]", "br": 999000});
    return result["code"] == 200 && result["data"][0]["code"] == 200;
  }

  ///fetch music detail from id
  Future<Map<String, dynamic>> getMusicDetail(int id) async {
    final result = await doRequest("https://music.163.com/weapi/v3/song/detail",
        {"ids": "[$id]", "c": '[{"id":$id}]'});
    if (result["code"] == 200) {
      return result["songs"][0];
    }
    return null;
  }

  ///edit playlist tracks
  ///true : succeed
  Future<bool> playlistTracksEdit(
      PlaylistOperation operation, int playlistId, List<int> musicIds) async {
    assert(operation != null);
    assert(playlistId != null);
    assert(musicIds != null && musicIds.isNotEmpty);

    var result = await doRequest(
        "https://music.163.com/weapi/playlist/manipulate/tracks", {
      "op": operation == PlaylistOperation.add ? "add" : "del",
      "pid": playlistId,
      "trackIds": "[${musicIds.join(",")}]"
    });
    return responseVerify(result).isSuccess;
  }

  ///update playlist name and description
  Future<bool> updatePlaylist(PlaylistDetail playlist) async {
    final response = await doRequest(
        "https://music.163.com/weapi/batch",
        {
          "/api/playlist/desc/update": json
              .encode({"id": playlist.id, "desc": playlist.description ?? ""}),
//          "/api/playlist/tags/update":
//              json.encode({"id": playlist.id, "tags": playlist.tags ?? ""}),
          "/api/playlist/update/name":
              json.encode({"id": playlist.id, "name": playlist.name}),
        },
        options: Options(headers: {"User-Agent": chooseUserAgent(ua: "pc")}));
    debugPrint("response :$response");
    if (!responseVerify(response).isSuccess) {
      bool success = response["/api/playlist/desc/update"]["code"] == 200 &&
//          response["/api/playlist/tags/update"]["code"] == 200 &&
          response["/api/playlist/update/name"]["code"] == 200;
      return success;
    }
    return Future.error(response["msg"] ?? "失败");
  }

  ///获取歌手信息和单曲
  Future<Map> artistDetail(int artistId) async {
    return doRequest("https://music.163.com/weapi/v1/artist/$artistId", {});
  }

  ///获取歌手的专辑列表
  Future<Map> artistAlbums(int artistId,
      {int limit = 10, int offset = 0}) async {
    return doRequest("https://music.163.com/weapi/artist/albums/$artistId", {
      "limit": limit,
      "offset": offset,
      "total": true,
    });
  }

  ///获取歌手的MV列表
  Future<Map> artistMvs(int artistId, {int limit = 20, int offset = 0}) async {
    return doRequest("https://music.163.com/weapi/artist/mvs", {
      "artistId": artistId,
      "limit": limit,
      "offset": offset,
      "total": true
    });
  }

  ///获取歌手介绍
  Future<Map> artistDesc(int artistId) async {
    return doRequest(
        "https://music.163.com/weapi/artist/introduction", {"id": artistId});
  }

  ///get comments
  Future<Map> getComments(CommentThreadId commentThread,
      {int limit = 20, int offset = 0}) {
    return neteaseRepository.doRequest(
        "https://music.163.com/weapi/v1/resource/comments/${commentThread.threadId}",
        {"rid": commentThread.id, "limit": limit, "offset": offset},
        cookies: [Cookie("os", "pc")]);
  }

  ///给歌曲加红心
  Future<bool> like(int musicId, bool like) async {
    try {
      final response = await doRequest(
          "https://music.163.com/weapi/radio/like?alg=itembased&trackId=$musicId&like=$like&time=25",
          {"trackId": musicId, "like": like});
      return responseVerify(response).isSuccess;
    } catch (e) {
      return false;
    }
  }

  ///获取用户红心歌曲id列表
  Future<List<int>> likedList(int userId) async {
    final response = await doRequest(
        "https://music.163.com/weapi/song/like/get", {"uid": userId});
    final result = responseVerify(response);
    if (result.isSuccess) {
      return (response["ids"] as List).cast();
    }
    throw result.errorMsg;
  }

  ///获取用户信息 , 歌单，收藏，mv, dj 数量
  FutureOr<Map> subCount() async {
    final response =
        await doRequest('https://music.163.com/weapi/subcount', {});
    final result = responseVerify(response);
    if (result.isSuccess) {
      return response;
    }
    return Future.error(result.errorMsg);
  }

  ///获取用户创建的电台
  Future<List<Map>> userDj(int userId) async {
    final response = await doRequest(
        'https://music.163.com/weapi/dj/program/$userId',
        {'limit': 30, 'offset': 0});
    final result = responseVerify(response);
    if (result.isSuccess) {
      return (response['programs'] as List).cast();
    }
    throw result.errorMsg;
  }

  ///登陆后调用此接口 , 可获取订阅的电台列表
  Future<List<Map>> djSubList() async {
    final response = await doRequest(
        'https://music.163.com/weapi/djradio/get/subed',
        {'total': true, 'offset': 0, 'limit': 30});
    final result = responseVerify(response);
    if (result.isSuccess) {
      return (response['djRadios'] as List).cast();
    }
    throw result.errorMsg;
  }

  ///获取对应 MV 数据 , 数据包含 mv 名字 , 歌手 , 发布时间 , mv 视频地址等数据
  Future<Map> mvDetail(int mvId) {
    return doRequest('https://music.163.com/weapi/mv/detail', {'id': mvId});
  }

  ///调用此接口,可收藏 MV
  Future<void> mvSubscribe(int mvId, bool subscribe) async {
    final action = subscribe ? 'sub' : 'unsub';
    final result = responseVerify(await doRequest(
        'https://music.163.com/weapi/mv/$action',
        {'mvId': mvId, 'mvIds': '["$mvId"]'}));
    if (result.isSuccess) {
      return;
    }
    throw result.errorMsg;
  }

  ///获取用户播放记录
  ///type : 0 all , 1 this week
  Future<Map> getRecord(int uid, int type) {
    assert(type == 0 || type == 1);
    return doRequest('https://music.163.com/weapi/v1/play/record',
        {'uid': uid, 'type': type});
  }

  Future<Map> doRequest(String path, Map data,
      {Crypto crypto = Crypto.we, Options options, List<Cookie> cookies = const []}) {
    return NeteaseRequestService().doRequest(path, data,
        crypto: crypto, options: options, cookies: cookies);
  }
}

Music mapJsonToMusic(Map song,
    {String artistKey = "artists", String albumKey = "album"}) {
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
      album: Album(
          id: album["id"], name: album["name"], coverImageUrl: album["picUrl"]),
      artist: artists);
}

List<Music> mapJsonListToMusicList(List tracks,
    {String artistKey = "artists", String albumKey = "album"}) {
  if (tracks == null) {
    return null;
  }
  var list = tracks
      .cast<Map>()
      .map((e) => mapJsonToMusic(e, artistKey: "ar", albumKey: "al"));
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
  _LyricCache._(Directory dir) : provider = FileCacheProvider(dir);

  final FileCacheProvider provider;

  @override
  Future<String> get(CacheKey key) async {
    final file = provider.getFile(key);
    if (await file.exists()) {
      return file.readAsStringSync();
    }
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
    return await file.exists();
  }
}
