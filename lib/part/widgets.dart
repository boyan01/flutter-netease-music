import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:quiet/model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player_service.dart';

///登录状态
///在上层嵌套 LoginStateWidget 以监听用户登录状态
class LoginState extends InheritedWidget {
  ///根据BuildContext获取 [LoginState]
  static LoginState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(LoginState);
  }

  ///刷新登录状态，检查是否登录状态已改变
  static void refresh(BuildContext context) {
    _LoginState _state =
        context.ancestorStateOfType(const TypeMatcher<_LoginState>());
    _state.checkIsLogin();
  }

  LoginState(this.user, this.child) : super(child: child);

  ///null -> not login
  ///not null -> login
  final Map<String, Object> user;

  final Widget child;

  @override
  bool updateShouldNotify(LoginState oldWidget) {
    return user != oldWidget.user;
  }

  ///当前是否已登录
  bool get isLogin {
    return user != null;
  }

  ///当前登录用户的id
  int get userId {
    if (!isLogin) {
      throw Exception("当前没有用户登录");
    }
    Map<String, Object> account = user["account"];
    return account["id"];
  }
}

class LoginStateWidget extends StatefulWidget {
  LoginStateWidget(this.child);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginStateWidget> {
  Map<String, Object> user;

  void checkIsLogin() {
    SharedPreferences.getInstance().then((preference) {
      var jsonStr = preference.getString("login_user");

      Map<String, Object> user;
      if (jsonStr == null || jsonStr.isEmpty) {
        user = null;
      }
      try {
        user = json.decode(jsonStr);
      } catch (e) {}
      if (user != this.user) {
        setState(() {
          this.user = user;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIsLogin();
  }

  @override
  Widget build(BuildContext context) {
    return LoginState(user, widget.child);
  }
}

class BoxWithBottomPlayerController extends StatefulWidget {
  BoxWithBottomPlayerController(this.child);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _BoxWithBottomPlayerControllerState();
}

class _BoxWithBottomPlayerControllerState
    extends State<BoxWithBottomPlayerController> {
  Music current;

  void _onMusicChange(Music music) {
    setState(() {
      current = music;
    });
  }

  @override
  void initState() {
    super.initState();
    quiet.addMusicChangeListener(_onMusicChange);
  }

  @override
  void dispose() {
    super.dispose();
    quiet.removeMusicChangeListener(_onMusicChange);
  }

  @override
  Widget build(BuildContext context) {
    if (current == null) {
      return widget.child;
    }
    debugPrint("create bottom controller bar");
    return Column(
      children: <Widget>[
        Expanded(child: widget.child),
        BottomControllerBar(current),
      ],
    );
  }
}

class BottomControllerBar extends StatelessWidget {
  BottomControllerBar(this.music);

  final Music music;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
              topLeft: const Radius.circular(4.0),
              topRight: const Radius.circular(4.0))),
      child: Container(
        height: 56,
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                child: CachedNetworkImage(
                  imageUrl: music.album.coverImageUrl,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  Text(
                    music.title,
                    style: Theme.of(context).textTheme.body1,
                  ),
                  Padding(padding: const EdgeInsets.only(top: 2)),
                  Text(
                    music.subTitle,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Spacer(),
                ],
              ),
            ),
            IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  quiet.play();
                }),
            IconButton(
                icon: Icon(Icons.skip_next),
                onPressed: () {
                  quiet.playNext();
                }),
          ],
        ),
      ),
    );
  }
}
