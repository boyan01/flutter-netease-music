import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../repository/app_dir.dart';
import 'media_cache_server.dart';

class MediaCache {
  MediaCache({required this.server}) {
    cacheDir = Directory(p.join(appDir.path, 'media_cache'));
    cacheDir.createSync(recursive: true);
  }

  final MediaCacheServer server;

  static final MediaCache instance = MediaCache(server: MediaCacheServer());

  late Directory cacheDir;

  Future<String?> getCached(String key) async {
    final file = File(p.join(cacheDir.path, key));
    if (file.existsSync()) {
      return file.path;
    }
    return null;
  }

  Future<String> put(String cacheFileName, String url) async {
    await server.start();
    final proxyUrl = server.addProxyFile(cacheFileName, url, cacheDir.path);
    return proxyUrl;
  }

  Future<String> generateTrackProxyUrl(int id, String url) async {
    final key = generateUniqueTrackCacheFileName(id, url);
    final cacheFile = await MediaCache.instance.getCached(key);
    if (cacheFile != null) {
      return Uri.file(cacheFile).toString();
    }
    final proxyUrl = await MediaCache.instance.put(key, url);
    return proxyUrl;
  }

  String generateUniqueTrackCacheFileName(int id, String url) {
    final uri = Uri.parse(url);
    return '${id.hashCode}${p.extension(uri.path)}';
  }
}
