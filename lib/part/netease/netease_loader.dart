import 'package:flutter/material.dart';
import 'package:quiet/part/loader.dart';

import 'package:quiet/repository/netease.dart';

///[T] 一定为 [neteaseLocalData] 所能保存的类型，例如 map, String , int
class NeteaseLoader<T> extends StatelessWidget {
  final Future<T> Function() loadTask;

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
    return Loader<T>(
      initialData: neteaseLocalData.get(cacheKey),
      resultVerify: neteaseRepository.responseVerify,
      loadTask: loadTask,
      builder: (context, result) {
        neteaseLocalData[cacheKey] = result;
        return builder(context, result);
      },
    );
  }
}
