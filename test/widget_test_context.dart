import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:quiet/component/netease/counter.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/component/player/player.dart';
import 'package:quiet/pages/account/account.dart';
import 'package:quiet/service/channel_media_player.dart';
import 'package:scoped_model/scoped_model.dart';

import 'repository/mock.dart';

///配置一些通用用于测试的Widget上下文
class TestContext extends StatelessWidget {
  final Widget child;

  final MockLoginState account = MockLoginState();

  final likedSong = MockLikedSongList();

  TestContext({Key key, this.child}) : super(key: key) {
    when(account.isLogin).thenReturn(false);
    when(likedSong.ids).thenReturn([]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
          child: ScopedModel<UserAccount>(
        model: account,
        child: ScopedModel<Counter>(
          model: Counter(account, null, null),
          child: ScopedModel<LikedSongList>(
            model: likedSong,
            child: PlayerState(
                value: PlayerControllerState.uninitialized(),
                child: DisableBottomController(child: child)),
          ),
        ),
      )),
    );
  }
}
