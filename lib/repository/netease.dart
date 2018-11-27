import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

NeteaseRepository neteaseRepository = NeteaseRepository._private();

class NeteaseRepository {
  static const String _BASE_URL = "http://music.163.com";

  NeteaseRepository._private();

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

    return _dio;
  }

  ///使用手机号码登录
  Future<Map> login(String phone, String password) async {
    var request = {
      "phone": phone,
      "password": md5.convert(utf8.encode(password)).toString()
    };
    return _doRequest("/weapi/login/cellphone", request,
        options: Options(headers: {"User-Agent": _chooseUserAgent(ua: "pc")}));
  }

  ///根据用户ID获取歌单
  ///PlayListDetail 中的 tracks 都是空数据
  Future<Map<String, Object>> userPlaylist(int userId,
      [int offset = 0, int limit = 1000]) {
    return _doRequest("/weapi/user/playlist",
        {"offset": offset, "uid": userId, "limit": limit, "csrf_token": ""});
  }

  ///根据歌单id获取歌单详情，包括歌曲
  Future<Map<String, dynamic>> playlistDetail(int id) {
    return _doRequest("https://music.163.com/weapi/v3/playlist/detail",
        {"id": "$id", "n": 100000, "s": 8},
        type: EncryptType.linux);
  }

  //请求数据
  Future<Map<String, dynamic>> _doRequest(String path, Map data,
      {EncryptType type = EncryptType.we, Options options}) async {
    debugPrint("netease request path = $path params = ${data.toString()}");

    options ??= Options();

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

    Response response =
        await (await dio).post(path, data: data, options: options);
    if (response.data is Map) {
      return response.data;
    }
    return json.decode(response.data);
  }
}

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
  "Connection": "close",
  "Accept-Language": "zh-CN,zh;q=0.8,gl;q=0.6,zh-TW;q=0.4",
  "Accept": "*/*",
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
  if (ua == 'pc') {
    index = (r.nextDouble() * 7).floor();
  } else if (ua == "mobile") {
    index = (r.nextDouble() * 5).floor() + 8;
  } else {
    index = (r.nextDouble() * (_USER_AGENT_LIST.length - 1)).floor();
  }
  return _USER_AGENT_LIST[index];
}
