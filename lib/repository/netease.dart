import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiet/model/playlist_detail.dart';
import 'package:quiet/pages/page_comment.dart';
import 'package:quiet/part/part.dart';
import 'netease_local_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class NeteaseRepository {
  ///to verify api response is success
  final TaskResultVerify responseVerify = (dynamic result) {
    if (result == null) {
      return VerifyValue.errorMsg("请求失败");
    }
    if (result["code"] != 200) {
      return VerifyValue.errorMsg(
          "code:${result["code"]} \nmsg:${result["msg"]}");
    }
    return VerifyValue.success(result);
  };

  static const String _BASE_URL = "http://music.163.com";

  ///current login user
  final ValueNotifier<Map> user = ValueNotifier(null);

  NeteaseRepository._private() {
    SharedPreferences.getInstance().then((preference) {
      var userJson = preference.getString("login_user");
      Map<String, Object> user;
      if (userJson == null || userJson.isEmpty) {
        user = null;
      }
      try {
        user = json.decode(userJson);
      } catch (e) {}
      this.user.value = user;
      this.user.addListener(() {
        var userValue = this.user.value;
        preference.setString(
            "login_user", userValue == null ? null : json.encode(userValue));
      });
    });
  }

  Dio _dio;

  Future<Dio> get dio async {
    if (_dio != null) {
      return _dio;
    }
    _dio = Dio(Options(
        method: "POST",
        baseUrl: _BASE_URL,
        headers: _header,
        responseType: ResponseType.JSON,
        contentType: ContentType.parse("application/x-www-form-urlencoded")));

    var path = (await getApplicationDocumentsDirectory()).path + "/.cookies/";
    _dio.cookieJar = PersistCookieJar(path);
    _dio.interceptor.request.onSend = (options) {
      debugPrint("request header :${options.headers}");
//      debugPrint("request cookie :${options.data}");
      return options;
    };
    return _dio;
  }

  ///使用手机号码登录
  Future<Map> login(String phone, String password) async {
    var request = {
      "phone": phone,
      "password": md5.convert(utf8.encode(password)).toString()
    };
    var result = await doRequest("/weapi/login/cellphone", request,
        options: Options(headers: {"User-Agent": _chooseUserAgent(ua: "pc")}));

    if (result["code"] == 200) {
      //保存登陆的用户
      user.value = result;
      return result;
    } else {
      return result;
    }
  }

  ///登出
  Future<void> logout() async {
    //删除cookie
    ((await dio).cookieJar as PersistCookieJar).delete(Uri.parse(_BASE_URL));
    //删除preference
    user.value = null;
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
        options: Options(headers: {"User-Agent": _chooseUserAgent(ua: "pc")}));
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
        type: EncryptType.linux);
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
        "https://music.163.com/weapi/song/lyric?os=osx&id=$id&lv=-1&kv=-1&tv=-1",
        {});
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
            Options(headers: {"User-Agent": _chooseUserAgent(ua: "mobile")}));
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
        options: Options(headers: {"User-Agent": _chooseUserAgent(ua: "pc")}));
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
  Future<Map> subCount() async {
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

  //请求数据
  Future<Map<String, dynamic>> doRequest(String path, Map data,
      {EncryptType type = EncryptType.we,
      Options options,
      List<Cookie> cookies = const []}) async {
    debugPrint("netease request path = $path params = ${data.toString()}");

    options ??= Options();

    if (path.contains('music.163.com')) {
      options.headers["Referer"] = "https://music.163.com";
    }

    if (type == EncryptType.linux) {
      data = await _encrypt({
        "params": data,
        "url": path.replaceAll(RegExp(r"\w*api"), 'api'),
        "method": "post",
      }, EncryptType.linux);
      options.baseUrl = null;
      options.headers["User-Agent"] =
          "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36";
      path = "https://music.163.com/api/linux/forward";
    } else if (type == EncryptType.we) {
      var cookies = (await dio).cookieJar.loadForRequest(Uri.parse(_BASE_URL));
      var csrfToken =
          cookies.firstWhere((c) => c.name == "__csrf", orElse: () => null);
      data["csrf_token"] = csrfToken?.value ?? "";

      data = await _encrypt(data, EncryptType.we);
      path = path.replaceAll(RegExp(r"\w*api"), 'weapi');
    }
    options.headers["Cookie"] = (await dio)
        .cookieJar
        .loadForRequest(Uri.parse(_BASE_URL))
          ..addAll(cookies);
    options.headers['Content-Type'] = 'application/x-www-form-urlencoded';

    try {
      Response response = await (await dio)
          .post(path, data: Transformer.urlEncodeMap(data), options: options);
      if (response.data is Map) {
        return response.data;
      }
      return json.decode(response.data);
    } on DioError catch (e) {
      return Future.error(_errorMessages[e.type]);
    }
  }
}

Map<DioErrorType, String> _errorMessages = {
  DioErrorType.DEFAULT: "连接网络失败,请检查网络后重试",
  DioErrorType.CANCEL: "访问已取消",
  DioErrorType.CONNECT_TIMEOUT: "网络连接超时",
  DioErrorType.RECEIVE_TIMEOUT: "网络响应超时",
  DioErrorType.RESPONSE: "服务器错误"
};

const _crypto = const MethodChannel('tech.soit.netease/crypto');

///加密参数
Future<Map> Function(dynamic, EncryptType) _encrypt = (any, type) async {
  var arguments = {"json": json.encode(any)};
  if (type == EncryptType.linux) {
    arguments["type"] = "linux";
  }
  var result = await _crypto.invokeMethod("encrypt", arguments);
  return result;
};

enum EncryptType { linux, we }

Map<String, String> _header = {
  "Referer": "http://music.163.com",
  "Host": "music.163.com",
  "User-Agent": _chooseUserAgent(),
};

const List<String> _USER_AGENT_LIST = [
  "Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1",
  "Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1",
  "Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36",
  "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36",
  "Mozilla/5.0 (Linux; Android 5.1.1; Nexus 6 Build/LYZ28E) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36",
  "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_2 like Mac OS X) AppleWebKit/603.2.4 (KHTML, like Gecko) Mobile/14F89;GameHelper",
  "Mozilla/5.0 (iPhone; CPU iPhone OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A300 Safari/602.1",
  "Mozilla/5.0 (iPad; CPU OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A300 Safari/602.1",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:46.0) Gecko/20100101 Firefox/46.0",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:46.0) Gecko/20100101 Firefox/46.0",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/13.10586"
];

String _chooseUserAgent({String ua}) {
  var r = Random();
  int index;
  if (ua == 'mobile') {
    index = (r.nextDouble() * 7).floor();
  } else if (ua == "pc") {
    index = (r.nextDouble() * 5).floor() + 8;
  } else {
    index = (r.nextDouble() * (_USER_AGENT_LIST.length - 1)).floor();
  }
  return _USER_AGENT_LIST[index];
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
