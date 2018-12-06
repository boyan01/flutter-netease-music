import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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
    var cache = await quietImageCache();
    File image = await cache.getCacheFile(key);
    if (image != null) {
      debugPrint("cached hited : ${image.path}");
      List<int> bytes = await image.readAsBytes();
      return await PaintingBinding.instance
          .instantiateImageCodec(Uint8List.fromList(bytes));
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
    image = await cache.newCacheFile(key);
    image = await image.writeAsBytes(bytes, flush: true);

    assert((await image.length()) != 0,
        " image $this saved to  ${image.path} with size = ${image.length()} ");


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
