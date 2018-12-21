import 'package:async/async.dart';
import 'package:flutter/material.dart';

///build widget when Loader has completed loading...
typedef LoaderWidgetBuilder = Widget Function(
    BuildContext context, dynamic result);

///build widget when loader load failed
///result and msg might be null
typedef LoaderFailedWidgetBuilder = Widget Function(
    BuildContext context, dynamic result, String msg);

///the result of function [TaskResultVerify]
class VerifyValue {
  VerifyValue.success(this.result);

  VerifyValue.errorMsg(this.errorMsg) : assert(errorMsg != null);

  dynamic result;
  String errorMsg;

  bool get isSuccess => errorMsg == null;
}

///to verify [Loader.loadTask] result is success
typedef TaskResultVerify = VerifyValue Function(dynamic result);

final TaskResultVerify _emptyVerify = (dynamic result) {
  return VerifyValue.success(result);
};

class Loader extends StatefulWidget {
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
  final Future<dynamic> Function() loadTask;

  final LoaderWidgetBuilder builder;

  final TaskResultVerify resultVerify;

  ///if null, build a default error widget when load failed
  final LoaderFailedWidgetBuilder failedWidgetBuilder;

  ///widget display when loading
  ///if null ,default to display a white background with a Circle Progress
  final WidgetBuilder loadingBuilder;

  static LoaderState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<LoaderState>());
  }

  @override
  State<StatefulWidget> createState() => LoaderState();
}

enum _LoaderState {
  loading,
  success,
  failed,
}

class LoaderState extends State<Loader> {
  _LoaderState state = _LoaderState.loading;

  String _errorMsg;

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
      }).catchError(() {
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
              color: Theme.of(context).backgroundColor,
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
