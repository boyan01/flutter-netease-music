import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnEmit = void Function(String char);
typedef OnDelete = void Function();

class KeyEmitter extends StatefulWidget {
  final Widget child;
  final OnEmit onEmit;
  final OnDelete onDelete;

  const KeyEmitter({
    Key key,
    @required this.onEmit,
    @required this.child,
    @required this.onDelete,
  }) : super(key: key);

  @override
  _KeyEmitterState createState() => _KeyEmitterState();
}

class _KeyEmitterState extends State<KeyEmitter> {
  static const _acceptedKeys = [
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.keyC,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyE,
    LogicalKeyboardKey.keyF,
    LogicalKeyboardKey.keyG,
    LogicalKeyboardKey.keyH,
    LogicalKeyboardKey.keyI,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
    LogicalKeyboardKey.keyL,
    LogicalKeyboardKey.keyM,
    LogicalKeyboardKey.keyN,
    LogicalKeyboardKey.keyO,
    LogicalKeyboardKey.keyP,
    LogicalKeyboardKey.keyQ,
    LogicalKeyboardKey.keyR,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyT,
    LogicalKeyboardKey.keyU,
    LogicalKeyboardKey.keyV,
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyX,
    LogicalKeyboardKey.keyY,
    LogicalKeyboardKey.keyZ,
    LogicalKeyboardKey.space,
  ];

  void _onKeyboard(RawKeyEvent event) {
    // ignore down event.
    if (event is! RawKeyUpEvent) {
      return;
    }
    if (_acceptedKeys.contains(event.logicalKey)) {
      widget.onEmit(event.logicalKey.keyLabel);
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      widget.onDelete();
    }
  }

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_onKeyboard);
  }

  @override
  void dispose() {
    super.dispose();
    RawKeyboard.instance.removeListener(_onKeyboard);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
