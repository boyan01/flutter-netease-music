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
    return _doRequest("/weapi/login/cellphone", request);
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
    return _doRequest("/weapi/v3/playlist/detail",
        {"id": id, "n": 100000, "s": 8});
  }

  //请求数据
  Future<Map<String, dynamic>> _doRequest(
      String path, Map<String, dynamic> data) async {
    debugPrint("netease request path = $path params = ${data.toString()}");

    Response response = await (await dio).post(path, data: await encrypt(data));
    if (response.data is Map) {
      return response.data;
    }
    return json.decode(response.data);
  }
}

const crypto = const MethodChannel('tech.soit.netease/crypto');

///加密参数
@protected
Future<Map> Function(dynamic) encrypt = (any) async {
  var str = json.encode(any);
  return await crypto.invokeMethod("encrypt", {"json": str});
};

Map<String, String> _header = {
  "Connection": "close",
  "Accept-Language": "zh-CN,zh;q=0.8,gl;q=0.6,zh-TW;q=0.4",
  "Accept": "*/*",
  "Referer": "http://music.163.com",
  "Host": "music.163.com",
  "User-Agent": _randomUserAgent(),
};

const List<String> USER_AGENT_LIST = [
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36",
  "Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1",
  "Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1",
  "Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36",
  "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36",
  "Mozilla/5.0 (Linux; Android 5.1.1; Nexus 6 Build/LYZ28E) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36",
  "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_2 like Mac OS X) AppleWebKit/603.2.4 (KHTML, like Gecko) Mobile/14F89;GameHelper",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4",
  "Mozilla/5.0 (iPhone; CPU iPhone OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A300 Safari/602.1",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:46.0) Gecko/20100101 Firefox/46.0",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:46.0) Gecko/20100101 Firefox/46.0",
  "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)",
  "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0)",
  "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)",
  "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Win64; x64; Trident/6.0)",
  "Mozilla/5.0 (Windows NT 6.3; Win64, x64; Trident/7.0; rv:11.0) like Gecko",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/13.10586",
  "Mozilla/5.0 (iPad; CPU OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A300 Safari/602.1"
];

String _randomUserAgent() {
  var r = Random();
  return USER_AGENT_LIST[
      (r.nextDouble() * (USER_AGENT_LIST.length - 1)).round()];
}
