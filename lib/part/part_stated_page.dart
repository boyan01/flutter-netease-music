import 'package:async/async.dart';
import 'package:flutter/material.dart';

typedef LoaderWidgetBuilder = Widget Function(
    BuildContext context, dynamic result);

class StatedLoader extends StatefulWidget {
  const StatedLoader({Key key, @required this.loadTask, @required this.builder})
      : super(key: key);

  final Future<dynamic> Function() loadTask;

  final LoaderWidgetBuilder builder;

  static StatedLoaderState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<StatedLoaderState>());
  }

  @override
  State<StatefulWidget> createState() => StatedLoaderState();
}

class StatedLoaderState extends State<StatedLoader> {
  /// 0 : loading
  /// 1 : load success
  /// 2 : load failed
  int state = 0;

  CancelableOperation task;

  dynamic value;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void refresh() {
    _loadData();
  }

  void _loadData() {
    state = 0;
    task?.cancel();
    task = CancelableOperation.fromFuture(widget.loadTask())
      ..value.then((v) {
        setState(() {
          this.value = v;
          state = 1;
        });
      }).catchError(() {
        setState(() {
          state = 2;
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    task?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (state == 1) {
      return widget.builder(context, value);
    } else if (state == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Center(
      child: RaisedButton(
        onPressed: () {
          setState(() {
            _loadData();
          });
        },
        child: Text("加载失败，点击重试"),
      ),
    );
  }
}
