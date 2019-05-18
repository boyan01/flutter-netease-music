import 'package:flutter/material.dart';
import 'package:quiet/component/player/player.dart';
import 'package:quiet/part/part.dart';
import 'package:quiet/service/channel_media_player.dart';

///配置一些通用用于测试的Widget上下文
class TestContext extends StatelessWidget {
  final Widget child;

  const TestContext({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
          child: ScopedModel<UserAccount>(
            model: UserAccount(),
            child: PlayerState(
                value: PlayerControllerState.uninitialized(),
                child: DisableBottomController(child: child)),
          )),
    );
  }
}
