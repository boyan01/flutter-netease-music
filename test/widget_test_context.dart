import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:music_player/music_player.dart';
import 'package:provider/provider.dart';
import 'package:quiet/component/netease/counter.dart';
import 'package:quiet/component/netease/netease.dart';
import 'package:quiet/component/player/player.dart';
import 'package:scoped_model/scoped_model.dart';

import 'repository/mock.dart';

///配置一些通用用于测试的Widget上下文
class TestContext extends StatefulWidget {
  final Widget child;

  TestContext({Key key, this.child}) : super(key: key);

  @override
  _TestContextState createState() => _TestContextState();
}

class _TestContextState extends State<TestContext> {
  final MockLoginState account = MockLoginState();

  final likedSong = MockLikedSongList();

  @override
  void initState() {
    super.initState();
    when(account.isLogin).thenReturn(false);
    when(likedSong.ids).thenReturn([]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
          child: ChangeNotifierProvider.value(
        value: account,
        child: ScopedModel<Counter>(
          model: Counter(account, null, null),
          child: ScopedModel<FavoriteMusicList>(
            model: likedSong,
            child: ScopedModel<QuietModel>(
              model: _TestQuietModel(),
              child: DisableBottomController(child: widget.child),
            ),
          ),
        ),
      )),
    );
  }
}

class _TestQuietModel extends Model implements QuietModel {
  //TODO test
  @override
  MusicPlayer player = MusicPlayer();
}
