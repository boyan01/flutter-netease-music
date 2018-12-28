import 'package:async/async.dart';
import 'package:flutter/material.dart';

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
      this.failedWidgetBuilder})
      : assert(loadTask != null),
        assert(builder != null),
        super(key: key);

  ///task to load
  ///returned future'data will send by [LoaderWidgetBuilder]
  final Future<T> Function() loadTask;

  final LoaderWidgetBuilder<T> builder;

  final TaskResultVerify<T> resultVerify;

  ///if null, build a default error widget when load failed
  final LoaderFailedWidgetBuilder<T> failedWidgetBuilder;

  ///widget display when loading
  ///if null ,default to display a white background with a Circle Progress
  final WidgetBuilder loadingBuilder;

  static LoaderState of(BuildContext context) {
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
    _loadData();
  }

  void refresh() {
    _loadData();
  }

  @override
  Loader<T> get widget => super.widget;

  void _loadData() {
    state = _LoaderState.loading;
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
        debugPrint("error to load : $dynamic");
        debugPrint(stack.toString());
        setState(() {
          state = _LoaderState.failed;
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
    if (state == _LoaderState.success) {
      return widget.builder(context, value);
    } else if (state == _LoaderState.loading) {
      return widget.loadingBuilder != null
          ? widget.loadingBuilder(context)
          : Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
    }
    return widget.failedWidgetBuilder != null
        ? widget.failedWidgetBuilder(context, value, _errorMsg)
        : Scaffold(
            body: Container(
              constraints: BoxConstraints.expand(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Spacer(),
                  _errorMsg == null
                      ? null
                      : Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            _errorMsg,
                            style: Theme.of(context).textTheme.body1,
                          ),
                        ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.title.color,
                    onPressed: () {
                      setState(() {
                        _loadData();
                      });
                    },
                    child: Text("加载失败，点击重试"),
                  ),
                  Spacer(),
                ]..removeWhere((v) => v == null),
              ),
            ),
          );
  }
}
