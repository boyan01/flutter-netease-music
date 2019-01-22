import 'package:flutter/material.dart';
import 'package:quiet/repository/netease.dart';

///
/// 提供各种数目,比如收藏数目,我的电台数目
///
class Counter extends InheritedWidget {
  final int djRadioCount;

  final int artistCount;

  final int mvCount;

  final int createDjRadioCount;

  final int createdPlaylistCount;

  final int subPlaylistCount;

  const Counter({
    @required this.djRadioCount,
    @required this.artistCount,
    @required this.mvCount,
    @required this.createDjRadioCount,
    @required this.createdPlaylistCount,
    @required this.subPlaylistCount,
    Key key,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  static Counter of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(Counter) as Counter;
  }

  static Future refresh(BuildContext context) {
    _CounterHolderState state =
        context.ancestorStateOfType(const TypeMatcher<_CounterHolderState>());
    return state._refresh();
  }

  @override
  bool updateShouldNotify(Counter old) {
    return djRadioCount != old.djRadioCount &&
        artistCount != old.artistCount &&
        mvCount != old.mvCount &&
        createDjRadioCount != old.createDjRadioCount &&
        createdPlaylistCount != old.createdPlaylistCount &&
        subPlaylistCount != old.subPlaylistCount;
  }
}

class CounterHolder extends StatefulWidget {
  final Widget child;

  final bool login;

  const CounterHolder(this.login, {Key key, this.child}) : super(key: key);

  @override
  _CounterHolderState createState() => _CounterHolderState();
}

class _CounterHolderState extends State<CounterHolder> {
  Map result;

  @override
  void initState() {
    super.initState();
    if (widget.login) {
      _refresh();
    }
  }

  @override
  void didUpdateWidget(CounterHolder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.login && !oldWidget.login) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return Counter(
          djRadioCount: 0,
          artistCount: 0,
          mvCount: 0,
          createDjRadioCount: 0,
          createdPlaylistCount: 0,
          subPlaylistCount: 0,
          child: widget.child);
    } else {
      return Counter(
        child: widget.child,
        artistCount: result['artistCount'] ?? 0,
        djRadioCount: result['djRadioCount'] ?? 0,
        mvCount: result['mvCount'] ?? 0,
        createDjRadioCount: result['createDjRadioCount'] ?? 0,
        createdPlaylistCount: result['createdPlaylistCount'] ?? 0,
        subPlaylistCount: result['subPlaylistCount'] ?? 0,
      );
    }
  }

  Future _refresh() {
    final stream = NeteaseLocalData.withData(
        "netease_sub_count", neteaseRepository.subCount());
    return stream.listen((data) {
      setState(() {
        result = data;
      });
    }, onError: (error) {
      debugPrint("on _refresh error $error");
    }).asFuture();
  }
}
