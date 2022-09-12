import 'dart:async';
import 'dart:io';

import 'package:mixin_logger/mixin_logger.dart';

import '../../component/utils/pair.dart';
import 'cached_media_file.dart';

const _kLocalProxyHost = 'localhost';

Pair<int, int?> _parsePartialRequestHeader(String value) {
  final parts = value.split('=');
  if (parts.length != 2) {
    return Pair(0, null);
  }
  final range = parts[1];
  final rangeParts = range.split('-');
  if (rangeParts.length != 2) {
    return Pair(0, null);
  }
  final start = int.tryParse(rangeParts[0]);
  final end = int.tryParse(rangeParts[1]);
  return Pair(start ?? 0, end);
}

class MediaCacheServer {
  MediaCacheServer();

  StreamSubscription? _serverSubscription;

  final Map<String, CachedMediaFile> _cacheFiles = {};

  bool get _isRunning => _serverSubscription != null;

  Future<void> start() async {
    if (_isRunning) {
      return;
    }
    final server = await HttpServer.bind(_kLocalProxyHost, 10090, shared: true);
    _serverSubscription = server.listen((request) {
      _handleHttpRequest(request).catchError((error, stacktrace) {
        e('MediaCacheServer: handle http request error $error $stacktrace');
      });
    });
  }

  Future<void> _handleHttpRequest(HttpRequest request) async {
    d('MediaCacheServer#_handleHttpRequest: ${request.uri.pathSegments}');
    final filename = request.uri.pathSegments.first;
    final cacheFile = _cacheFiles[filename];
    if (cacheFile == null) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    final contentLength = await cacheFile.contentLength;
    request.response.headers.contentLength = contentLength;
    request.response.headers.add(HttpHeaders.acceptRangesHeader, 'bytes');

    // handle partial request
    final range = request.headers.value(HttpHeaders.rangeHeader);

    var start = 0;
    int? end;
    if (range != null) {
      final pair = _parsePartialRequestHeader(range);
      start = pair.first;
      end = pair.last;
    }
    if (start != 0 || end != null) {
      request.response.statusCode = HttpStatus.partialContent;
      request.response.headers.add(
        HttpHeaders.contentRangeHeader,
        'bytes $start-${end ?? contentLength - 1}/$contentLength',
      );
      request.response.headers.contentLength =
          (end ?? contentLength - 1) - start + 1;
    }
    await request.response
        .addStream(cacheFile.stream(start, end ?? contentLength));
    await request.response.close();
  }

  String addProxyFile(String filename, String url, String cacheDir) {
    final proxyUrl = 'http://$_kLocalProxyHost:10090/$filename';
    if (!_cacheFiles.containsKey(filename)) {
      final mediaCacheFile = CachedMediaFile(
        cacheFileName: filename,
        url: url,
        cacheDir: cacheDir,
      );
      _cacheFiles[filename] = mediaCacheFile;
    }
    return proxyUrl;
  }

  Future<void> stop() async {
    await _serverSubscription?.cancel();
  }
}
