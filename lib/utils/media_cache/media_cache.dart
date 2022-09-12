import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:mixin_logger/mixin_logger.dart';
import 'package:path/path.dart' as p;

import '../../component/utils/pair.dart';
import '../../repository/app_dir.dart';

String _generateUniqueTrackCacheFileName(int id, String url) {
  final uri = Uri.parse(url);
  return '${id.hashCode}${p.extension(uri.path)}';
}

Future<String> generateTrackProxyUrl(int id, String url) async {
  final key = _generateUniqueTrackCacheFileName(id, url);
  final cacheFile = await MediaCache.instance.getCached(key);
  if (cacheFile != null) {
    return cacheFile;
  }
  final proxyUrl = await MediaCache.instance.put(key, url);
  return proxyUrl;
}

class MediaCache {
  MediaCache._() {
    cacheDir = Directory(p.join(appDir.path, 'media_cache'));
    cacheDir.createSync(recursive: true);
  }

  static final MediaCache instance = MediaCache._();

  late Directory cacheDir;

  Future<String?> getCached(String key) async {
    final file = File(p.join(cacheDir.path, key));
    if (file.existsSync()) {
      return file.path;
    }
    return null;
  }

  Future<String> put(String cacheFileName, String url) async {
    await MediaCacheServer.instance.start();
    final proxyUrl = MediaCacheServer.instance.addProxyFile(cacheFileName, url);
    return proxyUrl;
  }
}

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
  MediaCacheServer._();

  static final MediaCacheServer instance = MediaCacheServer._();

  StreamSubscription? _serverSubscription;

  final Map<String, MediaCacheFile> _cacheFiles = {};

  bool get _isRunning => _serverSubscription != null;

  Future<void> start() async {
    if (_isRunning) {
      return;
    }
    final server = await HttpServer.bind(_kLocalProxyHost, 10090, shared: true);
    _serverSubscription = server.listen(_handleHttpRequest);
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

    // handle partial request
    final range = request.headers.value(HttpHeaders.rangeHeader);

    var start = 0;
    int? end;
    if (range != null) {
      final pair = _parsePartialRequestHeader(range);
      start = pair.first;
      end = pair.last;
    }
    await request.response
        .addStream(cacheFile.stream(start, end ?? contentLength));
    await request.response.close();
  }

  String addProxyFile(String filename, String url) {
    final proxyUrl = 'http://$_kLocalProxyHost:10090/$filename';
    if (!_cacheFiles.containsKey(filename)) {
      final mediaCacheFile = MediaCacheFile(cacheFileName: filename, url: url);
      _cacheFiles[filename] = mediaCacheFile;
    }
    return proxyUrl;
  }

  Future<void> stop() async {
    await _serverSubscription?.cancel();
  }
}

// Read the file in blocks of size 64k.
const int _blockSize = 64 * 1024;

const _downloadingSuffix = '.downloading';

class MediaCacheFile {
  MediaCacheFile({
    required this.cacheFileName,
    required this.url,
  }) : _downloadingFile = File(
          p.join(
            MediaCache.instance.cacheDir.path,
            '$cacheFileName$_downloadingSuffix',
          ),
        ) {
    _access = _downloadingFile.openSync(mode: FileMode.writeOnlyAppend);
    _startDownload();
  }

  final String cacheFileName;
  final String url;

  final File _downloadingFile;
  late RandomAccessFile _access;

  File? _completedFile;

  final _response = Completer<HttpClientResponse>();

  Future<int> get contentLength async {
    if (_completedFile != null) {
      return _completedFile!.lengthSync();
    }
    final response = await _response.future;
    return response.contentLength;
  }

  Future<void> _startDownload() async {
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    _response.complete(response);
    await for (final chunk in response) {
      await _access.setPosition(_access.lengthSync());
      await _access.writeFrom(chunk);
    }
    _access.closeSync();
    final completedFile = File(
      p.join(
        MediaCache.instance.cacheDir.path,
        cacheFileName,
      ),
    );
    _downloadingFile.renameSync(completedFile.path);
    _access = completedFile.openSync();
    d('Download completed $url');
  }

  Stream<List<int>> stream(int start, int end) {
    if (_completedFile != null) {
      return _completedFile!.openRead(start, end);
    }
    final controller = StreamController<List<int>>();
    var read = 0;
    final size = end - start + 1;
    Future<void> readBlock() async {
      await _access.setPosition(start + read);

      final blockSize = math.min(_blockSize, size - read);

      if (start + read + blockSize >= _access.lengthSync()) {
        d('readBlock: no more data');
        await Future.delayed(const Duration(milliseconds: 100));
        await readBlock();
        return;
      }
      final block = await _access.read(blockSize);
      read += block.length;
      controller.add(block);
      if (read < size) {
        await readBlock();
      } else {
        await controller.close();
      }
    }

    readBlock();
    return controller.stream;
  }
}
