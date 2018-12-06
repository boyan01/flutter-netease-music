import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:quiet/repository/netease_image.dart';

abstract class CacheKey {
  ///unique key to save or get a cache
  String getKey();
}

QuietCache _imageCache;

Future<QuietCache> quietImageCache() async {
  if (_imageCache != null) {
    return _imageCache;
  }
  var temp = await getTemporaryDirectory();
  var dir = Directory(temp.path + "/quiet_images/");
  if (!(await dir.exists())) {
    dir = await dir.create();
  }
  _imageCache = QuietCache(dir);
  return _imageCache;
}

class QuietCache {
  QuietCache(this.directory) : assert(directory != null);

  final Directory directory;

  Future<File> getCacheFile(CacheKey key) async {
    var file = _cacheFileForKey(key);
    if (await file.exists()) {
      return file;
    } else {
      return null;
    }
  }

  File _cacheFileForKey(CacheKey key) =>
      File(directory.path + "/" + key.getKey());

  Future<File> newCacheFile(NeteaseImage key) async {
    var file = _cacheFileForKey(key);
    if (await file.exists()) {
      file.delete();
    }
    return file;
  }
}
