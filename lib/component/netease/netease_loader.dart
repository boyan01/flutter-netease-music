import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loader/loader.dart';
import 'package:quiet/repository/netease.dart';

bool enableCache = true;

///[T] 一定为 [neteaseLocalData] 所能保存的类型，例如 map, String , int
class NeteaseLoader<T> extends StatelessWidget {
  final Future<Result<T>> Function() loadTask;

  final LoaderWidgetBuilder<T> builder;

  final String cacheKey;

  const NeteaseLoader(
      {Key key,
      @required this.loadTask,
      @required this.builder,
      @required this.cacheKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    () async {
      debugPrint("cache_$cacheKey : ${await neteaseLocalData.get(cacheKey)}");
    }();
    return Loader<T>(
      initialData: enableCache ? neteaseLocalData.get(cacheKey) : null,
      loadTask: loadTask,
      builder: (context, result) {
        if (enableCache) {
          neteaseLocalData[cacheKey] = result;
        }
        return builder(context, result);
      },
    );
  }
}
