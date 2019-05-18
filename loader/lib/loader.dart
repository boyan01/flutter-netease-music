library loader;

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:overlay_support/overlay_support.dart';

export 'package:async/async.dart' show Result;
export 'package:async/async.dart' show ErrorResult;
export 'package:async/async.dart' show ValueResult;

///build widget when Loader has completed loading...
typedef LoaderWidgetBuilder<T> = Widget Function(
    BuildContext context, T result);

void _defaultFailedHandler(BuildContext context, ErrorResult result) {
  toast(context, result.error?.toString() ?? defaultErrorMessage);
}

class Loader<T> extends StatefulWidget {
  const Loader(
      {Key key,
      @required this.loadTask,
      @required this.builder,
      this.loadingBuilder,
      this.initialData,
      this.onError = _defaultFailedHandler,
      this.errorBuilder})
      : assert(loadTask != null),
        assert(builder != null),
        super(key: key);

  static Widget buildSimpleLoadingWidget<T>(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 200),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static Widget buildSimpleFailedWidget(
      BuildContext context, ErrorResult result) {
    return Container(
      constraints: BoxConstraints(minHeight: 200),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(result.error.toString()),
            SizedBox(height: 8),
            RaisedButton(
                child: Text(MaterialLocalizations.of(context)
                    .refreshIndicatorSemanticLabel),
                onPressed: () {
                  Loader.of(context).refresh();
                })
          ],
        ),
      ),
    );
  }

  final FutureOr<T> initialData;

  ///task to load
  ///returned future'data will send by [LoaderWidgetBuilder]
  final Future<Result<T>> Function() loadTask;

  final LoaderWidgetBuilder<T> builder;

  final Widget Function(BuildContext context, ErrorResult result) errorBuilder;

  ///callback to handle error, could be null
  ///
  /// if null, will do nothing when an error occurred in [loadTask]
  final void Function(BuildContext context, ErrorResult result) onError;

  ///widget display when loading
  ///if null ,default to display a white background with a Circle Progress
  final WidgetBuilder loadingBuilder;

  static LoaderState<T> of<T>(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<LoaderState>());
  }

  @override
  State<StatefulWidget> createState() => LoaderState<T>();
}

@visibleForTesting
const defaultErrorMessage = '啊哦，出错了~';

class LoaderState<T> extends State<Loader> {
  bool get isLoading => _loadingTask != null;

  CancelableOperation _loadingTask;

  Result<T> value;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      scheduleMicrotask(() async {
        final data = await widget.initialData;
        if (data != null) {
          await _loadData(Future.value(Result.value(data)), force: true);
        }
        await refresh();
      });
    } else {
      refresh();
    }
  }

  @override
  Loader<T> get widget => super.widget;

  ///refresh data
  ///force: true to force refresh when a loading ongoing
  Future<void> refresh({bool force: false}) async {
    await _loadData(widget.loadTask(), force: false);
  }

  Future<Result<T>> _loadData(Future<Result<T>> future, {bool force = false}) {
    assert(future != null);
    assert(force != null);

    if (_loadingTask != null && !force) {
      return _loadingTask.value;
    }
    _loadingTask?.cancel();
    _loadingTask = CancelableOperation<Result<T>>.fromFuture(future)
      ..value.then((result) {
        assert(result != null, "result can not be null");
        if (result.isError) {
          _onError(result);
        } else {
          value = result;
        }
      }).catchError((e, StackTrace stack) {
        _onError(Result.error(e, stack));
      }).whenComplete(() {
        _loadingTask = null;
        setState(() {});
      });
    //notify if should be in loading status
    setState(() {});
    return _loadingTask.value;
  }

  void _onError(ErrorResult result) {
    if (result.stackTrace != null) {
      debugPrint(result.stackTrace.toString());
    }

    if (value == null || value.isError) {
      value = result;
    }
    if (widget.onError != null) {
      widget.onError(context, result);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _loadingTask?.cancel();
    _loadingTask = null;
  }

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      return LoaderResultWidget(
          result: value,
          valueBuilder: widget.builder,
          errorBuilder: widget.errorBuilder ?? Loader.buildSimpleFailedWidget);
    }
    return (widget.loadingBuilder ?? Loader.buildSimpleLoadingWidget)(context);
  }
}

@visibleForTesting
class LoaderResultWidget<T> extends StatelessWidget {
  final Result<T> result;

  final LoaderWidgetBuilder<T> valueBuilder;
  final Widget Function(BuildContext context, ErrorResult result) errorBuilder;

  const LoaderResultWidget(
      {Key key,
      @required this.result,
      @required this.valueBuilder,
      @required this.errorBuilder})
      : assert(result != null),
        assert(valueBuilder != null),
        assert(errorBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (result.isValue) {
      return valueBuilder(context, result.asValue.value);
    } else {
      return errorBuilder(context, result);
    }
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
