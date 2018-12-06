import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui show Codec;

import 'package:quiet/part/part_cache.dart';

///image provider for netease image
class NeteaseImage extends ImageProvider<NeteaseImage> implements CacheKey {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  const NeteaseImage(this.url, {this.scale = 1.0, this.headers})
      : assert(url != null),
        assert(scale != null);

  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String> headers;

  ///the id of this image
  ///netease image url has a unique id at url last part
  String get id => url.substring(url.lastIndexOf('/'));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NeteaseImage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          scale == other.scale;

  @override
  int get hashCode => hashValues(id, scale);

  @override
  ImageStreamCompleter load(NeteaseImage key) {
    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key), scale: key.scale);
  }

  static final HttpClient _httpClient = HttpClient();

  Future<ui.Codec> _loadAsync(NeteaseImage key) async {
    assert(key == this);
    var cache = await _imageCache();

    var image = await cache.get(key);
    if (image != null) {
      return PaintingBinding.instance
          .instantiateImageCodec(Uint8List.fromList(image));
    }
    //request network source
    final Uri resolved = Uri.base.resolve(key.url);
    final HttpClientRequest request = await _httpClient.getUrl(resolved);
    headers?.forEach((String name, String value) {
      request.headers.add(name, value);
    });
    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok)
      throw Exception(
          'HTTP request failed, statusCode: ${response?.statusCode}, $resolved');

    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    if (bytes.lengthInBytes == 0)
      throw Exception('NetworkImage is an empty file: $resolved');

    //save image to cache
    await cache.update(key, bytes);

    return await PaintingBinding.instance.instantiateImageCodec(bytes);
  }

  @override
  Future<NeteaseImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NeteaseImage>(this);
  }

  @override
  String toString() {
    return 'NeteaseImage{url: $url, scale: $scale}';
  }

  @override
  String getKey() {
    return id;
  }
}

_ImageCache __imageCache;

Future<_ImageCache> _imageCache() async {
  if (_imageCache != null) {
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
  _ImageCache(Directory dir) : provider = FileCacheProvider(dir);

  final FileCacheProvider provider;

  @override
  Future<Uint8List> get(CacheKey key) async {
    var file = provider.getFile(key);
    if (await file.exists()) {
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
    return await file.exists();
  }
}
