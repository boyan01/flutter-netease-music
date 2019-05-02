import 'dart:async';
import 'dart:io';

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
  const FileCacheProvider(this.directory) : assert(directory != null);

  final Directory directory;

  Future<bool> isCacheAvailable(CacheKey key) {
    return _cacheFileForKey(key).exists();
  }

  File getFile(CacheKey key) {
    return _cacheFileForKey(key);
  }

  File _cacheFileForKey(CacheKey key) =>
      File(directory.path + "/" + key.getKey());
}
