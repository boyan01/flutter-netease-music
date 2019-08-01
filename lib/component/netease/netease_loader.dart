import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import 'package:quiet/repository/netease.dart';

@visibleForTesting
bool enableCache = true;

///[T] 一定为 [neteaseLocalData] 所能保存的类型，例如 map, String , int
///
/// 如果[T]不是可序列化列表，则设置需要对应的序列化和反序列化方法
///
class CachedLoader<T> extends StatelessWidget {
  final Future<Result<T>> Function() loadTask;

  final LoaderWidgetBuilder<T> builder;

  final String cacheKey;

  final dynamic Function(T t) serialize;
  final T Function(dynamic) deserialize;

  const CachedLoader(
      {Key key,
      @required this.loadTask,
      @required this.builder,
      @required this.cacheKey,
      this.serialize,
      this.deserialize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(() {
      () async {
        debugPrint("load cache $cacheKey : ${(await neteaseLocalData.get(cacheKey)) == null ? 'null' : 'hit'}");
      }();
      return true;
    }());
    return Loader<T>(
      initialData: enableCache
          ? neteaseLocalData.get(cacheKey).then((cache) {
              return deserialize != null && cache != null ? deserialize(cache) : cache;
            })
          : null,
      loadTask: loadTask,
      builder: (context, result) {
        if (enableCache) {
          neteaseLocalData[cacheKey] = serialize != null ? serialize(result) : result;
        }
        return builder(context, result);
      },
    );
  }
}
