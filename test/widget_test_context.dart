import 'package:flutter/material.dart';
import 'package:music_player/music_player.dart';
import 'package:quiet/component/player/player.dart';

///配置一些通用用于测试的Widget上下文
class TestContext extends StatefulWidget {
  const TestContext({Key? key, this.child}) : super(key: key);
  final Widget? child;

  @override
  _TestContextState createState() => _TestContextState();
}

class _TestContextState extends State<TestContext> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
          child: ScopedModel<QuietModel>(
        model: _TestQuietModel(),
        child: DisableBottomController(child: widget.child),
      )),
    );
  }
}

class _TestQuietModel extends Model implements QuietModel {
  //TODO test
  @override
  MusicPlayer player = MusicPlayer();
}
