import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

///build widget when Loader has completed loading...
typedef LoaderWidgetBuilder<T> = Widget Function(
    BuildContext context, T result);

///build widget when loader load failed
///result and msg might be null
typedef LoaderFailedWidgetBuilder<T> = Widget Function(
    BuildContext context, T result, String msg);

///the result of function [TaskResultVerify]
class VerifyValue<T> {
  VerifyValue.success(this.result);

  VerifyValue.errorMsg(this.errorMsg) : assert(errorMsg != null);

  T result;
  String errorMsg;

  bool get isSuccess => errorMsg == null;
}

///to verify [Loader.loadTask] result is success
typedef TaskResultVerify<T> = VerifyValue Function(T result);

final TaskResultVerify _emptyVerify = (dynamic result) {
  return VerifyValue.success(result);
};

///create a simple [TaskResultVerify]
///use bool result to check result if valid
TaskResultVerify<T> simpleLoaderResultVerify<T>(bool test(T t),
    {String errorMsg = "falied"}) {
  assert(errorMsg != null);
  TaskResultVerify<T> verify = (result) {
    if (test(result)) {
      return VerifyValue.success(result);
    } else {
      return VerifyValue.errorMsg(errorMsg);
    }
  };
  return verify;
}

class Loader<T> extends StatefulWidget {
  const Loader(
      {Key key,
      @required this.loadTask,
      @required this.builder,
      this.resultVerify,
      this.loadingBuilder,
      this.failedWidgetBuilder,
      this.initialData,
      this.onFailed = defaultFailedHandler})
      : assert(loadTask != null),
        assert(builder != null),
        super(key: key);

  static Widget buildSimpleFailedWidget<T>(
      BuildContext context, T result, String msg) {
    return Container(
      constraints: BoxConstraints(minHeight: 200),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(msg),
            SizedBox(height: 8),
            RaisedButton(
                child: Text("重试"),
                onPressed: () {
                  Loader.of(context).refresh();
                })
          ],
        ),
      ),
    );
  }

  static Widget buildSimpleLoadingWidget<T>(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 200),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void defaultFailedHandler<T>(
      BuildContext context, T result, String msg) {
    showSimpleNotification(context, Text(msg));
  }

  final FutureOr<T> initialData;

  ///task to load
  ///returned future'data will send by [LoaderWidgetBuilder]
  final Future<T> Function() loadTask;

  final LoaderWidgetBuilder<T> builder;

  final TaskResultVerify<T> resultVerify;

  ///if null, build a default error widget when load failed
  final LoaderFailedWidgetBuilder<T> failedWidgetBuilder;

  ///callback to handle error, could be null
  ///if [initialData] has been loaded, [failedWidgetBuilder] will never be invoked
  ///because current is showing initial data
  ///so we need send the error msg to callback, let caller handle it.
  final void Function<T>(BuildContext context, T result, String msg) onFailed;

  ///widget display when loading
  ///if null ,default to display a white background with a Circle Progress
  final WidgetBuilder loadingBuilder;

  static LoaderState<T> of<T>(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<LoaderState>());
  }

  @override
  State<StatefulWidget> createState() => LoaderState<T>();
}

enum _LoaderState {
  loading,
  success,
  failed,
}

class LoaderState<T> extends State<Loader> {
  _LoaderState state = _LoaderState.loading;

  String _errorMsg;

  CancelableOperation task;

  T value;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _loadInitialData();
    } else {
      _loadData();
    }
  }

  void _loadInitialData() async {
    try {
      final result = await widget.initialData;
      if (result != null) {
        setState(() {
          this.value = result;
        });
      }
    } catch (e) {
      //do nothing...
      debugPrint("_loadInitialData error $e");
    }
    _loadData();
  }

  Future<void> refresh() async {
    await _loadData();
  }

  @override
  Loader<T> get widget => super.widget;

  Future<dynamic> _loadData() {
    if (state == _LoaderState.loading && task != null) {
      return task.value;
    }
    setState(() {
      state = _LoaderState.loading;
    });
    task?.cancel();
    task = CancelableOperation.fromFuture(widget.loadTask())
      ..value.then((v) {
        var verify = (widget.resultVerify ?? _emptyVerify)(v);
        if (verify.isSuccess) {
          setState(() {
            this.value = verify.result;
            state = _LoaderState.success;
          });
        } else {
          setState(() {
            state = _LoaderState.failed;
            _errorMsg = verify.errorMsg;
          });
        }
      }).catchError((e, StackTrace stack) {
        debugPrint("error to load : $e");
        _errorMsg = e.toString() ?? "出错";
        state = _LoaderState.failed;
        if (value != null && widget.onFailed != null) {
          widget.onFailed(context, null, _errorMsg);
        }
      });
    return task.value;
  }

  @override
  void dispose() {
    super.dispose();
    task?.cancel();
    task = null;
  }

  @override
  Widget build(BuildContext context) {
    if (state == _LoaderState.success || value != null) {
      return widget.builder(context, value);
    } else if (state == _LoaderState.failed || _errorMsg != null) {
      return Builder(
          builder: (context) => (widget.failedWidgetBuilder ??
              Loader.buildSimpleFailedWidget)(context, value, _errorMsg));
    }
    return (widget.loadingBuilder ?? Loader.buildSimpleLoadingWidget)(context);
  }
}

///a list view
///auto load more when reached the bottom
class AutoLoadMoreList<T> extends StatefulWidget {
  ///list total count
  final totalCount;

  ///initial list item
  final List<T> initialList;

  ///return the items loaded
  ///null indicator failed
  final Future<List<T>> Function(int loadedCount) loadMore;

  ///build list tile with item
  final Widget Function(BuildContext context, T item) builder;

  const AutoLoadMoreList(
      {Key key,
      @required this.loadMore,
      @required this.totalCount,
      @required this.initialList,
      @required this.builder})
      : super(key: key);

  @override
  _AutoLoadMoreListState<T> createState() => _AutoLoadMoreListState<T>();
}

class _AutoLoadMoreListState<T> extends State<AutoLoadMoreList> {
  ///true when more item available
  bool hasMore;

  ///true when load error occurred
  bool error = false;

  List<T> items = [];

  CancelableOperation<List> _autoLoadOperation;

  @override
  AutoLoadMoreList<T> get widget => super.widget;

  @override
  void initState() {
    super.initState();
    items.clear();
    items.addAll(widget.initialList ?? []);
    hasMore = items.length < widget.totalCount;
  }

  void _load() {
    if (hasMore && !error && _autoLoadOperation == null) {
      _autoLoadOperation =
          CancelableOperation<List<T>>.fromFuture(widget.loadMore(items.length))
            ..value.then((result) {
              if (result == null) {
                error = true;
              } else if (result.isEmpty) {
                //assume empty represent end of list
                hasMore = false;
              } else {
                items.addAll(result);
                hasMore = items.length < widget.totalCount;
              }
              setState(() {});
            }).whenComplete(() {
              _autoLoadOperation = null;
            }).catchError((e) {
              setState(() {
                error = true;
              });
            });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 500) {
          _load();
        }
      },
      child: ListView.builder(
          itemCount: items.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= 0 && index < items.length) {
              return widget.builder(context, items[index]);
            } else if (index == items.length && hasMore) {
              if (!error) {
                return _ItemLoadMore();
              } else {
                return Container(
                  height: 56,
                  child: Center(
                    child: RaisedButton(
                      onPressed: () {
                        error = false;
                        _load();
                      },
                      child: Text("加载失败！点击重试"),
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      color: Theme.of(context).errorColor,
                    ),
                  ),
                );
              }
            }
            throw Exception("illegal state");
          }),
    );
  }
}

///suffix of a list, indicator that list is loading more items
class _ItemLoadMore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            child: CircularProgressIndicator(),
            height: 16,
            width: 16,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
          ),
          Text("正在加载更多...")
        ],
      ),
    );
  }
}
