import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

abstract class CacheKey {
  ///unique key to save or get a cache
  String getKey();
}

///base cache interface
///provide method to fetch or update cache object
abstract class Cache<T> {
  ///get cache object by key
  ///null if no cache
  Future<T> get(CacheKey key);

  ///update cache by key
  ///true if success
  Future<bool> update(CacheKey key, T t);
}

class FileCacheProvider {
  FileCacheProvider(this.directory, {@required this.maxSize}) : assert(directory != null);

  final Directory directory;

  final int maxSize;

  bool _calculating = false;

  Future<bool> isCacheAvailable(CacheKey key) {
    return _cacheFileForKey(key).exists();
  }

  File getFile(CacheKey key) {
    return _cacheFileForKey(key);
  }

  File _cacheFileForKey(CacheKey key) => File(directory.path + "/" + key.getKey());

  void touchFile(File file) {
    file.setLastModified(DateTime.now()).catchError((e) {
      debugPrint("setLastModified for ${file.path} failed. $e");
    });
  }

  void checkSize() {
    if (_calculating) {
      return;
    }
    _calculating = true;
    compute(_fileLru, {"path": directory.path, "maxSize": maxSize}, debugLabel: "file lruc check size")
        .whenComplete(() {
      _calculating = false;
    });
  }
}

Future<void> _fileLru(Map params) async {
  final Directory directory = Directory(params["path"]);
  final int maxSize = params["maxSize"];
  if (!directory.existsSync()) {
    return;
  }
  List<File> files = directory.listSync().where((e) => e is File).cast<File>().toList();
  files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

  int totalSize = 0;
  for (final File file in files) {
    if (totalSize > maxSize) {
      file.deleteSync();
    } else {
      totalSize += file.lengthSync();
    }
  }
}
