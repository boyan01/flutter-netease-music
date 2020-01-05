import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiet/component/cache/key_value_cache.dart';

///default image size in dimens
const _defaultImageSize = const Size.fromWidth(200);

///image provider for netease image
class CachedImage extends ImageProvider<CachedImage> implements CacheKey {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  const CachedImage(this.url, {this.scale = 1.0, this.headers})
      : assert(url != null),
        assert(scale != null),
        this._size = null;

  const CachedImage._internal(this.url, this._size, {this.scale = 1.0, this.headers});

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// the size in pixel (widget & height) of this image
  /// might be null
  final Size _size;

  int get height => _size == null || _size.height == double.infinity ? -1 : _size.height.toInt();

  int get width => _size == null || _size.width == double.infinity ? -1 : _size.width.toInt();

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String> headers;

  ///the id of this image
  ///netease image url has a unique id at url last part
  String get id => url.substring(url.lastIndexOf('/'));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedImage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          scale == other.scale &&
          _size == other._size;

  @override
  int get hashCode => hashValues(id, scale, _size);

  @override
  ImageStreamCompleter load(CachedImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(codec: _loadAsync(key, decode), scale: key.scale);
  }

  static final HttpClient _httpClient = HttpClient();

  Future<ui.Codec> _loadAsync(CachedImage key, DecoderCallback decode) async {
    final cache = await _imageCache();
    var image = await cache.get(key);
    if (image != null) {
      return await decode(Uint8List.fromList(image), cacheWidth: key.width, cacheHeight: null);
    }
    //request network source
    final Uri resolved = Uri.base.resolve(key.url);
    final HttpClientRequest request = await _httpClient.getUrl(resolved);
    headers?.forEach((String name, String value) {
      request.headers.add(name, value);
    });
    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw Exception('HTTP request failed, statusCode: ${response?.statusCode}, $resolved');

    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    if (bytes.lengthInBytes == 0) throw Exception('NetworkImage is an empty file: $resolved');

    //save image to cache
    await cache.update(key, bytes);

    return await decode(Uint8List.fromList(bytes), cacheWidth: key.width, cacheHeight: null);
  }

  @override
  Future<CachedImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedImage>(CachedImage._internal(
        url, (configuration.size ?? _defaultImageSize) * configuration.devicePixelRatio,
        scale: scale, headers: headers));
  }

  @override
  String toString() {
    return 'NeteaseImage{url: $url, scale: $scale, size: $_size}';
  }

  @override
  String getKey() {
    return id;
  }
}

_ImageCache __imageCache;

Future<_ImageCache> _imageCache() async {
  if (__imageCache != null) {
    return __imageCache;
  }
  var temp = await getTemporaryDirectory();
  var dir = Directory(temp.path + "/quiet_images/");
  if (!(await dir.exists())) {
    dir = await dir.create();
  }
  __imageCache = _ImageCache(dir);
  return __imageCache;
}

///cache netease image data
class _ImageCache implements Cache<Uint8List> {
  _ImageCache(Directory dir) : provider = FileCacheProvider(dir, maxSize: 600 * 1024 * 1024 /* 600 Mb*/);

  final FileCacheProvider provider;

  @override
  Future<Uint8List> get(CacheKey key) async {
    var file = provider.getFile(key);
    if (await file.exists()) {
      provider.touchFile(file);
      return Uint8List.fromList(await file.readAsBytes());
    }
    return null;
  }

  @override
  Future<bool> update(CacheKey key, Uint8List t) async {
    var file = provider.getFile(key);
    if (await file.exists()) {
      file.delete();
    }
    file = await file.create();
    await file.writeAsBytes(t);
    try {
      return await file.exists();
    } finally {
      provider.checkSize();
    }
  }
}
