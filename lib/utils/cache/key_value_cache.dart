import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

abstract class CacheKey {
  factory CacheKey.fromString(String key) {
    return _StringCacheKey(key);
  }

  ///unique key to save or get a cache
  String getKey();
}

class _StringCacheKey implements CacheKey {
  const _StringCacheKey(this.key);

  final String key;

  @override
  String getKey() {
    return key;
  }
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
  FileCacheProvider(this.directory, {required this.maxSize});

  final String directory;

  final int maxSize;

  bool _calculating = false;

  Future<bool> isCacheAvailable(CacheKey key) {
    return _cacheFileForKey(key).exists();
  }

  File getFile(CacheKey key) {
    return _cacheFileForKey(key);
  }

  File _cacheFileForKey(CacheKey key) => File('$directory/${key.getKey()}');

  void touchFile(File file) {
    file.setLastModified(DateTime.now()).catchError((e) {
      debugPrint('setLastModified for ${file.path} failed. $e');
    });
  }

  void checkSize() {
    if (_calculating) {
      return;
    }
    _calculating = true;
    compute(
      _fileLru,
      {'path': directory, 'maxSize': maxSize},
      debugLabel: 'file lru check size',
    ).whenComplete(() {
      _calculating = false;
    });
  }
}

Future<void> _fileLru(Map params) async {
  final directory = Directory(params['path'] as String);
  final maxSize = params['maxSize'] as int?;
  if (!directory.existsSync()) {
    return;
  }
  final files = directory.listSync().whereType<File>().toList();
  files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

  var totalSize = 0;
  for (final file in files) {
    if (totalSize > maxSize!) {
      file.deleteSync();
    } else {
      totalSize += file.lengthSync();
    }
  }
}
