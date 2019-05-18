import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'netease_request_crypto.dart';

enum Crypto { linux, we }

const _BASE_URL = "http://music.163.com";

Map<String, String> _header = {
  "Referer": "http://music.163.com",
  "Host": "music.163.com",
  "User-Agent": chooseUserAgent(),
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

Map<DioErrorType, String> _errorMessages = {
  DioErrorType.DEFAULT: "连接网络失败,请检查网络后重试",
  DioErrorType.CANCEL: "访问已取消",
  DioErrorType.CONNECT_TIMEOUT: "网络连接超时",
  DioErrorType.RECEIVE_TIMEOUT: "网络响应超时",
  DioErrorType.RESPONSE: "服务器错误"
};

String chooseUserAgent({String ua}) {
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

class NeteaseRequestService {
  static var _service = NeteaseRequestService._internal();

  Future<Dio> _dio;

  Future<CookieJar> _cookieJar;

  NeteaseRequestService._internal() {
    _cookieJar = () async {
      String path;
      try {
        path = (await getApplicationDocumentsDirectory()).path;
      } catch (e) {
        path = '.';
      }
      return PersistCookieJar(dir: path + '/.cookies/');
    }();
    _dio = () async {
      final dio = Dio(BaseOptions(
          method: "POST",
          baseUrl: _BASE_URL,
          headers: _header,
          responseType: ResponseType.json,
          contentType: ContentType.parse("application/x-www-form-urlencoded")));

      dio.interceptors..add(CookieManager(await _cookieJar));
      return dio;
    }();
  }

  factory NeteaseRequestService() => _service;

  ///请求数据
  Future<Map<String, dynamic>> doRequest(String path, Map data,
      {Crypto crypto = Crypto.we,
      Options options,
      List<Cookie> cookies = const []}) async {
    //init dio first
    final dio = await _dio;
    final cookieJar = await _cookieJar;

    options ??= Options();

    if (path.contains('music.163.com')) {
      options.headers["Referer"] = "https://music.163.com";
    }

    if (crypto == Crypto.linux) {
      data = linuxApi({
        "params": data,
        "url": path.replaceAll(RegExp(r"\w*api"), 'api'),
        "method": "post",
      });
      options.headers["User-Agent"] =
          "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36";
      path = "https://music.163.com/api/linux/forward";
    } else if (crypto == Crypto.we) {
      var cookies = cookieJar.loadForRequest(Uri.parse(_BASE_URL));
      var csrfToken =
          cookies.firstWhere((c) => c.name == "__csrf", orElse: () => null);
      data["csrf_token"] = csrfToken?.value ?? "";

      data = weApi(data);
      path = path.replaceAll(RegExp(r"\w*api"), 'weapi');
    } else {
      throw "crypto can only be ${Crypto.values}";
    }
    options.headers["Cookie"] =
        cookies + cookieJar.loadForRequest(Uri.parse(_BASE_URL));
    options.headers['Content-Type'] = 'application/x-www-form-urlencoded';

    debugPrint("request url : $path, option :$options");
    debugPrint("request data : $data");

    try {
      Response response = await dio.post(path,
          data: Transformer.urlEncodeMap(data), options: options);
      debugPrint("response :${response.data}");
      if (response.data is Map) {
        return response.data;
      }
      return json.decode(response.data);
    } on DioError catch (e) {
      return Future.error(_errorMessages[e.type]);
    }
  }

  void clearCookie() {
    //删除cookie
    _cookieJar.then((jar) {
      if (jar is PersistCookieJar) jar.delete(Uri.parse(_BASE_URL));
    });
  }
}
