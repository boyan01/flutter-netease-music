import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/repository/netease.dart';
import 'package:scoped_model/scoped_model.dart';

class Netease extends StatefulWidget {
  final Widget child;

  const Netease({Key key, @required this.child}) : super(key: key);

  @override
  NeteaseState createState() => NeteaseState();

  static NeteaseState of(BuildContext context) {
    return context.ancestorStateOfType(TypeMatcher<NeteaseState>());
  }
}

class NeteaseState extends State<Netease> {
  final LoginState loginState = LoginState();

  Counter counter;

  @override
  void initState() {
    super.initState();
    counter = Counter(loginState, neteaseRepository, neteaseLocalData);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<LoginState>(
      model: loginState,
      child: ScopedModel<LikedSongList>(
        model: LikedSongList(loginState),
        child: ScopedModel<Counter>(
          model: counter,
          child: widget.child,
        ),
      ),
    );
  }
}
