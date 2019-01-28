import 'package:flutter/material.dart';
import 'package:quiet/part/part.dart';
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


  @override
  Widget build(BuildContext context) {
    return ScopedModel<LoginState>(
      model: loginState,
      child: ScopedModel<LikedSongList>(
        model: LikedSongList(loginState),
        child: ScopedModelDescendant<LoginState>(
          builder: (context, child, loginState) {
            return CounterHolder(loginState.isLogin, child: child);
          },
          child: widget.child,
        ),
      ),
    );
  }
}
