import 'package:async/async.dart';
import 'package:flutter/material.dart';

///build widget when Loader has completed loading...
typedef LoaderWidgetBuilder = Widget Function(
    BuildContext context, dynamic result);

class Loader extends StatefulWidget {
  const Loader(
      {Key key,
      @required this.loadTask,
      @required this.builder,
      this.loadingBuilder})
      : super(key: key);

  ///task to load
  ///returned future'data will send by [LoaderWidgetBuilder]
  final Future<dynamic> Function() loadTask;

  final LoaderWidgetBuilder builder;

  ///widget display when loading
  ///if null ,default to display a white background with a Circle Progress
  final WidgetBuilder loadingBuilder;

  static LoaderState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<LoaderState>());
  }

  @override
  State<StatefulWidget> createState() => LoaderState();
}

class LoaderState extends State<Loader> {
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
      return widget.loadingBuilder != null
          ? widget.loadingBuilder(context)
          : Container(
              color: Theme.of(context).backgroundColor,
              child: Center(
                child: CircularProgressIndicator(),
              ),
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
